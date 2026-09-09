import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/styles/fonts/my_fonts.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/widgets/motion/motion_durations.dart';
import '../../../../core/widgets/motion/reveal_scope.dart';

/// Vertical "SCROLL DOWN" label pinned to the hero's trailing edge, with a
/// line that slides down on a loop.
///
/// The loop is paused once the hero scrolls away: the hero stays mounted for
/// the whole session, so an unconditional `repeat()` would keep producing
/// frames for an off-screen 1.4px line forever.
class ScrollDownLabel extends StatefulWidget {
  const ScrollDownLabel({this.onTap, super.key});

  /// Makes the cue act on what it invites. Decorative when null.
  final VoidCallback? onTap;

  @override
  State<ScrollDownLabel> createState() => _ScrollDownLabelState();
}

class _ScrollDownLabelState extends State<ScrollDownLabel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  RevealTicker? _ticker;
  bool _visible = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Reduce-motion users get a static line rather than a slower loop.
    if (Motion.reducedMotion(context)) {
      _controller.stop();
      return;
    }

    final ticker = RevealScope.maybeOf(context);
    if (!identical(ticker, _ticker)) {
      _ticker?.removeListener(_syncWithVisibility);
      _ticker = ticker;
      _ticker?.addListener(_syncWithVisibility);
    }
    if (!_controller.isAnimating) _controller.repeat();
  }

  void _syncWithVisibility() {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final bottom = box.localToGlobal(Offset.zero).dy + box.size.height;
    final nowVisible = bottom > 0;
    if (nowVisible == _visible) return;

    _visible = nowVisible;
    if (nowVisible) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _ticker?.removeListener(_syncWithVisibility);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final label = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        RotatedBox(
          quarterTurns: 3,
          child: Text(
            context.translate(LangKeys.heroScrollDown).toUpperCase(),
            style: MyFonts.caps10.copyWith(color: colors.onNavyFaint),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: 1.4,
          height: 56.h,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (rect) {
                  final t = _controller.value;
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      colors.transparent,
                      colors.accent,
                      colors.transparent,
                    ],
                    stops: <double>[
                      (t - 0.25).clamp(0.0, 1.0),
                      t.clamp(0.0, 1.0),
                      (t + 0.25).clamp(0.0, 1.0),
                    ],
                  ).createShader(rect);
                },
                child: ColoredBox(color: colors.onNavy),
              );
            },
          ),
        ),
      ],
    );

    if (widget.onTap == null) return label;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: label,
      ),
    );
  }
}
