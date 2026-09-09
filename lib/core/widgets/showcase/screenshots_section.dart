import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../features/portfolio_content/domain/entities/shot_background.dart';
import '../../../features/portfolio_content/domain/entities/showcase_panel.dart';
import '../../localization/lang_keys.dart';
import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import 'screenshots_strip.dart';

/// The "Screenshots" media block: a label over a full-size [ScreenshotsStrip].
class ScreenshotsSection extends StatelessWidget {
  const ScreenshotsSection({
    required this.panels,
    required this.background,
    this.playing = true,
    super.key,
  });

  final List<ShowcasePanel> panels;
  final ShotBackground background;

  /// False while the page is covered by another route — stops a looping GIF
  /// screenshot from animating underneath whatever was just pushed on top.
  final bool playing;

  /// A fixed strip height regardless of page width — these are individual
  /// panels meant to be browsed by scrolling sideways, not one element that
  /// should grow with the page.
  static const double _panelHeight = 440;

  @override
  Widget build(BuildContext context) {
    if (panels.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.translate(LangKeys.mediaLayerScreenshots).toUpperCase(),
          style: MyFonts.caps10.copyWith(color: context.colors.onNavyFaint),
        ),
        SizedBox(height: 12.h),
        ScreenshotsStrip(
          panels: panels,
          background: background,
          height: _panelHeight.h,
          playing: playing,
        ),
      ],
    );
  }
}
