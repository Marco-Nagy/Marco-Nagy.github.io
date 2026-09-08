import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../features/portfolio_content/domain/entities/media_ref.dart';
import '../../utils/extension/context_extensions.dart';
import '../../utils/url_opener.dart';

/// Plays a [MediaKind.videoEmbed] ref — a YouTube walkthrough.
///
/// Lazier than `VideoFileView` on purpose: the poster stands in until the
/// visitor taps it, and only then is a controller built. Each one is an iframe
/// on web and a WebView on mobile, so a detail view of five panels must not
/// boot five players for someone who opens none.
///
/// Never put this inside a transformed surface. It is a platform view: it
/// ignores rotation and clipping and paints straight over the layout.
/// `AppMedia`'s `allowPlatformView` is the guard against that.
class VideoEmbedView extends StatefulWidget {
  const VideoEmbedView({
    required this.media,
    required this.poster,
    this.aspectRatio = 16 / 9,
    super.key,
  });

  final MediaRef media;

  /// Shown until the visitor asks for playback, and permanently when the URL
  /// holds no video id we can resolve.
  final Widget poster;

  final double aspectRatio;

  @override
  State<VideoEmbedView> createState() => _VideoEmbedViewState();
}

class _VideoEmbedViewState extends State<VideoEmbedView> {
  YoutubePlayerController? _controller;

  /// Null when the URL is not a YouTube link we can parse — a Vimeo link, or a
  /// typo. That case degrades to opening the URL in a new tab.
  String? get _videoId =>
      YoutubePlayerController.convertUrlToId(widget.media.videoUrl.trim());

  @override
  void dispose() {
    // close() is asynchronous and dispose() cannot await; the player is going
    // away either way.
    _controller?.close();
    super.dispose();
  }

  Future<void> _start() async {
    final id = _videoId;
    if (id == null) {
      await UrlOpener.open(widget.media.videoUrl.trim());
      return;
    }

    setState(() {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: id,
        autoPlay: widget.media.autoplay,
        params: YoutubePlayerParams(
          mute: widget.media.muted,
          loop: widget.media.loop,
          showFullscreenButton: true,
          // No YouTube chrome (title, CC, progress bar) over the panel —
          // this is a showcase card, not a YouTube page; [TappableVideo] is
          // the only play/pause control a visitor gets.
          showControls: false,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller != null) {
      // Centered in its own AspectRatio rather than handed straight to a
      // parent that fills tightly (VideoCard's portrait Stack, this admin
      // preview's 9:16 box): a bare YoutubePlayer there gets tight portrait
      // constraints and its internal AspectRatio is overridden, stretching
      // the iframe — the video shrinks into the middle of YouTube's own
      // chrome (title bar, CC, progress bar) blown up to fill the rest.
      // Centering hands it loose constraints instead, so it renders at its
      // true 16:9 shape and simply letterboxes over whatever sits behind it.
      return Center(
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: YoutubePlayer(
            controller: controller,
            aspectRatio: widget.aspectRatio,
          ),
        ),
      );
    }

    return _PosterBadge(
      poster: widget.poster,
      icon: _videoId == null
          ? Icons.open_in_new_rounded
          : Icons.play_arrow_rounded,
      onTap: _start,
    );
  }
}

class _PosterBadge extends StatelessWidget {
  const _PosterBadge({
    required this.poster,
    required this.icon,
    required this.onTap,
  });

  final Widget poster;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            poster,
            // A scrim so the badge stays readable over a bright poster — the
            // same reason ShotBackground carries an overlay.
            Positioned.fill(
              child: ColoredBox(color: colors.pageTop.withValues(alpha: 0.35)),
            ),
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.92),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 30.r, color: colors.pageTop),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
