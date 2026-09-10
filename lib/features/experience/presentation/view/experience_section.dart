import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/styles/fonts/my_fonts.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/site_content_extensions.dart';
import '../../../portfolio_content/domain/entities/section_definition.dart';
import '../../../../core/widgets/common/content_container.dart';
import '../../../../core/widgets/motion/motion_durations.dart';
import '../../../../core/widgets/motion/reveal_on_scroll.dart';
import '../../../../core/widgets/section/section_divider_header.dart';
import '../../../../di/di.dart';
import '../../../portfolio_content/domain/entities/work_history_entry.dart';
import '../../../portfolio_content/presentation/view_data/timeline_row_data.dart';
import '../view_model/experience_actions.dart';
import '../view_model/experience_states.dart';
import '../view_model/experience_view_model.dart';
import '../widgets/experience_timeline_row.dart';

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExperienceViewModelCubit>(
      create: (_) =>
          getIt<ExperienceViewModelCubit>()..doAction(LoadWorkHistory()),
      child: const _ExperienceBody(),
    );
  }
}

class _ExperienceBody extends StatelessWidget {
  const _ExperienceBody();

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

class _ExperienceTimeline extends StatelessWidget {
  const _ExperienceTimeline({required this.entries});

  final List<WorkHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _ExperienceMessage(
        text: context.translate(LangKeys.experienceEmpty),
      );
    }

    final cubit = context.read<ExperienceViewModelCubit>();
    // Translated once here so the view-data layer stays free of BuildContext.
    final presentLabel = context.translate(LangKeys.experiencePresent);

    return Column(
      children: <Widget>[
        for (var i = 0; i < entries.length; i++)
          RevealOnScroll(
            delay: Motion.stagger * i,
            child: ExperienceTimelineRow(
              key: ValueKey<String>(entries[i].id),
              data: TimelineRowData.fromWorkHistory(
                entries[i],
                i,
                context.isArabic,
                presentLabel,
              ),
              onEdit: () {},
              onDelete: () => cubit.doAction(DeleteWorkHistory(entries[i].id)),
            ),
          ),
      ],
    );
  }
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
