import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:injectable/injectable.dart';

import '../../common/data_result.dart';

/// The single owner account's sign-in, gating writes to Firestore.
///
/// `AdminGate` (`kDebugMode`) is still the only reason this UI exists at all —
/// it is tree-shaken out of release builds entirely. This service is the
/// *real* boundary underneath it: Firestore's security rules accept a write
/// only from this one uid, so an unauthenticated client is rejected by the
/// server regardless of what the client believes its own state is.
@lazySingleton
class AdminAuthService {
  const AdminAuthService();

  /// Resolved on use rather than injected, matching
  /// [PortfolioRemoteDataSourceImpl._firestore]: `main()` lets
  /// `Firebase.initializeApp` fail without stopping the app, and
  /// `FirebaseAuth.instance` throws when Firebase never initialised. Taking it
  /// as a constructor argument would move that throw into DI resolution,
  /// outside every guard.
  FirebaseAuth? get _auth {
    if (Firebase.apps.isEmpty) return null;
    try {
      return FirebaseAuth.instance;
    } on Object {
      return null;
    }
  }

  /// Synchronous read for the very first frame, before [signedInChanges] has
  /// emitted anything — avoids a flash of "signed out" UI while Firebase
  /// restores a persisted session.
  bool get isSignedInNow => _auth?.currentUser != null;

  /// Emits on every sign-in/out, including the persisted session
  /// [FirebaseAuth] restores on load. A client where Firebase never
  /// initialised gets a single `false` rather than a stream that never fires —
  /// callers should treat "no Firebase" the same as "signed out".
  Stream<bool> get signedInChanges {
    final auth = _auth;
    if (auth == null) return Stream<bool>.value(false);
    return auth.authStateChanges().map((user) => user != null);
  }

  Future<DataResult<void>> signIn({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) {
      return const Fail<void>(
        'Firebase is not available in this build — check the console for '
        'an initialisation error.',
      );
    }
    try {
      await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return const Success<void>(null);
    } on FirebaseAuthException catch (error) {
      return Fail<void>(_messageFor(error), error);
    } on Object catch (error, stack) {
      return Fail<void>('Could not sign in.', error, stack);
    }
  }

  Future<void> signOut() async => _auth?.signOut();

  /// A handful of codes translated to something an admin — just Marco — can
  /// act on; anything else falls back to Firebase's own message rather than
  /// going silent on a code this was not written against.
  String _messageFor(FirebaseAuthException error) => switch (error.code) {
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => 'Wrong email or password.',
    'invalid-email' => 'That email address looks invalid.',
    'too-many-requests' => 'Too many attempts — try again later.',
    'network-request-failed' => 'No network connection.',
    'user-disabled' => 'This account has been disabled.',
    _ => error.message ?? 'Could not sign in.',
  };
}
