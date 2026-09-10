import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/styles/fonts/my_fonts.dart';
import '../../../../core/utils/date_parsing.dart';
import '../../../../core/utils/experience_duration.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/site_content_extensions.dart';
import '../../../../core/utils/responsive/app_breakpoints.dart';
import '../../../../core/widgets/motion/block_reveal_text.dart';
import '../../../portfolio_content/presentation/view_data/statement_data.dart';

/// The large, lighter statement sentences built from the CV summary.
class AboutStatements extends StatelessWidget {
  const AboutStatements({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final data = StatementData.fromSiteContent(context.site, context.isArabic);
    final statementStyle = context.isDesktop
        ? MyFonts.statement26
        : MyFonts.statement20;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        BlockRevealText(
          data.lead,
          style: MyFonts.bold28.copyWith(color: colors.accent),
        ),
        SizedBox(height: 28.h),
        // Every statement shares one timeline: the reference wipes a whole
        // paragraph open at once, so no delay is passed here.
        for (final statement in data.statements)
          Padding(
            padding: EdgeInsets.only(bottom: 22.h),
            child: BlockRevealText(
              statement,
              style: statementStyle.copyWith(color: colors.onNavy),
            ),
          ),
        SizedBox(height: 8.h),
        const _LocationLine(),
        const _ExperienceLine(),
      ],
    );
  }
}

class _LocationLine extends StatelessWidget {
  const _LocationLine();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final site = context.site;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.place_outlined, size: 18.r, color: colors.accent),
        SizedBox(width: 8.w),
        Text(
          '${context.translate(LangKeys.aboutLocationLabel)} '
          '${context.localized(site.locationEn, site.locationAr)}',
          style: MyFonts.regular14.copyWith(color: colors.onNavyMuted),
        ),
      ],
    );
  }
}

/// Total experience, computed from the earliest work-history [startDate] to
/// today — distinct from the free-text "N+ years" that may already appear in
/// the admin-written summary/statements copy above. Renders nothing when no
/// entry has a parseable start date.
class _ExperienceLine extends StatelessWidget {
  const _ExperienceLine();

  @override
  Widget build(BuildContext context) {
    final earliestStart = context.workHistory
        .map((entry) => parseMonthYear(entry.startDate))
        .whereType<DateTime>()
        .fold<DateTime?>(
          null,
          (earliest, date) =>
              earliest == null || date.isBefore(earliest) ? date : earliest,
        );
    if (earliestStart == null) return const SizedBox.shrink();

    final duration = ExperienceDuration.between(earliestStart, DateTime.now());
    if (duration.isZero) return const SizedBox.shrink();

    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.work_outline_rounded, size: 18.r, color: colors.accent),
          SizedBox(width: 8.w),
          Text(
            '${context.translate(LangKeys.aboutExperienceLabel)}: '
            '${duration.format(isArabic: context.isArabic)}',
            style: MyFonts.regular14.copyWith(color: colors.accent),
          ),
        ],
      ),
    );
  }
}
