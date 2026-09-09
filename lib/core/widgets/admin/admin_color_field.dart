import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../styles/colors/content_palette.dart';
import '../../utils/extension/context_extensions.dart';
import '../../utils/hex_color.dart';
import '../common/underline_text_field.dart';

/// Picks a colour from the site's palette, with the hex box kept alongside.
///
/// The swatches are the point — hand-typing `4CC9F0` is how a project ends up
/// with an accent that belongs to no palette at all. The field stays because a
/// colour lifted from a screenshot has to be typeable, and because the stored
/// value is a hex string either way.
class AdminColorField extends StatefulWidget {
  const AdminColorField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    super.key,
  });

  final String label;

  /// Six-digit `RRGGBB`, the form every colour is stored in.
  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;

  @override
  State<AdminColorField> createState() => _AdminColorFieldState();
}

class _AdminColorFieldState extends State<AdminColorField> {
  late String _hex = _normalize(widget.value, widget.value);

  late final TextEditingController _field = TextEditingController(text: _hex);

  /// Anything unparseable keeps the last good value: a colour is mid-edit for
  /// as long as it takes to type six characters, and blanking the swatch on
  /// every keystroke is just flicker.
  static String _normalize(String raw, String fallback) {
    final hex = raw.trim().replaceFirst('#', '').toUpperCase();
    return hex.length == 6 ? hex : fallback;
  }

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  void _emit(String hex) {
    setState(() => _hex = hex);
    widget.onChanged(hex);
  }

  void _onTyped(String text) {
    final hex = _normalize(text, _hex);
    if (hex != _hex) _emit(hex);
  }

  void _pick(Color color) {
    final hex = HexColor.toHex(color);
    _field.text = hex;
    _emit(hex);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selected = HexColor.parse(_hex, colors.accent);

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _Swatch(color: selected, selected: false, size: 44),
              SizedBox(width: 16.w),
              Expanded(
                child: UnderlineTextField(
                  label: widget.label,
                  controller: _field,
                  hint: widget.hint,
                  onChanged: _onTyped,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: <Widget>[
              for (final color in ContentPalette.all)
                GestureDetector(
                  onTap: () => _pick(color),
                  child: _Swatch(
                    color: color,
                    selected: HexColor.toHex(color) == _hex,
                  ),
                ),
            ],
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.selected, this.size = 28});

  final Color color;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          // A dark swatch on a navy sheet is invisible without an edge, and the
          // selected one needs to be obvious at swatch size.
          color: selected ? colors.accent : colors.divider,
          width: selected ? 2.5 : 1,
        ),
      ),
    );
  }
}
