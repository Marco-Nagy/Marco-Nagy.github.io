import 'package:flutter/material.dart';

import '../../../features/portfolio_content/domain/entities/media_ref.dart';
import '../../../features/portfolio_content/domain/entities/media_shot.dart';
import '../../../features/portfolio_content/domain/entities/project_video.dart';
import '../../../features/portfolio_content/domain/entities/shot_background.dart';
import '../../utils/extension/context_extensions.dart';
import '../../utils/hex_color.dart';
import '../common/app_media.dart';
import '../common/safe_asset_image.dart';
import 'device_frame.dart';
import 'panel_caption.dart';
import 'shot_background_view.dart';
import 'tappable_video.dart';

/// One video card: background, the recording, caption on top, tap to play.
///
/// Shape follows [ProjectVideo.frame] rather than a fixed ratio: `none` is a
/// bare landscape rectangle filling the card edge to edge, same as this
/// widget always drew; `laptop`/`iphone`/`samsungS` instead draw the
/// recording inside [DeviceFrame]'s bezel, the same art [ScreenshotCard]
/// uses, sized to that bezel's own aspect ratio.
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

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  /// Starts paused rather than autoplaying on arrival: a visitor scrolling
  /// past should not have sound/motion start without asking.
  bool _playing = false;

  MediaRef get _media => widget.video.media;

  bool get _isVideoFile => _media.kind == MediaKind.videoFile;

  bool get _isFramed => widget.video.frame != DeviceFrameType.none;

  Widget _bare() {
    // A YouTube embed already owns its own tap-to-start badge and ignores
    // `playing` outright (see VideoEmbedView) — wrapping it in TappableVideo
    // too would stack a second, disconnected badge on top of it. Only a
    // video file responds to `playing`, so only that case gets the outer tap
    // chrome. Not inside any rotated/clipped ancestor here (see VideoSection),
    // so the platform view an embed needs is safe to allow.
    final media = AppMedia(
      media: _media,
      fit: BoxFit.cover,
      allowPlatformView: true,
      playing: _playing,
      fallback: const AssetPlaceholder(
        icon: Icons.play_circle_outline_rounded,
      ),
    );

    return _isVideoFile
        ? TappableVideo(
            playing: _playing,
            onTap: () => setState(() => _playing = !_playing),
            child: media,
          )
        : media;
  }

  Widget _framed() {
    // DeviceFrame is a bezel, not a flat surface — it always renders its own
    // AppMedia with allowPlatformView false (see its own doc comment), so a
    // YouTube embed shown inside one rests on its poster; only a video file
    // actually plays there, same restriction ScreenshotCard already lives
    // with for a screen recording inside a frame.
    return TappableVideo(
      playing: _playing,
      onTap: () => setState(() => _playing = !_playing),
      child: DeviceFrame(
        image: _media,
        frame: widget.video.frame,
        width: widget.width,
        playing: _playing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final panelWidth = widget.width;

    return RepaintBoundary(
      child: SizedBox(
        width: panelWidth,
        child: AspectRatio(
          aspectRatio: widget.video.aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ShotBackgroundView(background: widget.background),
              _isFramed ? _framed() : _bare(),
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
    );
  }
}
