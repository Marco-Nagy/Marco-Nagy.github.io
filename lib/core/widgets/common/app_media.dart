import 'package:flutter/material.dart';

import '../../../features/portfolio_content/domain/entities/image_ref.dart';
import '../../../features/portfolio_content/domain/entities/media_ref.dart';
import '../../utils/youtube_thumbnail.dart';
import 'app_image.dart';
import 'video_embed_view.dart';
import 'video_file_view.dart';

/// Renders a [MediaRef] whatever it holds — a still, a GIF, a screen recording
/// or a YouTube walkthrough — degrading to [fallback] rather than throwing.
/// Same contract as [AppImage], which it wraps for every non-video case.
class AppMedia extends StatelessWidget {
  const AppMedia({
    required this.media,
    required this.fallback,
    this.playing = true,
    this.allowPlatformView = true,
    this.preload = false,
    this.controls = false,
    this.onPlayingChanged,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    super.key,
  });

  final MediaRef media;
  final Widget fallback;

  /// Whether the media should be running. Owned by the parent — a hovered
  /// project row, an opened detail panel — so that no player decides for itself
  /// whether it is worth the visitor's bandwidth.
  final bool playing;

  /// Must be false on any surface that transforms its child. The YouTube player
  /// is a platform view: it ignores rotation and clipping and would draw itself
  /// over the layout, so it falls back to its poster there instead.
  final bool allowPlatformView;

  /// Renders the media at rest instead of nothing when [playing] is false —
  /// a video opens far enough to show its first frame, and a GIF is drawn.
  /// Admin forms set this so a pasted URL turns into a visible thumbnail.
  final bool preload;

  /// Draws a transport bar — play/pause, scrubber, elapsed clock, mute —
  /// over a [MediaKind.videoFile]. Ignored by every other kind: a still has
  /// nothing to transport, and a YouTube embed brings its own player chrome.
  final bool controls;

  /// Paired with [controls]: reports the viewer pressing play or pause, so
  /// the parent that owns [playing] can update it.
  final ValueChanged<bool>? onPlayingChanged;

  final BoxFit fit;
  final double? width;
  final double? height;

  /// A YouTube ref with no poster of its own still gets one: the site hosts a
  /// still per video, and it costs a plain image request rather than a player.
  ImageRef get _posterRef {
    if (!media.image.isEmpty || media.kind != MediaKind.videoEmbed) {
      return media.image;
    }
    final url = YoutubeThumbnail.forUrl(media.videoUrl);
    return url == null ? media.image : ImageRef.network(url);
  }

  Widget _poster() => AppImage(
    image: _posterRef,
    fallback: fallback,
    fit: fit,
    width: width,
    height: height,
  );

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) return fallback;

    return switch (media.kind) {
      // Flutter animates a GIF for as long as it is mounted and gives no way to
      // pause it, so leaving the tree is the only stop button there is. Project
      // rows keep their hover reveal mounted at zero opacity, which would
      // otherwise leave every project's GIF looping unseen — and hand the
      // visitor a mid-loop frame at the moment they finally hover.
      MediaKind.image =>
        media.isAnimatedImage && !playing && !preload ? fallback : _poster(),

      MediaKind.videoFile => VideoFileView(
        media: media,
        playing: playing,
        preload: preload,
        controls: controls,
        onPlayingChanged: onPlayingChanged,
        poster: _poster(),
        fit: fit,
      ),

      MediaKind.videoEmbed =>
        allowPlatformView
            ? VideoEmbedView(media: media, poster: _poster())
            : _poster(),
    };
  }
}
