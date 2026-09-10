import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';

/// One row of an [AdminReorderableList].
class AdminReorderableItem<T> {
  const AdminReorderableItem({
    required this.id,
    required this.value,
    required this.title,
    this.subtitle,
  });

  /// Stable identity for the drag animation — [ReorderableListView] keys each
  /// child by this, not by its position, so a row keeps its own place in the
  /// animation across a drag instead of two rows swapping content mid-flight.
  final String id;

  final T value;
  final String title;
  final String? subtitle;
}

/// A drag-to-reorder list for admin content — the body a section swaps to
/// while its reorder toggle is active.
///
/// Deliberately not [ReorderableListView]'s own drag handles: those render at
/// the trailing edge, which collides with the edit/delete affordances this
/// content already carries elsewhere. A dedicated handle on the leading edge
/// keeps drag and the rest of the row's actions from fighting over the same
/// gesture.
///
/// Calls [onReorder] with the whole list in its new order after every drag —
/// there is no separate Save step, matching [SectionsManagerScreen]'s
/// visibility switch: leaving reorder mode has nothing left pending.
/// Renumbering `order` to match list position is the repository's job, not
/// this widget's.
class AdminReorderableList<T> extends StatelessWidget {
  const AdminReorderableList({
    required this.items,
    required this.onReorder,
    super.key,
  });

  final List<AdminReorderableItem<T>> items;
  final void Function(List<T> reordered) onReorder;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      // Nested inside the page's own SingleChildScrollView — this list must
      // not carry a scroll position of its own.
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: items.length,
      // Not the deprecated `onReorder`: `onReorderItem` hands back `newIndex`
      // already adjusted for the removed item, so no off-by-one correction is
      // needed here.
      onReorderItem: (oldIndex, newIndex) {
        final next = List<AdminReorderableItem<T>>.of(items);
        next.insert(newIndex, next.removeAt(oldIndex));
        onReorder(<T>[for (final item in next) item.value]);
      },
      itemBuilder: (context, index) => _ReorderRow(
        key: ValueKey<String>(items[index].id),
        index: index,
        item: items[index],
      ),
    );
  }
}

class _ReorderRow extends StatelessWidget {
  const _ReorderRow({
    required super.key,
    required this.index,
    required this.item,
  });

  final int index;
  final AdminReorderableItem<Object?> item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final subtitle = item.subtitle?.trim();

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsetsDirectional.only(end: 12.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        children: <Widget>[
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: EdgeInsets.all(12.r),
              child: Icon(
                Icons.drag_indicator_rounded,
                color: colors.onNavyFaint,
                size: 20.r,
              ),
            ),
          ),
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
                if (subtitle != null && subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MyFonts.regular12.copyWith(
                      color: colors.onNavyFaint,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
    );
  }
}
