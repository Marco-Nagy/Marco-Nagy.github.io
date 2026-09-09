import 'package:flutter/material.dart';

import '../../../di/di.dart';
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

/// Restores the seeded content, undoing local edits.
///
/// Seeding runs only on first launch, so without this a visitor who deletes
/// every project in debug has no way back short of clearing site data.
class AdminResetButton extends StatelessWidget {
  const AdminResetButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminGate(
      child: AdminHoverIconButton(
        svg: AdminSvgIcons.reset,
        tooltip: context.translate(LangKeys.adminResetSeed),
        color: context.colors.accent,
        iconSize: 19,
        onPressed: () => _confirmAndReset(context),
      ),
    );
  }

  Future<void> _confirmAndReset(BuildContext context) async {
    final confirmed = await AdminConfirmDialog.show(
      context,
      title: context.translate(LangKeys.adminResetSeed),
      body: context.translate(LangKeys.adminResetSeedConfirm),
      confirmLabel: context.translate(LangKeys.adminResetSeed),
    );
    if (!confirmed || !context.mounted) return;

    final result = await getIt<PortfolioRepo>().resetToSeed();
    if (!context.mounted) return;

    switch (result) {
      case Success<void>():
        AppSnackBar.show(
          context,
          context.translate(LangKeys.adminSaved),
          kind: SnackKind.success,
        );
        // Rebuilding the root route recreates every section cubit, which
        // re-reads storage.
        context.replaceNamed<void>(RouteNames.home);
      case Fail<void>(:final message):
        AppSnackBar.show(context, message, kind: SnackKind.error);
    }
  }
}
