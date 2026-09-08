import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../styles/colors/content_palette.dart';
import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import '../../utils/hex_color.dart';

/// Picks both ends of a gradient in one tap.
///
/// The two colours still have their own fields underneath for tuning, but the
/// starting point is a pair someone already made work together. A swatch shows
/// the actual blend rather than two dots, because a gradient is the thing being
/// chosen — not its endpoints.
class AdminGradientField extends StatelessWidget {
  const AdminGradientField({
    required this.label,
    required this.fromHex,
    required this.toHex,
    required this.onChanged,
    super.key,
  });

  final String label;
  final String fromHex;
  final String toHex;

  /// Hands back both hex values at once; a preset is only a preset if it
  /// arrives whole.
  final void Function(String fromHex, String toHex) onChanged;

  bool _isSelected(GradientPreset preset) =>
      preset.fromHex.toUpperCase() == fromHex.toUpperCase() &&
      preset.toHex.toUpperCase() == toHex.toUpperCase();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: MyFonts.caps12.copyWith(color: colors.onNavyMuted),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: <Widget>[
              for (final preset in ContentPalette.gradients)
                GestureDetector(
                  onTap: () => onChanged(preset.fromHex, preset.toHex),
                  child: _Swatch(preset: preset, selected: _isSelected(preset)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.preset, required this.selected});

  final GradientPreset preset;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Tooltip(
      message: preset.name,
      child: Container(
        width: 72.w,
        height: 44.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              HexColor.parse(preset.fromHex, colors.surface),
              HexColor.parse(preset.toHex, colors.surfaceHigh),
            ],
          ),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? colors.accent : colors.divider,
            width: selected ? 2.5 : 1,
          ),
        ),
      ),
    );
  }
}
