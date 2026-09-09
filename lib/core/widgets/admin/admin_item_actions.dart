import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../localization/lang_keys.dart';
import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import 'admin_gate.dart';
import 'admin_hover_icon_button.dart';
import 'admin_svg_icons.dart';

/// Per-item edit/delete icons shown beside content in debug builds only.
class AdminItemActions extends StatelessWidget {
  const AdminItemActions({
    required this.onEdit,
    required this.onDelete,
    this.compact = false,
    super.key,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = compact ? 15.0 : 17.0;

    return AdminGate(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AdminHoverIconButton(
            svg: AdminSvgIcons.edit,
            tooltip: context.translate(LangKeys.adminEdit),
            color: colors.accent,
            iconSize: size,
            onPressed: onEdit,
          ),
          SizedBox(width: 6.w),
          AdminHoverIconButton(
            svg: AdminSvgIcons.delete,
            tooltip: context.translate(LangKeys.adminDelete),
            color: colors.danger,
            iconSize: size,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

/// Small "DEBUG MODE" chip so it's obvious why admin controls are visible.
class AdminBadge extends StatelessWidget {
  const AdminBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AdminGate(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: colors.accent.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(color: colors.accent.withValues(alpha: 0.5)),
        ),
        child: Text(
          context.translate(LangKeys.adminBadge),
          style: MyFonts.caps10.copyWith(color: colors.accent),
        ),
      ),
    );
  }
}
