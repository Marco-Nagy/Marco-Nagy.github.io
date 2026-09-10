import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../di/di.dart';
import '../../../features/portfolio_content/domain/entities/portfolio_bundle.dart';
import '../../../features/portfolio_content/domain/use_cases/bundle_use_case.dart'
    show BundleExport, BundleUseCase;
import '../../common/data_result.dart';
import '../../localization/lang_keys.dart';
import '../../services/auth/admin_auth_service.dart';
import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import 'admin_gate.dart';
import 'admin_sign_in_sheet.dart';
import 'admin_svg_icons.dart';

/// The one site-wide admin entry point, mounted once in `PortfolioScaffold`.
///
/// A speed-dial rather than a single button because the store-wide actions
/// (sign-in, publish, export; the site-content forms as later phases land)
/// belong to no particular list, so they have nowhere else to live. Per-list
/// add/edit/delete stays inline on the list, via `AdminAddButton` and
/// `AdminItemActions` — those must dispatch into their own cubit, which a
/// page-level control sits outside of.
///
/// Wrapped in [AdminGate], so release builds do not merely hide it: the whole
/// subtree, including the sign-in and publish paths, is tree-shaken away.
/// That is also why an unsigned Cloudinary upload preset is safe to ship
/// (Phase 6) and why a signed-out write is rejected server-side rather than
/// merely hidden client-side (Phase 2): none of this reaches a visitor.
class AdminFab extends StatefulWidget {
  const AdminFab({super.key});

  @override
  State<AdminFab> createState() => _AdminFabState();
}

class _AdminFabState extends State<AdminFab> {
  bool _open = false;
  bool _busy = false;

  Future<void> _signIn() async {
    setState(() => _open = false);
    await AdminSignInSheet.show(context);
    // No result to branch on: the sheet pops on success and stays open on
    // failure, showing its own inline error. The StreamBuilder below picks up
    // the new auth state on its own the moment sign-in succeeds.
  }

  Future<void> _signOut() async {
    if (_busy) return;
    setState(() => _busy = true);
    await getIt<AdminAuthService>().signOut();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _publish() async {
    if (_busy) return;
    setState(() => _busy = true);

    final result = await getIt<BundleUseCase>().publish();
    if (!mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    final published = context.translate(LangKeys.adminPublished);
    final failed = context.translate(LangKeys.adminPublishFailed);
    final danger = context.colors.danger;

    switch (result) {
      case Success<PortfolioBundle>(data: final bundle):
        messenger?.showSnackBar(
          SnackBar(content: Text('$published (v${bundle.contentVersion})')),
        );
      case Fail<PortfolioBundle>(:final message):
        messenger?.showSnackBar(
          SnackBar(
            backgroundColor: danger,
            duration: const Duration(seconds: 8),
            content: Text('$failed: $message'),
          ),
        );
    }

    if (mounted) setState(() => _busy = false);
  }

  Future<void> _export() async {
    if (_busy) return;
    setState(() => _busy = true);

    final result = await getIt<BundleUseCase>().exportJson();
    if (!mounted) return;

    // Read every context-dependent value before the await inside
    // Clipboard.setData, and hold the messenger rather than the context: the
    // widget can be disposed while the platform channel is in flight.
    final messenger = ScaffoldMessenger.maybeOf(context);
    final copied = context.translate(LangKeys.adminExportCopied);
    final failed = context.translate(LangKeys.adminExportFailed);
    final oversize = context.translate(LangKeys.adminExportOversize);
    final embedded = context.translate(LangKeys.adminExportEmbedded);
    final danger = context.colors.danger;

    switch (result) {
      case Success<BundleExport>(data: final export):
        await Clipboard.setData(ClipboardData(text: export.json));

        // Copying still happens — the text is useful for inspecting what went
        // wrong — but the result says plainly whether it can be published,
        // rather than letting Firestore reject it later with no context.
        final problems = <String>[
          if (!export.fitsFirestore) oversize,
          if (export.hasEmbeddedImages)
            '$embedded (${export.embeddedImageCount})',
        ];
        messenger?.showSnackBar(
          SnackBar(
            backgroundColor: problems.isEmpty ? null : danger,
            duration: Duration(seconds: problems.isEmpty ? 4 : 8),
            content: Text(
              <String>[
                '$copied — ${export.sizeLabel}',
                ...problems,
              ].join('\n'),
            ),
          ),
        );
      case Fail<BundleExport>(message: final message):
        messenger?.showSnackBar(SnackBar(content: Text('$failed: $message')));
    }

    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return AdminGate(
      child: StreamBuilder<bool>(
        // initialData avoids a flash of "signed out" before Firebase's
        // persisted-session restore emits its first event.
        initialData: getIt<AdminAuthService>().isSignedInNow,
        stream: getIt<AdminAuthService>().signedInChanges,
        builder: (context, snapshot) {
          final signedIn = snapshot.data ?? false;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              if (_open) ...<Widget>[
                _AdminFabAction(
                  label: context.translate(
                    signedIn ? LangKeys.adminSignOut : LangKeys.adminSignIn,
                  ),
                  icon: signedIn ? Icons.logout_rounded : Icons.login_rounded,
                  busy: _busy,
                  onPressed: signedIn ? _signOut : _signIn,
                ),
                if (signedIn)
                  _AdminFabAction(
                    label: context.translate(LangKeys.adminPublish),
                    icon: Icons.cloud_upload_rounded,
                    busy: _busy,
                    onPressed: _publish,
                  ),
                _AdminFabAction(
                  label: context.translate(LangKeys.adminExport),
                  icon: Icons.download_rounded,
                  busy: _busy,
                  onPressed: _export,
                ),
              ],
              SizedBox(height: 12.h),
              FloatingActionButton.extended(
                heroTag: 'admin-fab',
                onPressed: () => setState(() => _open = !_open),
                backgroundColor: context.colors.accent,
                foregroundColor: context.colors.pageTop,
                icon: _open
                    ? Icon(Icons.close, size: 18.r)
                    : SvgPicture.string(
                        AdminSvgIcons.add,
                        width: 18.r,
                        height: 18.r,
                        colorFilter: ColorFilter.mode(
                          context.colors.pageTop,
                          BlendMode.srcIn,
                        ),
                      ),
                label: Text(
                  context
                      .translate(
                        _open ? LangKeys.adminMenuClose : LangKeys.adminMenu,
                      )
                      .toUpperCase(),
                  style: MyFonts.caps10.copyWith(color: context.colors.pageTop),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// One row of the expanded dial.
class _AdminFabAction extends StatelessWidget {
  const _AdminFabAction({
    required this.label,
    required this.icon,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 8.h),
      child: FloatingActionButton.extended(
        heroTag: 'admin-fab-$label',
        onPressed: busy ? null : onPressed,
        backgroundColor: context.colors.pageTop,
        foregroundColor: context.colors.accent,
        icon: busy
            ? SizedBox(
                width: 16.r,
                height: 16.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.colors.accent,
                ),
              )
            : Icon(icon, size: 18.r),
        label: Text(
          label.toUpperCase(),
          style: MyFonts.caps10.copyWith(color: context.colors.accent),
        ),
      ),
    );
  }
}
