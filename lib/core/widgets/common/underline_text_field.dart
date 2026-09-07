import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';

/// A field with no box — just a bottom border, matching the reference site's
/// minimal contact form. Reused by the debug-mode admin forms.
class UnderlineTextField extends StatelessWidget {
  const UnderlineTextField({
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.hint,
    this.textInputAction,
    this.onChanged,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? hint;
  final TextInputAction? textInputAction;

  /// Lets a field that mirrors non-text state — an [ImageRef], a parsed
  /// number — react as it is typed rather than only on save.
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textInputAction: textInputAction,
        onChanged: onChanged,
        style: MyFonts.regular16.copyWith(color: colors.onNavy),
        cursorColor: colors.accent,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: MyFonts.regular14.copyWith(color: colors.onNavyMuted),
          floatingLabelStyle: MyFonts.caps12.copyWith(color: colors.accent),
          hintStyle: MyFonts.regular14.copyWith(color: colors.onNavyFaint),
          errorStyle: MyFonts.regular12.copyWith(color: colors.danger),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.divider),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.accent, width: 1.6),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.danger),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.danger, width: 1.6),
          ),
        ),
      ),
    );
  }
}
