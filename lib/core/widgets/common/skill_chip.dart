import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';

/// A single skill/tool/technology pill. Shared by the About section's skills
/// block and a project's skills · technologies · tools groups, so the same
/// name reads identically wherever it appears on the site.
class SkillChip extends StatelessWidget {
  const SkillChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: colors.divider),
      ),
      child: Text(
        label,
        style: MyFonts.regular14.copyWith(color: colors.onNavyMuted),
      ),
    );
  }
}
