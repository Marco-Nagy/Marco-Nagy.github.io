import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routes/route_names.dart';
import '../../../../core/styles/fonts/my_fonts.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/site_content_extensions.dart';
import '../../../../core/utils/extension/navigation_extensions.dart';
import '../../../../core/widgets/motion/motion_durations.dart';
import 'splash_metrics.dart';

/// The Flutter half of the launch sequence.
///
/// The native window (Android `launch_background`) and the web `index.html`
/// loader both cover the period *before* Flutter can paint — a widget cannot,
/// by definition. This screen picks up from them: it repeats the same mark on
/// the same ground so the handoff is invisible, then parts two panels to reveal
/// the site.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late final AnimationController _hold = AnimationController(
    vsync: this,
    duration: Motion.introFill,
  );

  late final AnimationController _part = AnimationController(
    vsync: this,
    duration: Motion.introPart,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    if (!mounted) return;

    // Reduce-motion users go straight through rather than being held behind a
    // decorative sequence.
    if (!Motion.reducedMotion(context)) {
      // On web the HTML loader in index.html already showed the mark and held
      // for the download. Holding again here reads as a second splash screen,
      // so this side contributes only the reveal.
      if (!kIsWeb) {
        await _hold.forward();
        if (!mounted) return;
      }
      await _part.forward();
      if (!mounted) return;
    }

    context.replaceNamed<void>(RouteNames.home);
  }

  @override
  void dispose() {
    _hold.dispose();
    _part.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.pageTop,
      body: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[_hold, _part]),
        builder: (context, _) {
          final part = Motion.curtainCurve.transform(_part.value);
          return LayoutBuilder(
            builder: (context, constraints) {
              final half = constraints.maxHeight / 2;
              final travel = half * part;

              return Stack(
                children: <Widget>[
                  // Panels meet at the centre and slide out of view.
                  Positioned(
                    top: -travel,
                    left: 0,
                    right: 0,
                    height: half,
                    child: ColoredBox(color: colors.pageTop),
                  ),
                  Positioned(
                    bottom: -travel,
                    left: 0,
                    right: 0,
                    height: half,
                    child: ColoredBox(color: colors.pageTop),
                  ),
                  // Web never draws the mark: index.html is still showing its
                  // own, and two marks with different fonts and measures would
                  // visibly jump as one fades into the other.
                  if (part == 0 && !kIsWeb)
                    Positioned.fill(
                      child: Center(child: _SplashMark(fill: _hold.value)),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Name over a filling rule.
///
/// Mobile and desktop only. The native launch window is a flat colour with no
/// mark of its own, so this is the first and only one the visitor sees; on web
/// `index.html` owns that job instead.
class _SplashMark extends StatelessWidget {
  const _SplashMark({required this.fill});

  final double fill;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final site = context.site;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Opacity(
          opacity: (fill / SplashMetrics.nameFadeFraction).clamp(0.0, 1.0),
          child: Text(
            context.localized(site.fullNameEn, site.fullNameAr),
            textAlign: TextAlign.center,
            style: MyFonts.display36.copyWith(color: colors.onNavy),
          ),
        ),
        SizedBox(height: SplashMetrics.markGap.h),
        SizedBox(
          width: SplashMetrics.ruleWidth.w,
          height: SplashMetrics.ruleHeight.h,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: ColoredBox(
                  color: colors.onNavy.withValues(
                    alpha: SplashMetrics.ruleTrackOpacity,
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: FractionallySizedBox(
                  // Fills from empty: nothing showed a bar before this.
                  widthFactor: fill.clamp(0.0, 1.0),
                  heightFactor: 1,
                  child: ColoredBox(color: colors.accent),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
