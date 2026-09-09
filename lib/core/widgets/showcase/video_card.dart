import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../features/portfolio_content/domain/entities/media_ref.dart';
import '../../../features/portfolio_content/domain/entities/project_video.dart';
import '../../../features/portfolio_content/domain/entities/shot_background.dart';
import '../../utils/extension/context_extensions.dart';
import '../../utils/hex_color.dart';
import '../common/app_media.dart';
import '../common/safe_asset_image.dart';
import 'panel_caption.dart';
import 'shot_background_view.dart';

/// One video card: background, the recording, caption on top, and a transport
/// bar to actually operate it.
///
/// Shape comes from [ProjectVideo.aspectRatio] rather than a fixed ratio, so a
/// portrait screen recording and a landscape walkthrough each render at their
/// own shape. The recording fills the card edge to edge; there is no device
/// bezel here — that is [ScreenshotsSection]'s job, and a bezel around a
/// video only crops it to a shape it was never recorded at.
///
/// The card clips itself to [radius]. The strip above must not do that
/// rounding on its behalf: one clip around a whole scrolling row rounds the
/// *row*, which leaves every card square except whichever two happen to be at
/// the ends, and moves the rounding around as the row scrolls.
class VideoCard extends StatefulWidget {
  const VideoCard({
    required this.video,
    required this.background,
    required this.caption,
    required this.subtitle,
    required this.width,
    super.key,
  });

  final ProjectVideo video;

  /// Already resolved: the video's own override, else the project default.
  final ShotBackground background;

  /// Already resolved into the active language.
  final String caption;
  final String subtitle;

  final double width;

  /// Matches the radius the other media strips round their cards to.
  static const double radius = 20;

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  /// Starts paused rather than autoplaying on arrival: a visitor scrolling
  /// past should not have sound and motion start without asking.
  bool _playing = false;

  MediaRef get _media => widget.video.media;

  @override
  Widget build(BuildContext context) {
    final panelWidth = widget.width;

    return RepaintBoundary(
      child: SizedBox(
        width: panelWidth,
        child: AspectRatio(
          aspectRatio: widget.video.aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(VideoCard.radius.r),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ShotBackgroundView(background: widget.background),

                // A YouTube embed carries its own player chrome and ignores
                // `playing` outright (see VideoEmbedView), so `controls` is
                // left off for it rather than stacking a second, disconnected
                // transport bar over YouTube's own. Nothing here sits inside a
                // rotated or clipped ancestor (see VideoSection), so the
                // platform view an embed needs is safe to allow.
                AppMedia(
                  media: _media,
                  fit: BoxFit.cover,
                  allowPlatformView: true,
                  playing: _playing,
                  // Opens the file far enough to rest on its first frame. A
                  // local video has no other thumbnail — nothing can produce
                  // a still without decoding it — so without this the card
                  // sits on the fallback icon until someone presses play, and
                  // reads as a broken asset. Affordable here because a detail
                  // page holds a handful of videos; the projects list, which
                  // would open one decoder per row, still leaves it off.
                  preload: true,
                  controls: _media.kind == MediaKind.videoFile,
                  onPlayingChanged: (playing) =>
                      setState(() => _playing = playing),
                  fallback: const AssetPlaceholder(
                    icon: Icons.play_circle_outline_rounded,
                  ),
                ),

                PanelCaption(
                  caption: widget.caption,
                  subtitle: widget.subtitle,
                  placement: widget.video.captionPlacement,
                  color: HexColor.parse(
                    widget.video.captionColorHex,
                    context.colors.onNavy,
                  ),
                  panelWidth: panelWidth,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
