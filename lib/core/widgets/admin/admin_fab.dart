import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import 'admin_gate.dart';
import 'admin_svg_icons.dart';

/// The debug-only "add item" affordance. Wrapped in [AdminGate], so it simply
/// does not exist in a release build.
class AdminFab extends StatelessWidget {
  const AdminFab({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AdminGate(
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: context.colors.accent,
        foregroundColor: context.colors.pageTop,
        icon: SvgPicture.string(
          AdminSvgIcons.add,
          width: 18.r,
          height: 18.r,
          colorFilter: ColorFilter.mode(
            context.colors.pageTop,
            BlendMode.srcIn,
          ),
        ),
        label: Text(
          label.toUpperCase(),
          style: MyFonts.caps10.copyWith(color: context.colors.pageTop),
        ),
      ),
    );
  }
}
