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
import '../../../portfolio_content/domain/entities/media_ref.dart';
import '../../../portfolio_content/domain/entities/media_shot.dart';
import '../../../portfolio_content/domain/entities/showcase_panel.dart';

/// Add/edit screen for one GIF panel — a looping animated image, no device
/// frame around it.
///
/// Its own screen rather than a case inside a shared media-item form. A GIF
/// is recognised structurally, by a `.gif` path or a `data:image/gif` prefix
/// — see `MediaRef.isAnimatedImage` — so there is no kind to preset here the
/// way [VideoFormScreen] presets `videoFile`; picking a `.gif` file is what
/// makes it one.
class GifFormScreen extends StatefulWidget {
  const GifFormScreen({this.panel, super.key});

  /// Null when adding.
  final ShowcasePanel? panel;

  /// Resolves to the built panel, or null if dismissed.
  static Future<ShowcasePanel?> open(
    BuildContext context, {
    ShowcasePanel? panel,
  }) {
    return AdminFormScreen.open<ShowcasePanel>(
      context,
      GifFormScreen(panel: panel),
    );
  }

  @override
  State<GifFormScreen> createState() => _GifFormScreenState();
}

class _GifFormScreenState extends State<GifFormScreen> {
  late final String _id = widget.panel?.id ?? IdGenerator.next('panel');

  late ShowcasePanel _panel =
      widget.panel ?? ShowcasePanel(id: _id, format: ShowcaseFormat.screenshot);

  late final TextEditingController _captionEn = TextEditingController(
    text: _panel.captionEn,
  );
  late final TextEditingController _captionAr = TextEditingController(
    text: _panel.captionAr,
  );

  MediaRef get _media =>
      _panel.shots.isEmpty ? const MediaRef() : _panel.shots.first.image;

  void _setMedia(MediaRef media) {
    setState(() {
      _panel = _panel.copyWith(shots: <MediaShot>[MediaShot(image: media)]);
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
        previewAspectRatio: 9 / 16,
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
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: DecoratedBox(
          decoration: BoxDecoration(color: colors.surface),
          child: AppMedia(
            media: _media,
            fit: BoxFit.cover,
            allowPlatformView: false,
            // preload turns a picked/typed .gif into a visible first frame
            // without starting the loop — this screen is for choosing the
            // file, not for watching it animate.
            playing: false,
            preload: true,
            fallback: Center(
              child: Icon(
                Icons.gif_box_outlined,
                size: 32.r,
                color: colors.onNavyFaint,
              ),
            ),
          ),
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
      title: context.translate(LangKeys.adminAddGif),
      fieldsBuilder: _fields,
      previewBuilder: _preview,
      onSave: _submit,
    );
  }
}
