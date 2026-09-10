import 'package:flutter/material.dart';

import '../../localization/lang_keys.dart';
import '../../utils/extension/context_extensions.dart';
import '../common/pill_button.dart';
import 'admin_gate.dart';

/// Toggles a section between its normal display and drag-to-reorder mode.
///
/// Placed beside the section's [AdminAddButton] rather than inside a header:
/// header layouts differ across sections, but every one of them already has
/// an add button in a known spot, so pairing with it needs no per-section
/// layout decision.
class AdminReorderButton extends StatelessWidget {
  const AdminReorderButton({
    required this.reordering,
    required this.onToggle,
    super.key,
  });

  final bool reordering;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AdminGate(
      child: PillButton(
        label: context.translate(
          reordering ? LangKeys.adminReorderDone : LangKeys.adminReorder,
        ),
        variant: PillButtonVariant.outlined,
        icon: reordering ? Icons.check_rounded : Icons.swap_vert_rounded,
        showArrow: false,
        dense: true,
        onPressed: onToggle,
      ),
    );
  }
}
