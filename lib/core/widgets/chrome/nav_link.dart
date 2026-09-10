import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../features/portfolio_content/domain/entities/section_definition.dart';
import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import '../../routes/route_names.dart';
import '../../utils/extension/navigation_extensions.dart';
import '../motion/motion_durations.dart';

/// A top-nav link. Each section is its own screen, so this replaces the route
/// rather than stacking one — clicking through the nav must not build an
/// unbounded back stack.
class NavLink extends StatefulWidget {
  const NavLink({
    required this.label,
    required this.section,
    required this.isActive,
    super.key,
  });

  final String label;

  /// The whole definition rather than just an id: a custom section resolves to
  /// a different route shape, and only [SectionDefinition] knows which it is.
  final SectionDefinition section;
  final bool isActive;

  @override
  State<NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final highlighted = widget.isActive || _hovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.isActive
            ? null
            : () => context.replaceNamed<void>(
                RouteNames.forSection(widget.section),
              ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.label,
                style: MyFonts.semi16.copyWith(
                  color: highlighted ? colors.onNavy : colors.onNavyMuted,
                ),
              ),
              SizedBox(height: 5.h),
              // Grows from nothing on hover and stays for the section in view.
              AnimatedContainer(
                duration: Motion.quick,
                curve: Curves.easeOut,
                height: 2,
                width: highlighted ? 20.w : 0,
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
