import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/styles/fonts/my_fonts.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/site_content_extensions.dart';
import '../../../portfolio_content/domain/entities/section_definition.dart';
import '../../../../core/widgets/admin/admin_add_button.dart';
import '../../../../core/widgets/admin/admin_confirm_dialog.dart';
import '../../../../core/widgets/admin/admin_reorder_button.dart';
import '../../../../core/widgets/admin/admin_reorderable_list.dart';
import '../../../../core/widgets/common/app_snack_bar.dart';
import '../../../../core/widgets/common/content_container.dart';
import '../../../../core/widgets/motion/motion_durations.dart';
import '../../../../core/widgets/motion/reveal_on_scroll.dart';
import '../../../../core/widgets/section/section_divider_header.dart';
import '../../../portfolio_content/domain/entities/work_history_entry.dart';
import '../../../portfolio_content/presentation/view_data/timeline_row_data.dart';
import '../view_model/experience_actions.dart';
import '../view_model/experience_states.dart';
import '../view_model/experience_view_model.dart';
import '../widgets/experience_timeline_row.dart';
import '../widgets/work_history_form_screen.dart';

// Consumes the ExperienceViewModelCubit provided above MaterialApp (in
// MarcoPortfolioApp) rather than owning one — About's years-of-experience
// stat reads the same cubit and needs it loaded regardless of whether this
// section has been scrolled into view yet.
class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final title = context.sectionTitle(BuiltInSectionIds.experience);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionDividerHeader(title: title),
        ContentContainer(
          child: BlocBuilder<ExperienceViewModelCubit, ExperienceState>(
            builder: (context, state) => switch (state) {
              ExperienceInitial() || ExperienceLoading() => Padding(
                padding: EdgeInsets.symmetric(vertical: 64.h),
                child: Center(
                  child: CircularProgressIndicator(
                    color: context.colors.accent,
                  ),
                ),
              ),
              ExperienceError() => _ExperienceMessage(text: state.message),
              ExperienceSuccess() => _ExperienceTimeline(
                entries: state.entries,
              ),
            },
          ),
        ),
        SizedBox(height: 96.h),
      ],
    );
  }
}

class _ExperienceTimeline extends StatefulWidget {
  const _ExperienceTimeline({required this.entries});

  final List<WorkHistoryEntry> entries;

  @override
  State<_ExperienceTimeline> createState() => _ExperienceTimelineState();
}

class _ExperienceTimelineState extends State<_ExperienceTimeline> {
  bool _reordering = false;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExperienceViewModelCubit>();

    if (widget.entries.isEmpty) {
      return Column(
        children: <Widget>[
          _ExperienceMessage(text: context.translate(LangKeys.experienceEmpty)),
          _AddWorkHistoryButton(cubit: cubit),
        ],
      );
    }

    if (_reordering) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: AdminReorderButton(
              reordering: true,
              onToggle: () => setState(() => _reordering = false),
            ),
          ),
          AdminReorderableList<WorkHistoryEntry>(
            items: <AdminReorderableItem<WorkHistoryEntry>>[
              for (final entry in widget.entries)
                AdminReorderableItem<WorkHistoryEntry>(
                  id: entry.id,
                  value: entry,
                  title: entry.company,
                  subtitle: context.localized(entry.role, entry.roleAr),
                ),
            ],
            onReorder: (reordered) =>
                cubit.doAction(ReorderWorkHistory(reordered)),
          ),
        ],
      );
    }

    // Translated once here so the view-data layer stays free of BuildContext.
    final presentLabel = context.translate(LangKeys.experiencePresent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: AdminReorderButton(
            reordering: false,
            onToggle: () => setState(() => _reordering = true),
          ),
        ),
        for (var i = 0; i < widget.entries.length; i++)
          RevealOnScroll(
            delay: Motion.stagger * i,
            child: ExperienceTimelineRow(
              key: ValueKey<String>(widget.entries[i].id),
              data: TimelineRowData.fromWorkHistory(
                widget.entries[i],
                i,
                context.isArabic,
                presentLabel,
              ),
              onEdit: () => _editWorkHistory(context, cubit, widget.entries[i]),
              onDelete: () =>
                  _deleteWorkHistory(context, cubit, widget.entries[i].id),
            ),
          ),
        SizedBox(height: 24.h),
        _AddWorkHistoryButton(cubit: cubit),
      ],
    );
  }
}

class _AddWorkHistoryButton extends StatelessWidget {
  const _AddWorkHistoryButton({required this.cubit});

  final ExperienceViewModelCubit cubit;

  @override
  Widget build(BuildContext context) {
    return AdminAddButton(
      label: context.translate(LangKeys.adminAdd),
      onPressed: () => _editWorkHistory(context, cubit, null),
    );
  }
}

/// The cubit is passed in rather than read after the await: the row that owns
/// this context can be rebuilt away while the form is open.
Future<void> _editWorkHistory(
  BuildContext context,
  ExperienceViewModelCubit cubit,
  WorkHistoryEntry? entry,
) async {
  final built = await WorkHistoryFormScreen.open(context, entry: entry);
  if (built == null || !context.mounted) return;

  cubit.doAction(SaveWorkHistory(built));
  AppSnackBar.show(
    context,
    context.translate(LangKeys.adminSaved),
    kind: SnackKind.success,
  );
}

Future<void> _deleteWorkHistory(
  BuildContext context,
  ExperienceViewModelCubit cubit,
  String id,
) async {
  final confirmed = await AdminConfirmDialog.show(context);
  if (!confirmed || !context.mounted) return;

  cubit.doAction(DeleteWorkHistory(id));
  AppSnackBar.show(
    context,
    context.translate(LangKeys.adminDeleted),
    kind: SnackKind.success,
  );
}

class _ExperienceMessage extends StatelessWidget {
  const _ExperienceMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 64.h),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: MyFonts.regular16.copyWith(color: context.colors.onNavyMuted),
        ),
      ),
    );
  }
}
