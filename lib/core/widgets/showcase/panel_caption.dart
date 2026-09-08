import 'package:flutter/material.dart';

import '../../../features/portfolio_content/domain/entities/showcase_panel.dart';
import '../../styles/fonts/my_fonts.dart';

/// Lays a caption/subtitle over a panel at the placement it was given.
///
/// Pure layout — it knows nothing about what is behind it (a device photo, a
/// flat banner, a video), which is why every media card can use the same one
/// without becoming the kind of shared widget that has to branch on media
/// kind to do its job.
class PanelCaption extends StatelessWidget {
  const PanelCaption({
    required this.caption,
    required this.subtitle,
    required this.placement,
    required this.color,
    required this.panelWidth,
    super.key,
  });

  final String caption;
  final String subtitle;
  final CaptionPlacement placement;
  final Color color;
  final double panelWidth;

  AlignmentDirectional get _alignment => switch (placement) {
    CaptionPlacement.top => AlignmentDirectional.topCenter,
    CaptionPlacement.bottom => AlignmentDirectional.bottomCenter,
    CaptionPlacement.start => AlignmentDirectional.centerStart,
    CaptionPlacement.end => AlignmentDirectional.centerEnd,
    CaptionPlacement.none => AlignmentDirectional.topCenter,
  };

  @override
  Widget build(BuildContext context) {
    if (placement == CaptionPlacement.none) return const SizedBox.shrink();
    if (caption.trim().isEmpty && subtitle.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    // Type scales with the panel, not the screen: a panel must look the same
    // whether it renders at 300px in a gallery or full-bleed.
    final titleSize = panelWidth * 0.075;

    return Align(
      alignment: _alignment,
      child: Padding(
        padding: EdgeInsets.all(panelWidth * 0.07),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (caption.trim().isNotEmpty)
              Text(
                caption,
                style: MyFonts.display36.copyWith(
                  fontSize: titleSize,
                  color: color,
                  height: 1.12,
                ),
              ),
            if (subtitle.trim().isNotEmpty) ...<Widget>[
              SizedBox(height: panelWidth * 0.02),
              Text(
                subtitle,
                style: MyFonts.regular16.copyWith(
                  fontSize: titleSize * 0.42,
                  color: color.withValues(alpha: 0.9),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
