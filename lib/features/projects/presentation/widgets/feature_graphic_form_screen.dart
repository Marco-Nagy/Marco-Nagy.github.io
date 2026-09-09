import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/navigation_extensions.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/widgets/admin/admin_form_screen.dart';
import '../../../../core/widgets/admin/media_ref_field.dart';
import '../../../../core/widgets/common/app_media.dart';
import '../../../../core/widgets/common/underline_text_field.dart';
import '../../../../core/widgets/showcase/tappable_video.dart';
import '../../../portfolio_content/domain/entities/media_ref.dart';
import '../../../portfolio_content/domain/entities/media_shot.dart';
import '../../../portfolio_content/domain/entities/showcase_panel.dart';

/// Add/edit screen for one Feature Graphic panel.
///
/// Its own screen rather than a case inside a shared media-item form — a
/// feature graphic is one flat image, full stop: no device frame, no
/// scale/rotation/offset, none of what [ScreenshotFormScreen] is for. Sharing
/// one form between the two meant either widget showed controls that did
/// nothing for it, which is exactly the confusion a dedicated screen removes.
class FeatureGraphicFormScreen extends StatefulWidget {
  const FeatureGraphicFormScreen({this.panel, super.key});

  /// Null when adding.
  final ShowcasePanel? panel;

  /// Resolves to the built panel, or null if dismissed.
  static Future<ShowcasePanel?> open(
    BuildContext context, {
    ShowcasePanel? panel,
  }) {
    return AdminFormScreen.open<ShowcasePanel>(
      context,
      FeatureGraphicFormScreen(panel: panel),
    );
  }

  @override
  State<FeatureGraphicFormScreen> createState() =>
      _FeatureGraphicFormScreenState();
}

class _FeatureGraphicFormScreenState extends State<FeatureGraphicFormScreen> {
  late final String _id = widget.panel?.id ?? IdGenerator.next('panel');

  late ShowcasePanel _panel =
      widget.panel ??
      ShowcasePanel(
        id: _id,
        format: ShowcaseFormat.featureGraphic,
        shots: const <MediaShot>[MediaShot()],
      );

  late final TextEditingController _captionEn = TextEditingController(
    text: _panel.captionEn,
  );
  late final TextEditingController _captionAr = TextEditingController(
    text: _panel.captionAr,
  );

  /// Starts paused, same as [FeatureGraphicCard]: nothing should autoplay
  /// while the admin is still choosing a source.
  bool _playing = false;

  MediaRef get _media =>
      _panel.shots.isEmpty ? const MediaRef() : _panel.shots.first.image;

  void _setMedia(MediaRef media) {
    setState(() {
      _panel = _panel.copyWith(shots: <MediaShot>[MediaShot(image: media)]);
      _playing = false;
    });
  }

  @override
  void dispose() {
    _captionEn.dispose();
    _captionAr.dispose();
    super.dispose();
  }

  List<Widget> _fields(BuildContext context) {
    return <Widget>[
      MediaRefField(
        label: context.translate(LangKeys.fieldShotMedia),
        value: _media,
        previewAspectRatio: 1024 / 500,
        onChanged: _setMedia,
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

  Widget _preview(BuildContext context) {
    final colors = context.colors;
    final isVideoFile = _media.kind == MediaKind.videoFile;
    final fallback = Center(
      child: Icon(
        Icons.image_outlined,
        size: 32.r,
        color: colors.onNavyFaint,
      ),
    );

    // A feature graphic can also be a video file (see FeatureGraphicCard), and
    // an embed already owns its own tap-to-start badge and ignores `playing`
    // outright — only a video file gets the outer tap chrome. Not inside any
    // rotated/clipped ancestor here, so the platform view an embed needs is
    // safe to allow.
    final media = AppMedia(
      media: _media,
      fit: BoxFit.cover,
      allowPlatformView: true,
      playing: isVideoFile ? _playing : true,
      preload: true,
      fallback: fallback,
    );

    return AspectRatio(
      aspectRatio: 1024 / 500,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: DecoratedBox(
          decoration: BoxDecoration(color: colors.surface),
          child: isVideoFile
              ? TappableVideo(
                  playing: _playing,
                  onTap: () => setState(() => _playing = !_playing),
                  child: media,
                )
              : media,
        ),
      ),
    );
  }

  void _submit() {
    context.pop<ShowcasePanel>(
      _panel.copyWith(
        id: _id,
        captionEn: _captionEn.text.trim(),
        captionAr: _captionAr.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormScreen(
      title: context.translate(LangKeys.adminAddFeatureGraphic),
      fieldsBuilder: _fields,
      previewBuilder: _preview,
      onSave: _submit,
    );
  }
}
