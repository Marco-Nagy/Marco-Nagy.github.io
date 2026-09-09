import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../features/portfolio_content/domain/entities/project_video.dart';
import '../../../features/portfolio_content/domain/entities/shot_background.dart';
import '../../../features/portfolio_content/domain/entities/showcase_panel.dart';
import 'feature_graphic_section.dart';
import 'gif_section.dart';
import 'screenshots_section.dart';
import 'video_section.dart';

/// A project's media, laid out as up to four labelled blocks — feature
/// graphic, device-framed screenshots, video, GIF — in that order: identity
/// first, then detail, then the two motion formats, matching the site's media
/// rules.
///
/// Groups panels by [ProjectMediaLayer] and hands each group to that layer's
/// own section widget; [videos] arrives already its own list, since a video
/// is never a panel — see [ProjectVideo]. This is the only place that decides
/// *which* sections appear and in what order; what a section looks like and
/// how it behaves lives entirely inside [FeatureGraphicSection],
/// [ScreenshotsSection], [VideoSection] and [GifSection] — four separate
/// widgets rather than one shared widget branching on media kind, so a
/// layer's rendering can change without touching, or risking, the other
/// three. A layer with no panels in it is skipped outright: a heading over
/// nothing reads as a missing asset, not as "there is no video for this one".
class ProjectMediaSections extends StatelessWidget {
  const ProjectMediaSections({
    required this.panels,
    required this.videos,
    required this.background,
    required this.stripWidth,
    this.playing = true,
    super.key,
  });

  final List<ShowcasePanel> panels;
  final List<ProjectVideo> videos;

  /// The project default. A panel's or video's own override still wins.
  final ShotBackground background;

  /// The page's own content width — only [FeatureGraphicSection] reads it.
  final double stripWidth;

  /// False while the page these sections sit on is covered by another route
  /// — stops a looping GIF screenshot from decoding frames nobody can see
  /// underneath whatever was just pushed on top. Video/feature-graphic cards
  /// already own their play state locally (tap to play), so only the GIF
  /// layers need this passed through.
  final bool playing;

  @override
  Widget build(BuildContext context) {
    final featureGraphics = <ShowcasePanel>[];
    final screenshots = <ShowcasePanel>[];
    final gifs = <ShowcasePanel>[];

    for (final panel in panels) {
      switch (panel.mediaLayer) {
        case ProjectMediaLayer.featureGraphic:
          featureGraphics.add(panel);
        case ProjectMediaLayer.screenshots:
          screenshots.add(panel);
        case ProjectMediaLayer.gif:
          gifs.add(panel);
      }
    }

    // Built once each; a section renders nothing when its own list is empty,
    // so the gap logic below only has to ask "is there anything here" rather
    // than repeat each section's own emptiness rule.
    final sections = <Widget>[
      if (featureGraphics.isNotEmpty)
        FeatureGraphicSection(
          panels: featureGraphics,
          background: background,
          pageWidth: stripWidth,
        ),
      if (screenshots.isNotEmpty)
        ScreenshotsSection(
          panels: screenshots,
          background: background,
          playing: playing,
        ),
      if (videos.isNotEmpty)
        VideoSection(videos: videos, background: background),
      if (gifs.isNotEmpty)
        GifSection(panels: gifs, background: background, playing: playing),
    ];
    if (sections.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var i = 0; i < sections.length; i++) ...<Widget>[
          if (i > 0) SizedBox(height: 32.h),
          sections[i],
        ],
      ],
    );
  }
}
