import 'package:flutter/material.dart';

import '../../../di/di.dart';
import '../../../features/portfolio_content/domain/entities/portfolio_bundle.dart';
import '../../../features/portfolio_content/domain/repositories/portfolio_repo.dart';
import '../../common/data_result.dart';
import '../../localization/lang_keys.dart';
import '../../routes/route_names.dart';
import '../../utils/extension/context_extensions.dart';
import '../../utils/extension/navigation_extensions.dart';
import '../common/app_snack_bar.dart';
import 'admin_confirm_dialog.dart';
import 'admin_gate.dart';
import 'admin_hover_icon_button.dart';
import 'admin_svg_icons.dart';

/// Discards local edits and reloads the last published content from
/// Firestore, undoing whatever the admin changed locally since the last sync.
///
/// Content used to live in hardcoded Dart seeds, and this button restored
/// them; it now restores the published bundle instead — see
/// [PortfolioRepo.resetToPublished] for why that has to always re-fetch
/// rather than reuse the version-match check the startup sync uses.
class AdminResetButton extends StatelessWidget {
  const AdminResetButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminGate(
      child: AdminHoverIconButton(
        svg: AdminSvgIcons.reset,
        tooltip: context.translate(LangKeys.adminResetPublished),
        color: context.colors.accent,
        iconSize: 19,
        onPressed: () => _confirmAndReset(context),
      ),
    );
  }

  Future<void> _confirmAndReset(BuildContext context) async {
    final confirmed = await AdminConfirmDialog.show(
      context,
      title: context.translate(LangKeys.adminResetPublished),
      body: context.translate(LangKeys.adminResetPublishedConfirm),
      confirmLabel: context.translate(LangKeys.adminResetPublished),
    );
    if (!confirmed || !context.mounted) return;

    final result = await getIt<PortfolioRepo>().resetToPublished();
    if (!context.mounted) return;

    switch (result) {
      case Success<PortfolioBundle>():
        AppSnackBar.show(
          context,
          context.translate(LangKeys.adminSaved),
          kind: SnackKind.success,
        );
        // Rebuilding the root route recreates every section cubit, which
        // re-reads storage.
        context.replaceNamed<void>(RouteNames.home);
      case Fail<PortfolioBundle>(:final message):
        AppSnackBar.show(context, message, kind: SnackKind.error);
    }
  }
}
