import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart';

import '../../../di/di.dart';
import '../../services/auth/admin_auth_service.dart';

/// The single place the app decides whether content-management UI exists.
///
/// Three builds, three behaviours:
///
/// - **Public release** (`flutter build web`) — renders nothing, ever. No
///   `ADMIN_BUILD` define means [isEnabled] folds to a compile-time `false`.
///   What actually keeps a *credential* out of that build is not this gate
///   but the build command: compiled without the Cloudinary defines,
///   `String.fromEnvironment` in `CloudinaryUploadService` is the empty
///   string in those binaries, so there is no secret in them to find no
///   matter how much of the admin widget tree the tree-shaker does or does
///   not manage to drop. (Widgets handed to this gate as [child] are
///   constructed by their caller before it decides anything, so treat "never
///   renders" as the guarantee here, not "never shipped".)
/// - **Admin release** (`--dart-define=ADMIN_BUILD=true`, deployed to its own
///   unlisted URL) — renders only once Firebase Auth reports a signed-in
///   owner. The sign-in itself is reachable from the footer heart, which sits
///   deliberately *outside* this gate: it is the only way in when nothing
///   else is showing yet.
/// - **Debug** (`flutter run`) — renders immediately, no sign-in. Editing
///   locally against the cache is the whole point of a dev run, and Firestore
///   still refuses an unauthenticated *write* regardless.
///
/// Sign-in is a UI gate, not the security boundary. Firestore's rules accept
/// a write only from the owner uid, so a stranger who finds the admin URL
/// sees a locked screen — and even past it, the server would reject them.
class AdminGate extends StatelessWidget {
  const AdminGate({required this.child, this.fallback, super.key});

  final Widget child;

  /// Rendered instead of [child] when the gate is shut. Defaults to nothing.
  final Widget? fallback;

  /// Compile-time: whether this build carries admin code at all. `const` so
  /// the tree-shaker can prove the admin tree unreachable in a public build
  /// and drop it, rather than merely hiding it at runtime.
  static const bool _isAdminBuild = bool.fromEnvironment('ADMIN_BUILD');

  /// Whether content-management UI exists in this build.
  ///
  /// Lets non-widget code (route guards, cubit branches) ask the same
  /// question — but note it answers "does this build have admin code", not
  /// "is the admin signed in". A caller that gates a *write* wants
  /// [AdminAuthService] instead.
  static bool get isEnabled => kDebugMode || _isAdminBuild;

  /// A debug run is already a trusted machine; the deployed admin build is
  /// not, so only that one waits for a real session.
  static bool get _requiresSignIn => !kDebugMode;

  @override
  Widget build(BuildContext context) {
    final closed = fallback ?? const SizedBox.shrink();
    if (!isEnabled) return closed;
    if (!_requiresSignIn) return child;

    final auth = getIt<AdminAuthService>();
    return StreamBuilder<bool>(
      // Seeded so a restored session paints admin UI on the first frame
      // rather than flashing the signed-out state for one frame first.
      initialData: auth.isSignedInNow,
      stream: auth.signedInChanges,
      builder: (context, snapshot) =>
          (snapshot.data ?? false) ? child : closed,
    );
  }
}
