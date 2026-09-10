import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/extension/site_content_extensions.dart';
import '../../../portfolio_content/domain/entities/section_definition.dart';
import '../../../../core/utils/responsive/app_breakpoints.dart';
import '../../../../core/widgets/common/content_container.dart';
import '../../../../core/widgets/motion/motion_durations.dart';
import '../../../../core/widgets/motion/reveal_on_scroll.dart';
import '../../../../core/widgets/section/section_divider_header.dart';
import '../widgets/about_photo_card.dart';
import '../widgets/about_statements.dart';
import '../widgets/skills_block.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionDividerHeader(
          title: context.sectionTitle(BuiltInSectionIds.about),
        ),
        ContentContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Not wrapped in a reveal: the statements wipe themselves in, and
              // on the reference the photo is simply present when the page
              // arrives. Fading the pair would double the text's animation and
              // give the photo one it should not have.
              if (context.isWide)
                const _WideAboutColumns()
              else
                const _NarrowAboutColumns(),
              SizedBox(height: 80.h),
              const RevealOnScroll(delay: Motion.stagger, child: SkillsBlock()),
            ],
          ),
        ),
        SizedBox(height: 96.h),
      ],
    );
  }
}

class _WideAboutColumns extends StatelessWidget {
  const _WideAboutColumns();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Expanded(flex: 6, child: AboutStatements()),
        SizedBox(width: 48.w),
        Expanded(
          flex: 4,
          child: Align(
            alignment: AlignmentDirectional.topEnd,
            child: AboutPhotoCard(size: context.isDesktop ? 340.w : 280.w),
          ),
        ),
      ],
    );
  }
}

class _NarrowAboutColumns extends StatelessWidget {
  const _NarrowAboutColumns();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(child: AboutPhotoCard(size: 240.w)),
        SizedBox(height: 40.h),
        const AboutStatements(),
      ],
    );
  }
}
