/// Inline SVG glyphs for every debug-only admin control.
///
/// Hand-drawn rather than [Icons.*]: at the small sizes admin chrome runs
/// at (15–20 logical px), Material's raster glyphs soften at the edges,
/// while a stroke-based SVG stays crisp and can be recolored per-state with
/// a [ColorFilter] without needing a second asset.
class AdminSvgIcons {
  const AdminSvgIcons._();

  static const String edit = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M4 20h4L18.5 9.5a2 2 0 0 0 0-2.83l-1.17-1.17a2 2 0 0 0-2.83 0L4 15.5V20Z"
    stroke="black" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M13 7l4 4" stroke="black" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

  static const String delete = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M4 7h16" stroke="black" stroke-width="1.8" stroke-linecap="round"/>
  <path d="M9 7V4.6c0-.55.45-1 1-1h4c.55 0 1 .45 1 1V7"
    stroke="black" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M6.2 7l.65 12.2a1.5 1.5 0 0 0 1.5 1.4h7.3a1.5 1.5 0 0 0 1.5-1.4L17.8 7"
    stroke="black" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M10 11v5.5M14 11v5.5" stroke="black" stroke-width="1.8" stroke-linecap="round"/>
</svg>
''';

  static const String add = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 5v14M5 12h14" stroke="black" stroke-width="1.8" stroke-linecap="round"/>
</svg>
''';

  static const String reset = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M4 4v5h5" stroke="black" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M4.5 13a8 8 0 1 0 2.6-6.6L4 9" stroke="black" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';
}
