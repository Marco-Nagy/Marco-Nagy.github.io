import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../../features/portfolio_content/domain/entities/media_ref.dart';
import '../../utils/media_url.dart';
import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';

/// Plays a [MediaKind.videoFile] ref, showing [poster] until it is ready — and
/// forever if it never becomes ready.
///
/// The controller is built on the first frame [playing] is true, never in
/// `initState`: the projects page builds one of these per row, and opening a
/// decoder for every project the moment the page loads is a cost nobody asked
/// for. Once built it lives as long as the widget and merely pauses, because
/// tearing it down on hover-out would make hover-in buffer from scratch.
///
/// [controls] draws the transport bar here rather than in the card above,
/// because this is the only widget holding the [VideoPlayerController] — a
/// scrubber, an elapsed clock and a volume toggle all need it, and handing the
/// controller upwards would put its lifetime in two places at once.
class VideoFileView extends StatefulWidget {
  const VideoFileView({
    required this.media,
    required this.playing,
    required this.poster,
    this.fit = BoxFit.cover,
    this.preload = false,
    this.controls = false,
    this.onPlayingChanged,
    super.key,
  });

  final MediaRef media;
  final bool playing;

  /// Opens the file even when [playing] is false, so it comes to rest on its
  /// first frame. That frame is the only thumbnail a local video has — nothing
  /// else can produce a still without decoding the file — so an admin form
  /// pasting a URL sets this to see what it got.
  final bool preload;

  /// Play/pause, a scrubbable progress bar, an elapsed clock and a mute
  /// toggle, plus tap-anywhere-to-toggle across the whole surface. Off by
  /// default: a hover preview inside a project row is not something to
  /// operate, and a transport bar over a thumbnail is only clutter there.
  final bool controls;

  /// Reports the viewer working the controls. [playing] stays the parent's to
  /// own — this only asks for it to change, so there is still exactly one
  /// source of truth for whether the video should be running.
  final ValueChanged<bool>? onPlayingChanged;

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

  /// Why playback is impossible, when it is. Swallowing this made a dead URL
  /// and a slow one look identical — both just sat on the poster — so the
  /// reason is now printed, and drawn over the poster in debug builds. Debug
  /// only because the admin surface that pastes these URLs is itself debug
  /// only: a visitor gets the poster and nothing else, as before.
  String? _error;

  /// The viewer's own sound choice, which outranks [MediaRef.muted] once they
  /// make one. Null until then, so the ref's stored default still applies.
  bool? _mutedOverride;

  bool get _muted => _mutedOverride ?? widget.media.muted;

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
      _error = null;
      _mutedOverride = null;
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

    // `autoplay` governs starting *unasked* — on hover, on reveal. Once there
    // are controls on screen, `playing` is a button the viewer just pressed,
    // and a play button that does nothing is worse than no play button.
    if (widget.playing && (widget.controls || widget.media.autoplay)) {
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

    // Checked before anything is constructed. `VideoPlayerController.asset`
    // hands the string to the web engine's asset manager, which parses it as
    // a URI — so junk in this field surfaces from inside the platform player
    // as an "Illegal scheme character" with no mention of the video, the
    // field, or the text that caused it.
    final rejection = MediaUrl.rejectionFor(url);
    if (rejection != null) {
      _failed = true;
      _error = rejection;
      debugPrint('VideoFileView: $rejection');
      debugPrint('  source: $url');
      if (mounted) setState(() {});
      return;
    }

    // An absolute URL streams; anything else is a key into the bundle. Decided
    // on the parsed scheme rather than a `startsWith('http')` prefix test,
    // which reads a path that merely begins with those letters as a URL.
    final uri = Uri.parse(url);
    final controller = uri.hasScheme
        ? VideoPlayerController.networkUrl(uri)
        : VideoPlayerController.asset(url);
    _controller = controller;

    try {
      // Order matters: both setters need the platform texture that
      // initialize() creates.
      await controller.initialize();
      await controller.setLooping(widget.media.loop);
      await controller.setVolume(_muted ? 0 : 1);
      // Decoding can fail long after a successful open — a truncated file, a
      // codec the browser will not take. That arrives on the value, never as
      // a throw, so initialize()'s try block cannot see it.
      controller.addListener(_watchValue);
    } on Object catch (error, stackTrace) {
      _failed = true;
      _error = '$error';
      debugPrint('VideoFileView: cannot open $url');
      debugPrint('  $error');
      debugPrintStack(stackTrace: stackTrace, maxFrames: 6);
    }

    if (mounted) setState(() {});
  }

  void _watchValue() {
    final controller = _controller;
    if (controller == null || !controller.value.hasError) return;

    final description = controller.value.errorDescription ?? 'unknown error';
    if (_error == description) return;

    debugPrint('VideoFileView: playback failed for ${widget.media.videoUrl}');
    debugPrint('  $description');
    if (mounted) setState(() => _error = description);
  }

  void _togglePlay() {
    final report = widget.onPlayingChanged;
    if (report != null) {
      report(!widget.playing);
      return;
    }

    // Uncontrolled fallback: with no parent listening, drive the controller
    // directly so the button still works.
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (widget.playing) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  void _toggleMute() {
    final next = !_muted;
    setState(() => _mutedOverride = next);
    _controller?.setVolume(next ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_failed || controller == null || !controller.value.isInitialized) {
      return _diagnosed(widget.poster);
    }

    // A decoded video can still report an empty size for a frame or two, and
    // FittedBox cannot scale from nothing.
    final size = controller.value.size;
    if (size.isEmpty) return _diagnosed(widget.poster);

    final video = ClipRect(
      child: FittedBox(
        fit: widget.fit,
        clipBehavior: Clip.hardEdge,
        child: SizedBox.fromSize(size: size, child: VideoPlayer(controller)),
      ),
    );

    if (!widget.controls) return _diagnosed(video);

    return VideoControlsOverlay(
      controller: controller,
      playing: widget.playing,
      muted: _muted,
      onTogglePlay: _togglePlay,
      onToggleMute: _toggleMute,
      child: _diagnosed(video),
    );
  }

  /// Stamps the failure reason over [child] in debug builds. Returns [child]
  /// untouched when there is nothing wrong, and always in release.
  Widget _diagnosed(Widget child) {
    final error = _error;
    if (!kDebugMode || error == null) return child;

    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        child,
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: _ErrorBanner(url: widget.media.videoUrl, error: error),
        ),
      ],
    );
  }
}

/// Names the URL as well as the error: nearly every failure here is the URL's
/// fault — a share page instead of a file, a host with no CORS header — and
/// the reason is unreadable without seeing what was actually requested.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.url, required this.error});

  final String url;
  final String error;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.shadow.withValues(alpha: 0.82)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.error_outline_rounded,
                  size: 14.r,
                  color: colors.danger,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    error,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: MyFonts.regular12.copyWith(color: colors.danger),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              url.isEmpty ? '(no url)' : url,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: MyFonts.regular12.copyWith(color: colors.onNavyMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// The transport layer over a playing video: tap-to-toggle, a centre play
/// badge while paused, and a bottom bar carrying play/pause, a scrubbable
/// progress bar, the elapsed clock and a mute toggle.
///
/// Only [VideoFileView] builds one, since only it holds a controller — public
/// so its own doc can be read from the card layer that turns `controls` on.
class VideoControlsOverlay extends StatelessWidget {
  const VideoControlsOverlay({
    required this.controller,
    required this.playing,
    required this.muted,
    required this.onTogglePlay,
    required this.onToggleMute,
    required this.child,
    super.key,
  });

  final VideoPlayerController controller;
  final bool playing;
  final bool muted;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleMute;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        child,

        // Tap anywhere to toggle. Sits below the bar in the stack, so the
        // bar's buttons and the scrubber win the hit test rather than having
        // their taps read as "toggle playback".
        Positioned.fill(
          child: GestureDetector(
            onTap: onTogglePlay,
            behavior: HitTestBehavior.opaque,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Center(
                // Only while paused: the badge exists to invite a tap away
                // from a still frame, and would sit over the video itself
                // once there is something to watch.
                child: playing
                    ? const SizedBox.shrink()
                    : Container(
                        width: 44.r,
                        height: 44.r,
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: colors.shadow.withValues(alpha: 0.35),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          size: 26.r,
                          color: colors.pageTop,
                        ),
                      ),
              ),
            ),
          ),
        ),

        // The bar alone rebuilds on every position tick — the controller is
        // itself a ValueNotifier<VideoPlayerValue>, so listening here keeps
        // the video texture above out of a 60-per-second rebuild.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: controller,
            builder: (context, value, _) => _TransportBar(
              controller: controller,
              value: value,
              playing: playing,
              muted: muted,
              onTogglePlay: onTogglePlay,
              onToggleMute: onToggleMute,
            ),
          ),
        ),
      ],
    );
  }
}

class _TransportBar extends StatelessWidget {
  const _TransportBar({
    required this.controller,
    required this.value,
    required this.playing,
    required this.muted,
    required this.onTogglePlay,
    required this.onToggleMute,
  });

  final VideoPlayerController controller;
  final VideoPlayerValue value;
  final bool playing;
  final bool muted;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleMute;

  static String _clock(Duration value) {
    final minutes = value.inMinutes;
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      // A scrim, not a solid bar: the video keeps showing through, and light
      // controls stay readable even over a pale frame.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: <Color>[
            colors.shadow.withValues(alpha: 0.72),
            colors.transparent,
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.w, 18.h, 8.w, 6.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Full width, on its own row: a scrubber squeezed between buttons
            // is a scrubber nobody can hit accurately.
            SizedBox(
              height: 14.h,
              child: VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                padding: EdgeInsets.symmetric(vertical: 5.h),
                colors: VideoProgressColors(
                  playedColor: colors.accent,
                  bufferedColor: colors.onNavy.withValues(alpha: 0.35),
                  backgroundColor: colors.onNavy.withValues(alpha: 0.18),
                ),
              ),
            ),
            Row(
              children: <Widget>[
                _BarButton(
                  icon: playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  onTap: onTogglePlay,
                ),
                SizedBox(width: 4.w),
                Text(
                  '${_clock(value.position)} / ${_clock(value.duration)}',
                  style: MyFonts.regular12.copyWith(color: colors.onNavy),
                ),
                const Spacer(),
                _BarButton(
                  icon: muted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  onTap: onToggleMute,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A plain gesture target rather than an [InkWell]: this bar is drawn over a
/// video inside whatever card mounted it, and an ink splash asserts a
/// [Material] ancestor that a showcase card is not obliged to have.
class _BarButton extends StatelessWidget {
  const _BarButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: EdgeInsets.all(6.r),
          child: Icon(icon, size: 20.r, color: context.colors.onNavy),
        ),
      ),
    );
  }
}
