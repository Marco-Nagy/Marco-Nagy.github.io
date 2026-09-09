import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';

/// A labelled slider with its current value shown beside the label.
///
/// The showcase composer is full of numbers whose right value is whatever looks
/// right — how far a phone overflows the panel edge, how heavy a scrim needs to
/// be. Those are found by dragging and watching, not by typing `1.12` and
/// saving to see what happened.
class AdminSliderField extends StatelessWidget {
  const AdminSliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.decimals = 2,
    this.suffix = '',
    super.key,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final int? divisions;

  /// How precisely to print the value. Degrees want none, a scale wants two.
  final int decimals;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // A value loaded from storage can sit outside the range this slider offers
    // — an older hand-authored panel, or a range narrowed since. Clamp for the
    // thumb only; the underlying value is left alone until something drags it.
    final clamped = value.clamp(min, max);

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: MyFonts.caps12.copyWith(color: colors.onNavyMuted),
                ),
              ),
              Text(
                '${value.toStringAsFixed(decimals)}$suffix',
                style: MyFonts.regular14.copyWith(color: colors.accent),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colors.accent,
              inactiveTrackColor: colors.divider,
              thumbColor: colors.accent,
              overlayColor: colors.accent.withValues(alpha: 0.16),
              trackHeight: 3.h,
            ),
            child: Slider(
              value: clamped,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
