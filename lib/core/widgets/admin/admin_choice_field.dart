import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';

/// A labelled row of single-select chips, for the short closed enums the admin
/// forms are full of — media kind, device frame, panel format, background style.
///
/// Chips rather than a dropdown: every one of these sets is small, and seeing
/// the options at once is what makes an unfamiliar enum guessable instead of
/// something you have to open to learn.
class AdminChoiceField<T> extends StatelessWidget {
  const AdminChoiceField({
    required this.label,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
    super.key,
  });

  final String label;
  final T value;
  final List<T> options;
  final String Function(T option) labelOf;
  final ValueChanged<T> onChanged;

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
            spacing: 8.w,
            runSpacing: 8.h,
            children: <Widget>[
              for (final option in options)
                _Chip(
                  label: labelOf(option),
                  selected: option == value,
                  onTap: () => onChanged(option),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected
              ? colors.accent.withValues(alpha: 0.16)
              : colors.transparent,
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(
            color: selected ? colors.accent : colors.divider,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Text(
          label,
          style: MyFonts.regular14.copyWith(
            color: selected ? colors.accent : colors.onNavyMuted,
          ),
        ),
      ),
    );
  }
}
