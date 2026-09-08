import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/navigation_extensions.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/widgets/admin/admin_choice_field.dart';
import '../../../../core/widgets/admin/admin_form_screen.dart';
import '../../../../core/widgets/admin/media_ref_field.dart';
import '../../../../core/widgets/common/app_media.dart';
import '../../../../core/widgets/common/underline_text_field.dart';
import '../../../portfolio_content/domain/entities/media_ref.dart';
import '../../../portfolio_content/domain/entities/project_video.dart';

/// Add/edit screen for one [ProjectVideo] — a screen recording or a YouTube
/// walkthrough.
///
/// Its own screen rather than a case inside a shared media-item form — video
/// has neither the geometry [ScreenshotFormScreen] tunes nor the flat crop
/// [FeatureGraphicFormScreen] wants; it is a source, a shape and a caption,
/// with a preview an admin can actually operate. The preview runs the same
/// transport bar the detail page's `VideoCard` shows, drawn at the chosen
/// [ProjectVideo.aspectRatio], so the source, the shape and how the clip
/// actually plays can all be checked here before any of it reaches the live
/// site.
class VideoFormScreen extends StatefulWidget {
  const VideoFormScreen({this.video, super.key});

  /// Null when adding.
  final ProjectVideo? video;

  /// Resolves to the built video, or null if dismissed.
  static Future<ProjectVideo?> open(
    BuildContext context, {
    ProjectVideo? video,
  }) {
    return AdminFormScreen.open<ProjectVideo>(
      context,
      VideoFormScreen(video: video),
    );
  }

  @override
  State<VideoFormScreen> createState() => _VideoFormScreenState();
}

class _VideoFormScreenState extends State<VideoFormScreen> {
  /// The three shapes a showcase video actually arrives in — a landscape
  /// walkthrough, a phone screen recording, a square social clip. Closed
  /// presets rather than a free number field: a hand-typed ratio is only a
  /// way to end up with a card that is subtly the wrong shape, and the
  /// labels are numerals, so they need no translation.
  static const List<(double, String)> _ratioPresets = <(double, String)>[
    (16 / 9, '16:9'),
    (9 / 16, '9:16'),
    (1, '1:1'),
  ];

  late final String _id = widget.video?.id ?? IdGenerator.next('video');

  late ProjectVideo _video =
      widget.video ??
      ProjectVideo(id: _id, media: const MediaRef(kind: MediaKind.videoFile));

  late final TextEditingController _captionEn = TextEditingController(
    text: _video.captionEn,
  );
  late final TextEditingController _captionAr = TextEditingController(
    text: _video.captionAr,
  );

  /// Starts paused, same as [VideoCard]: nothing should autoplay while the
  /// admin is still choosing a source.
  bool _playing = false;

  void _setMedia(MediaRef media) {
    setState(() {
      _video = _video.copyWith(media: media);
      _playing = false;
    });
  }

  /// Only reshapes the card — playback deliberately keeps running, since the
  /// point of switching ratios mid-preview is to see the same moment of the
  /// same clip at another shape.
  void _setAspectRatio(double ratio) {
    setState(() => _video = _video.copyWith(aspectRatio: ratio));
  }

  @override
  void dispose() {
    _captionEn.dispose();
    _captionAr.dispose();
    super.dispose();
  }

  /// Falls back to the raw ratio for a video stored at some shape outside the
  /// presets, so an unrecognised value is visible rather than silently shown
  /// as nothing selected.
  String _ratioLabel(double ratio) {
    for (final (value, label) in _ratioPresets) {
      if (value == ratio) return label;
    }
    return ratio.toStringAsFixed(2);
  }

  List<Widget> _fields(BuildContext context) {
    return <Widget>[
      MediaRefField(
        label: context.translate(LangKeys.fieldShotMedia),
        value: _video.media,
        previewAspectRatio: _video.aspectRatio,
        onChanged: _setMedia,
      ),
      AdminChoiceField<double>(
        label: context.translate(LangKeys.fieldVideoAspectRatio),
        value: _video.aspectRatio,
        options: <double>[for (final (value, _) in _ratioPresets) value],
        labelOf: _ratioLabel,
        onChanged: _setAspectRatio,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldCaptionEn),
        controller: _captionEn,
        textInputAction: TextInputAction.next,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldCaptionAr),
        controller: _captionAr,
        textInputAction: TextInputAction.next,
      ),
    ];
  }

  Widget _player(BuildContext context) {
    final colors = context.colors;

    // A YouTube embed carries its own player chrome and ignores `playing`
    // outright (see VideoEmbedView), so `controls` is left off for it rather
    // than stacking a second, disconnected transport bar over YouTube's own.
    // This box is never rotated or clipped by a parent transform, so the
    // platform view an embed needs is safe to allow.
    return AppMedia(
      media: _video.media,
      fit: BoxFit.cover,
      allowPlatformView: true,
      playing: _playing,
      preload: true,
      controls: _video.media.kind == MediaKind.videoFile,
      onPlayingChanged: (playing) => setState(() => _playing = playing),
      fallback: Center(
        child: Icon(
          Icons.play_circle_outline_rounded,
          size: 32.r,
          color: colors.onNavyFaint,
        ),
      ),
    );
  }

  Widget _preview(BuildContext context) {
    final colors = context.colors;

    return AspectRatio(
      aspectRatio: _video.aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: DecoratedBox(
          decoration: BoxDecoration(color: colors.surface),
          child: _player(context),
        ),
      ),
    );
  }

  void _submit() {
    context.pop<ProjectVideo>(
      _video.copyWith(
        id: _id,
        captionEn: _captionEn.text.trim(),
        captionAr: _captionAr.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormScreen(
      title: context.translate(LangKeys.adminAddVideo),
      fieldsBuilder: _fields,
      previewBuilder: _preview,
      onSave: _submit,
    );
  }
}
