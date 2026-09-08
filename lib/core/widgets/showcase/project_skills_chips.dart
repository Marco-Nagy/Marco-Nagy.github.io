import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../common/skill_chip.dart';
import '../../localization/lang_keys.dart';
import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';

/// The three labelled chip groups on a project's detail page — skills,
/// technologies, tools, in that order.
///
/// Skills first: they say what he can do for the visitor. Tools last: they are
/// the least differentiating group, since everyone uses Git. A group with no
/// items is dropped entirely rather than rendered as an empty heading.
class ProjectSkillsChips extends StatelessWidget {
  const ProjectSkillsChips({
    required this.skills,
    required this.technologies,
    required this.tools,
    super.key,
  });

  final List<String> skills;
  final List<String> technologies;
  final List<String> tools;

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty && technologies.isEmpty && tools.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (skills.isNotEmpty)
          _Group(labelKey: LangKeys.projectSkills, items: skills),
        if (technologies.isNotEmpty)
          _Group(labelKey: LangKeys.projectTechnologies, items: technologies),
        if (tools.isNotEmpty)
          _Group(labelKey: LangKeys.projectTools, items: tools),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.labelKey, required this.items});

  final String labelKey;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.translate(labelKey).toUpperCase(),
            style: MyFonts.caps10.copyWith(color: colors.onNavyFaint),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            // Reuses the About section's own chip so a "Bloc" pill looks the
            // same whether it is read on the skills block or here.
            children: <Widget>[
              for (final item in items) SkillChip(label: item),
            ],
          ),
        ],
      ),
    );
  }
}
