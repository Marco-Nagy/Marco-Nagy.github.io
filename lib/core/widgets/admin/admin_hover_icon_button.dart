import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import '../motion/motion_durations.dart';

/// One admin icon button: an SVG glyph inside a circular hit target that
/// fills, rings and lifts slightly on hover — the same hover language as
/// `PillButton`, scaled down to icon size, so every debug-only icon control
/// (edit, delete, reset) reads as one consistent premium chrome instead of
/// bare Material icon buttons each animating differently.
///
/// The chip carries a small permanent dark scrim rather than starting fully
/// transparent: these controls sit on top of whatever content they're
/// annotating — a project's own accent-colored hover reveal included — and a
/// bare stroke icon in [color] can vanish against a busy backdrop it wasn't
/// designed to sit on. The scrim guarantees contrast everywhere; [color]
/// itself is saved for the hover state, where it reads as an intentional
/// reveal rather than the icon's only source of contrast.
class AdminHoverIconButton extends StatefulWidget {
  const AdminHoverIconButton({
    required this.svg,
    required this.tooltip,
    required this.color,
    required this.onPressed,
    this.iconSize = 18,
    this.hitSize = 34,
    super.key,
  });

  final String svg;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;
  final double iconSize;
  final double hitSize;

  @override
  State<AdminHoverIconButton> createState() => _AdminHoverIconButtonState();
}

class _AdminHoverIconButtonState extends State<AdminHoverIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Tooltip(
      message: widget.tooltip,
      // The default Material tooltip is a plain light box — jarring against
      // this site's dark chrome. A small dark pill with the same accent as
      // the icon's hover state reads as part of the same design system.
      decoration: BoxDecoration(
        color: colors.pageTop.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: colors.onNavy.withValues(alpha: 0.12)),
      ),
      textStyle: MyFonts.caps10.copyWith(color: colors.onNavy),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          // Isolates this circle's own layer. Without it, a list of these
          // buttons re-laying-out (an item added/removed/reordered next to
          // them) can leave stale painted pixels behind on Flutter web's
          // CanvasKit renderer — the "trail of ghost icons" artifact this
          // was added to fix. A solid ring on hover (no blurred BoxShadow)
          // keeps that same renderer from needing an offscreen blur layer at
          // all, which was the more likely source of it.
          child: RepaintBoundary(
            child: AnimatedContainer(
              duration: Motion.quick,
              curve: Curves.easeOut,
              width: widget.hitSize.w,
              height: widget.hitSize.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _hovered
                    ? widget.color.withValues(alpha: 0.18)
                    : colors.pageTop.withValues(alpha: 0.55),
                border: Border.all(
                  color: _hovered
                      ? widget.color.withValues(alpha: 0.6)
                      : colors.onNavy.withValues(alpha: 0.14),
                  width: _hovered ? 1.6 : 1.2,
                ),
              ),
              child: Center(
                child: AnimatedScale(
                  duration: Motion.quick,
                  curve: Curves.easeOut,
                  scale: _hovered ? 1.12 : 1,
                  child: SvgPicture.string(
                    widget.svg,
                    width: widget.iconSize.r,
                    height: widget.iconSize.r,
                    colorFilter: ColorFilter.mode(
                      _hovered
                          ? widget.color
                          : colors.onNavy.withValues(alpha: 0.92),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
