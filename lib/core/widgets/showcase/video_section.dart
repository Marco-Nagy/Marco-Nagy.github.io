import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../features/portfolio_content/domain/entities/project_video.dart';
import '../../../features/portfolio_content/domain/entities/shot_background.dart';
import '../../localization/lang_keys.dart';
import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import 'video_card.dart';

/// The "Video" media block: a label over a row of [VideoCard]s that shrinks to
/// fit the page, and scrolls sideways only once shrinking would make the
/// videos too small to watch.
///
/// Builds its own strip directly, using its own card — see
/// [FeatureGraphicSection]'s doc comment for why these four sections stay
/// independent rather than sharing one "showcase panel" strip underneath.
/// Playback itself (the transport bar, the play badge) lives inside
/// [VideoCard]; this widget only lays the strip out.
class VideoSection extends StatelessWidget {
  const VideoSection({
    required this.videos,
    required this.background,
    super.key,
  });

  final List<ProjectVideo> videos;
  final ShotBackground background;

  /// The height a row is drawn at when it fits — big enough to actually watch,
  /// and the same regardless of page width, since these are individual cards
  /// rather than one element that should grow with the page. Each card's width
  /// still follows its own [ProjectVideo.aspectRatio], so a portrait recording
  /// and a landscape one sit side by side at their own natural shapes rather
  /// than in one shared box.
  static const double _cardHeight = 440;

  /// The row shrinks no further than this. Past it, making everything fit
  /// costs more than scrolling does: two landscape videos squeezed into one
  /// page width are a pair of thumbnails, not something anyone can watch.
  static const double _minCardHeight = 220;

  /// Cards of two different widths butted together read as one torn image; a
  /// gap is what makes the row parse as separate videos.
  static const double _gap = 16;

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.translate(LangKeys.mediaLayerVideo).toUpperCase(),
          style: MyFonts.caps10.copyWith(color: context.colors.onNavyFaint),
        ),
        SizedBox(height: 12.h),
        LayoutBuilder(
          builder: (context, constraints) {
            final gap = _gap.w;
            final gaps = gap * (videos.length - 1);

            // Every card is drawn at one shared height, so the row's width is
            // that height times the sum of the ratios. Inverting that gives
            // the height at which the row exactly fills the page — no search,
            // no measure pass.
            final totalRatio = videos.fold<double>(
              0,
              (sum, video) => sum + video.aspectRatio,
            );
            final fitted = (constraints.maxWidth - gaps) / totalRatio;

            // Never grow past the nominal height: a single portrait clip on a
            // wide page would otherwise stretch to the full page height.
            final height = math.min(
              _cardHeight.h,
              math.max(_minCardHeight.h, fitted),
            );

            return SizedBox(
              height: height,
              // Still a ListView: once the floor above stops the shrinking,
              // the row is wider than the page again and has to scroll. It
              // simply does not move when everything fits.
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: videos.length,
                separatorBuilder: (context, index) => SizedBox(width: gap),
                itemBuilder: (context, index) {
                  final video = videos[index];
                  return VideoCard(
                    video: video,
                    background: video.backgroundOverride ?? background,
                    caption: context.localized(
                      video.captionEn,
                      video.captionAr,
                    ),
                    subtitle: context.localized(
                      video.subtitleEn,
                      video.subtitleAr,
                    ),
                    width: height * video.aspectRatio,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
