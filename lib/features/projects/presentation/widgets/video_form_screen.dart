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
import '../../../../core/widgets/showcase/device_frame.dart';
import '../../../../core/widgets/showcase/tappable_video.dart';
import '../../../portfolio_content/domain/entities/media_ref.dart';
import '../../../portfolio_content/domain/entities/media_shot.dart';
import '../../../portfolio_content/domain/entities/project_video.dart';

/// Add/edit screen for one [ProjectVideo] — a screen recording or a YouTube
/// walkthrough.
///
/// Its own screen rather than a case inside a shared media-item form — video
/// has neither the geometry [ScreenshotFormScreen] tunes nor the flat crop
/// [FeatureGraphicFormScreen] wants; it is a source, a frame choice and a
/// caption, with a preview an admin can actually play. The preview reuses
/// `TappableVideo`, the same tap-to-play chrome the detail page's `VideoCard`
/// uses, so a chosen source can be checked here before it ever reaches the
/// live site.
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

  void _setFrame(DeviceFrameType frame) {
    setState(() {
      _video = _video.copyWith(frame: frame);
      _playing = false;
    });
  }

  @override
  void dispose() {
    _captionEn.dispose();
    _captionAr.dispose();
    super.dispose();
  }

  String _frameLabel(DeviceFrameType frame) =>
      context.translate(switch (frame) {
        DeviceFrameType.none => LangKeys.frameNone,
        DeviceFrameType.laptop => LangKeys.frameLaptop,
        DeviceFrameType.iphone => LangKeys.frameIphone,
        DeviceFrameType.samsungS => LangKeys.frameSamsung,
      });

  List<Widget> _fields(BuildContext context) {
    return <Widget>[
      MediaRefField(
        label: context.translate(LangKeys.fieldShotMedia),
        value: _video.media,
        previewAspectRatio: _video.aspectRatio,
        onChanged: _setMedia,
      ),
      AdminChoiceField<DeviceFrameType>(
        label: context.translate(LangKeys.fieldShotFrame),
        value: _video.frame,
        options: DeviceFrameType.selectable,
        labelOf: _frameLabel,
        onChanged: _setFrame,
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

  bool get _isVideoFile => _video.media.kind == MediaKind.videoFile;

  bool get _isFramed => _video.frame != DeviceFrameType.none;

  Widget _bare(BuildContext context) {
    final colors = context.colors;

    // A YouTube embed already owns its own tap-to-start badge and ignores
    // `playing` outright (see VideoEmbedView) — wrapping it in TappableVideo
    // too would stack a second, disconnected badge on top of it. Only a
    // video file responds to `playing`, so only that case gets the outer tap
    // chrome. This box is never rotated or clipped by a parent transform, so
    // the platform view a YouTube embed needs is safe to allow.
    final media = AppMedia(
      media: _video.media,
      fit: BoxFit.cover,
      allowPlatformView: true,
      playing: _playing,
      preload: true,
      fallback: Center(
        child: Icon(
          Icons.play_circle_outline_rounded,
          size: 32.r,
          color: colors.onNavyFaint,
        ),
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

  Widget _framed(BuildContext context) {
    // DeviceFrame always renders with allowPlatformView false (it is a bezel,
    // not a flat surface — see its own doc comment), so a YouTube embed shown
    // inside one rests on its poster here too; only a video file plays.
    return TappableVideo(
      playing: _playing,
      onTap: () => setState(() => _playing = !_playing),
      child: DeviceFrame(
        image: _video.media,
        frame: _video.frame,
        width: 300.w,
        playing: _playing,
      ),
    );
  }

  Widget _preview(BuildContext context) {
    final colors = context.colors;

    if (_isFramed) {
      return Center(child: _framed(context));
    }

    return AspectRatio(
      aspectRatio: _video.aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: DecoratedBox(
          decoration: BoxDecoration(color: colors.surface),
          child: _bare(context),
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
