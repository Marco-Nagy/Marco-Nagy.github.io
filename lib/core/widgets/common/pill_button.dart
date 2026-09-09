import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import '../motion/motion_durations.dart';

enum PillButtonVariant {
  /// Bright accent fill — reserved for the page's single primary CTA.
  filled,

  /// Outlined — nav RESUME button, secondary actions.
  outlined,
}

/// The site's one button shape: a pill with an optional trailing arrow that
/// nudges forward on hover.
class PillButton extends StatefulWidget {
  const PillButton({
    required this.label,
    required this.onPressed,
    this.variant = PillButtonVariant.filled,
    this.showArrow = true,
    this.icon,
    this.svgIcon,
    this.dense = false,
    super.key,
  }) : assert(
         icon == null || svgIcon == null,
         'Pass either icon or svgIcon, not both.',
       );

  final String label;
  final VoidCallback? onPressed;
  final PillButtonVariant variant;
  final bool showArrow;
  final IconData? icon;

  /// A raw SVG string rendered instead of [icon] — for admin-only controls
  /// whose glyphs are hand-drawn rather than Material icons.
  final String? svgIcon;
  final bool dense;

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isFilled = widget.variant == PillButtonVariant.filled;

    final foreground = isFilled
        ? colors.pageTop
        : (_hovered ? colors.accent : colors.onNavy);
    final arrowDirection = context.isRtl ? -1.0 : 1.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        // Without this the padded area hovers and tints but never taps.
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: Motion.quick,
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: widget.dense ? 18.w : 28.w,
            vertical: widget.dense ? 10.h : 16.h,
          ),
          decoration: BoxDecoration(
            gradient: isFilled ? context.gradients.accentCta : null,
            color: isFilled
                ? null
                : (_hovered
                      ? colors.accent.withValues(alpha: 0.10)
                      : colors.transparent),
            borderRadius: BorderRadius.circular(100.r),
            border: Border.all(
              color: isFilled
                  ? colors.transparent
                  : (_hovered ? colors.accent : colors.divider),
              width: 1.2,
            ),
            boxShadow: isFilled && _hovered
                ? <BoxShadow>[
                    BoxShadow(
                      color: colors.accent.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.icon != null) ...<Widget>[
                Icon(widget.icon, size: 18.r, color: foreground),
                SizedBox(width: 8.w),
              ] else if (widget.svgIcon != null) ...<Widget>[
                SvgPicture.string(
                  widget.svgIcon!,
                  width: 16.r,
                  height: 16.r,
                  colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
                ),
                SizedBox(width: 8.w),
              ],
              Text(
                widget.label.toUpperCase(),
                style: (widget.dense ? MyFonts.caps10 : MyFonts.caps12)
                    .copyWith(color: foreground),
              ),
              if (widget.showArrow) ...<Widget>[
                // Growing the gap rather than sliding the arrow over the label
                // is what widens the pill: on the reference site the button
                // stretches and the arrow travels with it, as one move. A
                // slide would send the arrow across a pill of fixed width.
                AnimatedContainer(
                  duration: Motion.quick,
                  curve: Curves.easeOut,
                  width: _hovered ? 24.w : 10.w,
                ),
                // The arrow points along the reading direction, so it mirrors
                // in Arabic.
                Transform.scale(
                  scaleX: arrowDirection,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 16.r,
                    color: foreground,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
