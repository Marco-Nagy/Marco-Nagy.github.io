import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/navigation_extensions.dart';
import '../../../../core/widgets/admin/admin_choice_field.dart';
import '../../../../core/widgets/admin/admin_color_field.dart';
import '../../../../core/widgets/admin/admin_form_sheet.dart';
import '../../../../core/widgets/admin/admin_gradient_field.dart';
import '../../../../core/widgets/admin/admin_slider_field.dart';
import '../../../../core/widgets/admin/media_ref_field.dart';
import '../../../../core/widgets/showcase/shot_background_view.dart';
import '../../../portfolio_content/domain/entities/media_ref.dart';
import '../../../portfolio_content/domain/entities/shot_background.dart';

/// Edits the ground a showcase panel is painted on.
///
/// Only the fields the chosen [ShotBackgroundStyle] actually reads are shown —
/// a gradient's second colour is meaningless for a solid fill, and offering it
/// anyway invites someone to set it and wonder why nothing moved.
class BackgroundFormSheet extends StatefulWidget {
  const BackgroundFormSheet({required this.background, super.key});

  final ShotBackground background;

  /// Resolves to the edited background, or null if dismissed.
  static Future<ShotBackground?> open(
    BuildContext context, {
    required ShotBackground background,
  }) {
    return AdminFormSheet.show<ShotBackground>(
      context,
      BackgroundFormSheet(background: background),
    );
  }

  @override
  State<BackgroundFormSheet> createState() => _BackgroundFormSheetState();
}

class _BackgroundFormSheetState extends State<BackgroundFormSheet> {
  late ShotBackground _background = widget.background;

  void _update(ShotBackground next) => setState(() => _background = next);

  String _styleLabel(ShotBackgroundStyle style) =>
      context.translate(switch (style) {
        ShotBackgroundStyle.none => LangKeys.backgroundNone,
        ShotBackgroundStyle.solid => LangKeys.backgroundSolid,
        ShotBackgroundStyle.linearGradient => LangKeys.backgroundLinear,
        ShotBackgroundStyle.radialGradient => LangKeys.backgroundRadial,
        ShotBackgroundStyle.blob => LangKeys.backgroundBlob,
        ShotBackgroundStyle.image => LangKeys.backgroundImage,
      });

  bool get _usesColor => switch (_background.style) {
    ShotBackgroundStyle.none || ShotBackgroundStyle.image => false,
    _ => true,
  };

  bool get _usesSecondColor => switch (_background.style) {
    ShotBackgroundStyle.linearGradient ||
    ShotBackgroundStyle.radialGradient ||
    ShotBackgroundStyle.blob => true,
    _ => false,
  };

  List<Widget> _fields(BuildContext context) {
    return <Widget>[
      // Gradient, overlay and blur combine into an effect none of the fields
      // below shows on its own — a solid ground, and a solid ground under a
      // 40% scrim, are two different fields that read identically as a colour
      // swatch. This renders the actual composited result, live.
      Padding(
        padding: EdgeInsets.only(bottom: 24.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ShotBackgroundView(background: _background),
          ),
        ),
      ),
      AdminChoiceField<ShotBackgroundStyle>(
        label: context.translate(LangKeys.fieldBackgroundStyle),
        value: _background.style,
        options: ShotBackgroundStyle.selectable,
        labelOf: _styleLabel,
        onChanged: (style) => _update(_background.copyWith(style: style)),
      ),
      // Presets first: the pair is the decision, and the two fields below are
      // for nudging one end of a pair that is already close.
      if (_usesSecondColor)
        AdminGradientField(
          label: context.translate(LangKeys.fieldBackgroundGradient),
          fromHex: _background.colorHex,
          toHex: _background.colorHex2,
          onChanged: (from, to) =>
              _update(_background.copyWith(colorHex: from, colorHex2: to)),
        ),
      if (_usesColor)
        AdminColorField(
          label: context.translate(LangKeys.fieldBackgroundColor),
          value: _background.colorHex,
          hint: '0A1533',
          onChanged: (hex) => _update(_background.copyWith(colorHex: hex)),
        ),
      if (_usesSecondColor)
        AdminColorField(
          label: context.translate(LangKeys.fieldBackgroundColor2),
          value: _background.colorHex2,
          hint: '1B3F8F',
          onChanged: (hex) => _update(_background.copyWith(colorHex2: hex)),
        ),
      if (_background.style == ShotBackgroundStyle.image)
        MediaRefField(
          label: context.translate(LangKeys.fieldBackgroundImage),
          // A background is a still by design — it sits behind the caption and
          // the devices, where motion would fight everything on top of it.
          value: MediaRef.still(_background.image),
          previewAspectRatio: 16 / 9,
          onChanged: (media) =>
              _update(_background.copyWith(image: media.image)),
        ),
      if (_background.style != ShotBackgroundStyle.none) ...<Widget>[
        AdminSliderField(
          label: context.translate(LangKeys.fieldBackgroundOverlay),
          value: _background.overlayOpacity,
          min: 0,
          max: 1,
          onChanged: (v) => _update(_background.copyWith(overlayOpacity: v)),
        ),
        AdminSliderField(
          label: context.translate(LangKeys.fieldBackgroundBlur),
          value: _background.blurSigma,
          min: 0,
          max: 20,
          decimals: 1,
          onChanged: (v) => _update(_background.copyWith(blurSigma: v)),
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormSheet(
      title: context.translate(LangKeys.formEditBackground),
      fieldsBuilder: _fields,
      onSave: () => context.pop<ShotBackground>(_background),
    );
  }
}
