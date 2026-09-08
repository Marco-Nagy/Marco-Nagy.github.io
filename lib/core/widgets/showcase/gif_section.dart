import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../features/portfolio_content/domain/entities/shot_background.dart';
import '../../../features/portfolio_content/domain/entities/showcase_panel.dart';
import '../../localization/lang_keys.dart';
import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import 'gif_card.dart';

/// The "GIF" media block: a label over a horizontally-scrolled row of
/// [GifCard]s.
///
/// Builds its own strip directly, using its own card — see
/// [FeatureGraphicSection]'s doc comment for why these four sections stay
/// independent rather than sharing one "showcase panel" strip underneath.
class GifSection extends StatelessWidget {
  const GifSection({required this.panels, required this.background, super.key});

  final List<ShowcasePanel> panels;
  final ShotBackground background;

  /// A fixed card height regardless of page width — these are individual
  /// cards meant to be browsed by scrolling sideways, not one element that
  /// should grow with the page.
  static const double _cardHeight = 440;

  @override
  Widget build(BuildContext context) {
    if (panels.isEmpty) return const SizedBox.shrink();

    final height = _cardHeight.h;
    final cardWidth = height * GifCard.aspectRatio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.translate(LangKeys.mediaLayerGif).toUpperCase(),
          style: MyFonts.caps10.copyWith(color: context.colors.onNavyFaint),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: panels.length,
              itemBuilder: (context, index) {
                final panel = panels[index];
                return GifCard(
                  panel: panel,
                  background: panel.backgroundOverride ?? background,
                  caption: context.localized(panel.captionEn, panel.captionAr),
                  subtitle: context.localized(
                    panel.subtitleEn,
                    panel.subtitleAr,
                  ),
                  width: cardWidth,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
