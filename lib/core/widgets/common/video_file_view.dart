import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../features/portfolio_content/domain/entities/media_ref.dart';

/// Plays a [MediaKind.videoFile] ref, showing [poster] until it is ready — and
/// forever if it never becomes ready.
///
/// The controller is built on the first frame [playing] is true, never in
/// `initState`: the projects page builds one of these per row, and opening a
/// decoder for every project the moment the page loads is a cost nobody asked
/// for. Once built it lives as long as the widget and merely pauses, because
/// tearing it down on hover-out would make hover-in buffer from scratch.
class VideoFileView extends StatefulWidget {
  const VideoFileView({
    required this.media,
    required this.playing,
    required this.poster,
    this.fit = BoxFit.cover,
    this.preload = false,
    super.key,
  });

  final MediaRef media;
  final bool playing;

  /// Opens the file even when [playing] is false, so it comes to rest on its
  /// first frame. That frame is the only thumbnail a local video has — nothing
  /// else can produce a still without decoding the file — so an admin form
  /// pasting a URL sets this to see what it got.
  final bool preload;

  /// Drawn before the first frame is decoded, and whenever playback is
  /// impossible. Never a black box.
  final Widget poster;

  final BoxFit fit;

  @override
  State<VideoFileView> createState() => _VideoFileViewState();
}

class _VideoFileViewState extends State<VideoFileView> {
  VideoPlayerController? _controller;

  /// Latched after a failed initialise so a broken URL is attempted once, not
  /// on every hover.
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(VideoFileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.media.videoUrl != widget.media.videoUrl) {
      _controller?.dispose();
      _controller = null;
      _failed = false;
    }
    _sync();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _sync() async {
    if (_failed || !widget.media.hasPlayableVideo) return;

    if (_controller == null) {
      // Stay lazy: nothing is allocated until the parent asks to run — or asks
      // for the first frame, which needs the file open just the same.
      if (!widget.playing && !widget.preload) return;
      await _create();
    }

    final controller = _controller;
    if (controller == null || !mounted || _failed) return;

    // Two fast hovers can re-enter here while _create() is still awaiting
    // initialize(): _controller is assigned before that await, so this call
    // would sail past the branch above. play() would then set isPlaying and
    // return without ever reaching the platform, leaving a video that looks
    // dead. The call that owns _create() applies the state once it lands.
    if (!controller.value.isInitialized) return;

    if (widget.playing && widget.media.autoplay) {
      try {
        await controller.play();
      } on Object {
        // Browsers refuse to autoplay with sound. An unmuted ref rests on its
        // poster instead of looking broken.
      }
    } else {
      await controller.pause();
    }
  }

  Future<void> _create() async {
    final url = widget.media.videoUrl.trim();
    final controller = url.startsWith('http')
        ? VideoPlayerController.networkUrl(Uri.parse(url))
        : VideoPlayerController.asset(url);
    _controller = controller;

    try {
      // Order matters: both setters need the platform texture that
      // initialize() creates.
      await controller.initialize();
      await controller.setLooping(widget.media.loop);
      await controller.setVolume(widget.media.muted ? 0 : 1);
    } on Object {
      _failed = true;
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_failed || controller == null || !controller.value.isInitialized) {
      return widget.poster;
    }

    // A decoded video can still report an empty size for a frame or two, and
    // FittedBox cannot scale from nothing.
    final size = controller.value.size;
    if (size.isEmpty) return widget.poster;

    return ClipRect(
      child: FittedBox(
        fit: widget.fit,
        clipBehavior: Clip.hardEdge,
        child: SizedBox.fromSize(size: size, child: VideoPlayer(controller)),
      ),
    );
  }
}
