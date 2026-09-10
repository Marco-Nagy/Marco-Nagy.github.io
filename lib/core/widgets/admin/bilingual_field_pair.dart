import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../common/underline_text_field.dart';

/// The English/Arabic field pair that every content form is built out of.
///
/// Side by side once there is room, stacked below ~520px. Worth the layout
/// rather than two plain fields in a column: `site_content_form_screen` alone
/// carries 20-odd of these, and stacking them all doubles a form that is
/// already long enough to need its own page.
///
/// **Only the English side is ever validated.** Every bilingual read in the app
/// goes through `context.localized(en, ar)`, which falls back to English when
/// the Arabic value is blank — so Arabic is genuinely optional content, and a
/// required-marker on it would be a lie the rest of the codebase disagrees with.
class BilingualFieldPair extends StatelessWidget {
  const BilingualFieldPair({
    required this.labelEn,
    required this.labelAr,
    required this.controllerEn,
    required this.controllerAr,
    this.validator,
    this.maxLines = 1,
    this.hintEn,
    this.hintAr,
    super.key,
  });

  final String labelEn;
  final String labelAr;
  final TextEditingController controllerEn;
  final TextEditingController controllerAr;

  /// Applied to the English field only — see the class doc.
  final String? Function(String?)? validator;

  final int maxLines;
  final String? hintEn;
  final String? hintAr;

  /// Below this the two fields stack. Measured against the form column's own
  /// width, not the window's: these sit inside a max-720 form that can itself
  /// be inside a sheet.
  static const double _stackBelow = 520;

  @override
  Widget build(BuildContext context) {
    final english = UnderlineTextField(
      label: labelEn,
      controller: controllerEn,
      validator: validator,
      maxLines: maxLines,
      hint: hintEn,
      textInputAction: maxLines == 1 ? TextInputAction.next : null,
    );
    final arabic = UnderlineTextField(
      label: labelAr,
      controller: controllerAr,
      maxLines: maxLines,
      hint: hintAr,
      textInputAction: maxLines == 1 ? TextInputAction.next : null,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _stackBelow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[english, arabic],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: english),
            SizedBox(width: 16.w),
            Expanded(child: arabic),
          ],
        );
      },
    );
  }
}
