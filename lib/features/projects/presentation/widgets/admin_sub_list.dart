import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/styles/fonts/my_fonts.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/widgets/admin/admin_item_actions.dart';
import '../../../../core/widgets/admin/admin_svg_icons.dart';

/// One row of an [AdminSubList].
class AdminSubListItem {
  const AdminSubListItem({
    required this.title,
    required this.subtitle,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
}

/// A list of child records edited inside its parent's form — the panels of a
/// project, the shots of a panel.
///
/// Inline rather than a sheet of its own: project → panel → shot is already
/// three modals deep, and a fourth whose entire content is a list would be a
/// screen that exists only to be passed through.
class AdminSubList extends StatelessWidget {
  const AdminSubList({
    required this.label,
    required this.addLabel,
    required this.items,
    required this.onAdd,
    this.emptyLabel,
    super.key,
  });

  final String label;
  final String addLabel;
  final List<AdminSubListItem> items;
  final VoidCallback onAdd;

  /// Shown in place of the rows when there are none. Says what the absence
  /// means — "inherits the project background" reads very differently from an
  /// empty box.
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: MyFonts.caps12.copyWith(color: colors.onNavyMuted),
          ),
          SizedBox(height: 8.h),
          if (items.isEmpty && emptyLabel != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                emptyLabel!,
                style: MyFonts.regular12.copyWith(color: colors.onNavyFaint),
              ),
            ),
          for (final item in items) _Row(item: item),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: onAdd,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
              ),
              icon: SvgPicture.string(
                AdminSvgIcons.add,
                width: 16.r,
                height: 16.r,
                colorFilter: ColorFilter.mode(colors.accent, BlendMode.srcIn),
              ),
              label: Text(
                addLabel,
                style: MyFonts.regular14.copyWith(color: colors.accent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item});

  final AdminSubListItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsetsDirectional.only(start: 12.w, end: 4.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MyFonts.semi16.copyWith(color: colors.onNavy),
                ),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MyFonts.regular12.copyWith(color: colors.onNavyFaint),
                ),
              ],
            ),
          ),
          AdminItemActions(
            onEdit: item.onEdit,
            onDelete: item.onDelete,
            compact: true,
          ),
        ],
      ),
    );
  }
}
