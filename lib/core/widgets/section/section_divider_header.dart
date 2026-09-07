import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import '../../utils/responsive/app_breakpoints.dart';
import '../motion/block_reveal_text.dart';
import '../motion/motion_durations.dart';
import '../motion/reveal_on_scroll.dart';
import 'wavy_ring_painter.dart';

/// The header every non-hero page opens with: a wavy-texture ring badge with
/// the section name centered inside, and a down-chevron inviting scroll.
class SectionDividerHeader extends StatefulWidget {
  const SectionDividerHeader({required this.title, super.key});

  final String title;

  @override
  State<SectionDividerHeader> createState() => _SectionDividerHeaderState();
}

class _SectionDividerHeaderState extends State<SectionDividerHeader>
    with SingleTickerProviderStateMixin {
  /// Bobs the chevron up and down on a loop, inviting the visitor to scroll —
  /// a static arrow reads as decoration rather than a cue.
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: Motion.chevronBobPeriod,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reducedMotion(context)) {
      _bob.stop();
      return;
    }
    if (!_bob.isAnimating) _bob.repeat(reverse: true);
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diameter = switch (context.screenKind) {
      ScreenKind.desktop => 340.0.w,
      ScreenKind.tablet => 300.0.w,
      ScreenKind.mobile => 250.0.w,
    };

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 56.h),
      child: Column(
        children: <Widget>[
          SizedBox.square(
            dimension: diameter,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                // Ring and chevron fade; the name wipes. Revealing the three
                // together would fade the title twice over.
                Positioned.fill(
                  child: RevealOnScroll(
                    child: CustomPaint(
                      painter: WavyRingPainter(color: context.colors.accent),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: diameter * 0.16),
                  child: FittedBox(
                    child: BlockRevealText(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: MyFonts.display48.copyWith(
                        color: context.colors.onNavy,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          RevealOnScroll(
            child: AnimatedBuilder(
              animation: _bob,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 32.r,
                color: context.colors.accent,
              ),
              builder: (context, child) => Transform.translate(
                offset: Offset(0, Motion.chevronBobDistance * _bob.value),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
