import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../features/portfolio_content/domain/entities/project_video.dart';
import '../../../features/portfolio_content/domain/entities/shot_background.dart';
import '../../localization/lang_keys.dart';
import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import 'video_card.dart';

/// The "Video" media block: a label over a horizontally-scrolled row of
/// [VideoCard]s.
///
/// Builds its own strip directly, using its own card — see
/// [FeatureGraphicSection]'s doc comment for why these four sections stay
/// independent rather than sharing one "showcase panel" strip underneath.
/// Playback itself (poster, tap to start, the play badge) lives inside
/// [VideoCard]; this widget only lays the strip out.
class VideoSection extends StatelessWidget {
  const VideoSection({
    required this.videos,
    required this.background,
    super.key,
  });

  final List<ProjectVideo> videos;
  final ShotBackground background;

  /// A fixed card height regardless of page width — these are individual
  /// cards meant to be browsed by scrolling sideways, not one element that
  /// should grow with the page. Each card's own width still follows its own
  /// [ProjectVideo.aspectRatio], so a portrait recording and a landscape one
  /// sit side by side at their own natural shapes rather than one shared box.
  static const double _cardHeight = 440;

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) return const SizedBox.shrink();

    final height = _cardHeight.h;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.translate(LangKeys.mediaLayerVideo).toUpperCase(),
          style: MyFonts.caps10.copyWith(color: context.colors.onNavyFaint),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return VideoCard(
                  video: video,
                  background: video.backgroundOverride ?? background,
                  caption: context.localized(video.captionEn, video.captionAr),
                  subtitle: context.localized(
                    video.subtitleEn,
                    video.subtitleAr,
                  ),
                  width: height * video.aspectRatio,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
