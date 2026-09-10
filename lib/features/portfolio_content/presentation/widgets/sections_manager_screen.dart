import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/styles/fonts/my_fonts.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/widgets/admin/admin_hover_icon_button.dart';
import '../../../../core/widgets/admin/admin_list_screen.dart';
import '../../../../core/widgets/admin/admin_reorder_button.dart';
import '../../../../core/widgets/admin/admin_reorderable_list.dart';
import '../../../../core/widgets/admin/admin_svg_icons.dart';
import '../../../../core/widgets/common/app_snack_bar.dart';
import '../../domain/entities/section_definition.dart';
import '../view_model/sections_actions.dart';
import '../view_model/sections_states.dart';
import '../view_model/sections_view_model.dart';
import 'section_form_sheet.dart';

/// Renames sections, toggles which appear in the nav, and reorders them.
///
/// Lists *all* sections, not `visible` ones: hiding a section here is the only
/// way to get it back, so a hidden one that disappeared from this screen too
/// would be unreachable.
///
/// No add and no delete. Built-in sections each map to a dedicated screen and
/// cannot be created or removed from content; custom sections are their own
/// feature.
class SectionsManagerScreen extends StatefulWidget {
  const SectionsManagerScreen({super.key});

  static Future<void> open(BuildContext context) =>
      AdminListScreen.open(context, const SectionsManagerScreen());

  @override
  State<SectionsManagerScreen> createState() => _SectionsManagerScreenState();
}

class _SectionsManagerScreenState extends State<SectionsManagerScreen> {
  bool _reordering = false;

  @override
  Widget build(BuildContext context) {
    return AdminListScreen(
      title: context.translate(LangKeys.adminSections),
      body: BlocBuilder<SectionsCubit, SectionsState>(
        builder: (context, _) {
          final cubit = context.read<SectionsCubit>();
          final sections = cubit.sections.toList()
            ..sort((a, b) => a.order.compareTo(b.order));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Text(
                  context.translate(LangKeys.sectionsHiddenHint),
                  style: MyFonts.regular12.copyWith(
                    color: context.colors.onNavyFaint,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: AdminReorderButton(
                  reordering: _reordering,
                  onToggle: () => setState(() => _reordering = !_reordering),
                ),
              ),
              if (_reordering)
                AdminReorderableList<SectionDefinition>(
                  items: <AdminReorderableItem<SectionDefinition>>[
                    for (final section in sections)
                      AdminReorderableItem<SectionDefinition>(
                        id: section.id,
                        value: section,
                        title: _titleOf(context, section),
                        subtitle: '${section.id} · ${section.type.name}',
                      ),
                  ],
                  onReorder: (reordered) =>
                      cubit.doAction(SaveAllSections(reordered)),
                )
              else
                for (final section in sections)
                  _SectionRow(
                    key: ValueKey<String>(section.id),
                    section: section,
                    cubit: cubit,
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({required this.section, required this.cubit, super.key});

  final SectionDefinition section;
  final SectionsCubit cubit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final title = _titleOf(context, section);

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
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MyFonts.semi16.copyWith(
                    color: section.visible ? colors.onNavy : colors.onNavyFaint,
                  ),
                ),
                Text(
                  '${section.id} · ${section.type.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MyFonts.regular12.copyWith(color: colors.onNavyFaint),
                ),
              ],
            ),
          ),
          Switch(
            value: section.visible,
            // Saved on the spot rather than behind a Save button: one toggle
            // is the whole edit, and this screen has nothing else pending.
            onChanged: (visible) =>
                cubit.doAction(SaveSection(section.copyWith(visible: visible))),
            activeThumbColor: colors.pageTop,
            activeTrackColor: colors.accent,
            inactiveTrackColor: colors.surfaceHigh,
          ),
          AdminHoverIconButton(
            svg: AdminSvgIcons.edit,
            tooltip: context.translate(LangKeys.adminEdit),
            color: colors.accent,
            iconSize: 15,
            onPressed: () => _rename(context, cubit, section),
          ),
          SizedBox(width: 6.w),
        ],
      ),
    );
  }
}

/// A section with no title still needs a label to click, so it falls back to
/// its id rather than rendering as a blank bar.
String _titleOf(BuildContext context, SectionDefinition section) {
  final title = context.localized(section.titleEn, section.titleAr);
  return title.trim().isEmpty ? section.id : title;
}

Future<void> _rename(
  BuildContext context,
  SectionsCubit cubit,
  SectionDefinition section,
) async {
  final built = await SectionFormSheet.open(context, section: section);
  if (built == null || !context.mounted) return;

  cubit.doAction(SaveSection(built));
  AppSnackBar.show(
    context,
    context.translate(LangKeys.adminSaved),
    kind: SnackKind.success,
  );
}
