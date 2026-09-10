import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';

/// A labelled on/off row, styled to sit in the same column as the underline
/// text fields rather than as a Material list tile.
///
/// [description] carries what the two states actually mean — "on" is rarely
/// self-explanatory for a content flag, and the label alone has no room to say
/// it.
class AdminSwitchField extends StatelessWidget {
  const AdminSwitchField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.description,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  label,
                  style: MyFonts.caps12.copyWith(color: colors.onNavyMuted),
                ),
                if (description != null) ...<Widget>[
                  SizedBox(height: 4.h),
                  Text(
                    description!,
                    style: MyFonts.regular12.copyWith(
                      color: colors.onNavyFaint,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colors.pageTop,
            activeTrackColor: colors.accent,
            inactiveTrackColor: colors.surface,
          ),
        ],
      ),
    );
  }
}
