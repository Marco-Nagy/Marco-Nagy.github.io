import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/navigation_extensions.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/widgets/admin/admin_choice_field.dart';
import '../../../../core/widgets/admin/admin_form_screen.dart';
import '../../../../core/widgets/admin/admin_slider_field.dart';
import '../../../../core/widgets/admin/media_ref_field.dart';
import '../../../../core/widgets/common/underline_text_field.dart';
import '../../../../core/widgets/showcase/shot_preview.dart';
import '../../../portfolio_content/domain/entities/media_shot.dart';
import '../../../portfolio_content/domain/entities/showcase_panel.dart';

/// Add/edit screen for one Screenshot panel — a device-framed shot with its
/// own frame, scale, rotation and offset.
///
/// Its own screen rather than a case inside a shared media-item form — this
/// is the one media kind with real geometry to tune, and tuning it blind was
/// exactly the complaint that led here: [ShotPreview] sits fixed on the
/// right, so a scale or rotation change is seen the moment it is made instead
/// of after saving and reopening the panel to look.
class ScreenshotFormScreen extends StatefulWidget {
  const ScreenshotFormScreen({this.panel, super.key});

  /// Null when adding.
  final ShowcasePanel? panel;

  /// Resolves to the built panel, or null if dismissed.
  static Future<ShowcasePanel?> open(
    BuildContext context, {
    ShowcasePanel? panel,
  }) {
    return AdminFormScreen.open<ShowcasePanel>(
      context,
      ScreenshotFormScreen(panel: panel),
    );
  }

  @override
  State<ScreenshotFormScreen> createState() => _ScreenshotFormScreenState();
}

class _ScreenshotFormScreenState extends State<ScreenshotFormScreen> {
  late final String _id = widget.panel?.id ?? IdGenerator.next('panel');

  late ShowcasePanel _panel =
      widget.panel ??
      ShowcasePanel(
        id: _id,
        format: ShowcaseFormat.screenshot,
        shots: const <MediaShot>[MediaShot(frame: DeviceFrameType.iphone)],
      );

  late final TextEditingController _captionEn = TextEditingController(
    text: _panel.captionEn,
  );
  late final TextEditingController _captionAr = TextEditingController(
    text: _panel.captionAr,
  );

  MediaShot get _shot =>
      _panel.shots.isEmpty ? const MediaShot() : _panel.shots.first;

  void _updateShot(MediaShot next) {
    setState(() => _panel = _panel.copyWith(shots: <MediaShot>[next]));
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
        value: _shot.image,
        previewAspectRatio: _shot.frame.isLandscape ? 16 / 10 : 9 / 16,
        onChanged: (media) => _updateShot(_shot.copyWith(image: media)),
      ),
      AdminChoiceField<DeviceFrameType>(
        label: context.translate(LangKeys.fieldShotFrame),
        value: _shot.frame,
        options: DeviceFrameType.selectable,
        labelOf: _frameLabel,
        onChanged: (frame) => _updateShot(_shot.copyWith(frame: frame)),
      ),
      AdminSliderField(
        label: context.translate(LangKeys.fieldShotScale),
        value: _shot.scale,
        min: 0.5,
        max: 2,
        onChanged: (v) => _updateShot(_shot.copyWith(scale: v)),
      ),
      AdminSliderField(
        label: context.translate(LangKeys.fieldShotRotation),
        value: _shot.rotationDegrees,
        min: -45,
        max: 45,
        divisions: 90,
        decimals: 0,
        suffix: '°',
        onChanged: (v) => _updateShot(_shot.copyWith(rotationDegrees: v)),
      ),
      AdminSliderField(
        label: context.translate(LangKeys.fieldShotOffsetX),
        value: _shot.offsetX,
        min: -1,
        max: 1,
        onChanged: (v) => _updateShot(_shot.copyWith(offsetX: v)),
      ),
      AdminSliderField(
        label: context.translate(LangKeys.fieldShotOffsetY),
        value: _shot.offsetY,
        min: -1,
        max: 1,
        onChanged: (v) => _updateShot(_shot.copyWith(offsetY: v)),
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
    return Center(
      child: ShotPreview(shot: _shot, width: 300.w, height: 380.h),
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
      title: context.translate(LangKeys.adminAddScreenshot),
      fieldsBuilder: _fields,
      previewBuilder: _preview,
      onSave: _submit,
    );
  }
}
