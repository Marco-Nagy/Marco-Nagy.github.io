import 'package:flutter/material.dart';

import '../common/pill_button.dart';
import 'admin_gate.dart';
import 'admin_svg_icons.dart';

/// The debug-only "add" affordance that sits inline at the end of a list.
///
/// Inline rather than a [Scaffold] FAB: the button has to dispatch into the
/// list's own cubit, and a page-level FAB would sit outside that provider —
/// and be ambiguous on a page that shows more than one editable list.
class AdminAddButton extends StatelessWidget {
  const AdminAddButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AdminGate(
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: PillButton(
          label: label,
          variant: PillButtonVariant.outlined,
          svgIcon: AdminSvgIcons.add,
          showArrow: false,
          dense: true,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
