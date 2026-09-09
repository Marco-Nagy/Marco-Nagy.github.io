import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../features/portfolio_content/domain/entities/shot_background.dart';
import '../../../features/portfolio_content/domain/entities/showcase_panel.dart';
import '../../localization/lang_keys.dart';
import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import 'feature_graphic_card.dart';

/// The "Feature Graphic" media block: a label over one or more wide banners.
///
/// Builds its own horizontal list of [FeatureGraphicCard]s directly — no
/// shared "showcase panel" strip underneath. [ScreenshotsSection],
/// [VideoSection] and [GifSection] each do the same with their own card, so
/// nothing here has to know those kinds exist, and nothing there has to know
/// a feature graphic does.
class FeatureGraphicSection extends StatelessWidget {
  const FeatureGraphicSection({
    required this.panels,
    required this.background,
    required this.pageWidth,
    super.key,
  });

  /// Normally exactly one panel — a second is rendered as a second banner
  /// stacked in the same strip rather than silently dropped.
  final List<ShowcasePanel> panels;

  final ShotBackground background;

  /// The page's own content width, which the banner's height is derived from.
  final double pageWidth;

  @override
  Widget build(BuildContext context) {
    if (panels.isEmpty) return const SizedBox.shrink();

    final height = (pageWidth / FeatureGraphicCard.aspectRatio).clamp(
      200.h,
      420.h,
    );
    final cardWidth = height * FeatureGraphicCard.aspectRatio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.translate(LangKeys.mediaLayerFeatureGraphic).toUpperCase(),
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
                return FeatureGraphicCard(
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
