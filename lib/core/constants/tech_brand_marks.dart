import 'package:flutter/material.dart';

/// The brand logo and colour for a tech badge.
///
/// These are build assets, not content: the file has to be in `pubspec.yaml`
/// and the colour is the brand's, not Marco's to edit. So the badge *list* is
/// editable content (`TechBadgeEntity` — which badges, their order, their
/// labels) while the mark each one wears is looked up here.
class TechBrandMark {
  const TechBrandMark({required this.assetPath, required this.color});

  /// Case-sensitive: the web build serves assets over HTTP, where `gitHub.svg`
  /// and `github.svg` are different files.
  final String assetPath;

  /// The lighter stop of the brand's colour, used to tint the fallback glyph
  /// so it stays legible on navy.
  final Color color;
}

/// Resolves a badge to its brand mark, or null when there is no logo for it.
///
/// A badge with no entry here is not broken — it falls back to its
/// `AppIconCatalog` glyph, which is what a newly added badge gets until a logo
/// is shipped for it.
class TechBrandMarks {
  const TechBrandMarks._();

  static const String _dir = 'assets/tech';

  /// Keyed by [normalize]d label. A GitHub badge is `GitHub`, `github` or
  /// `Git Hub` depending on who typed it; all three land here.
  static const Map<String, TechBrandMark> _marks = <String, TechBrandMark>{
    'flutter': TechBrandMark(
      assetPath: '$_dir/flutter.svg',
      color: Color(0xFF54C5F8),
    ),
    'dart': TechBrandMark(
      assetPath: '$_dir/dart.svg',
      color: Color(0xFF41C4FF),
    ),
    'firebase': TechBrandMark(
      assetPath: '$_dir/firebase.svg',
      color: Color(0xFFFFCA28),
    ),
    'android': TechBrandMark(
      assetPath: '$_dir/android.svg',
      color: Color(0xFF6FE39F),
    ),
    // A light mark on purpose: the GitHub logo is dark and would disappear
    // against this navy ground.
    'github': TechBrandMark(
      assetPath: '$_dir/gitHub.svg',
      color: Color(0xFFF0F6FC),
    ),
    'net': TechBrandMark(
      assetPath: '$_dir/dotnet.svg',
      color: Color(0xFF9B7BFF),
    ),
    'dotnet': TechBrandMark(
      assetPath: '$_dir/dotnet.svg',
      color: Color(0xFF9B7BFF),
    ),
    // `C#` normalizes to `c`, so both spellings are listed rather than left to
    // whichever one happens to be typed.
    'c': TechBrandMark(assetPath: '$_dir/csharp.svg', color: Color(0xFFB980C8)),
    'csharp': TechBrandMark(
      assetPath: '$_dir/csharp.svg',
      color: Color(0xFFB980C8),
    ),
    'graphql': TechBrandMark(
      assetPath: '$_dir/graphQL.svg',
      color: Color(0xFFF06FC4),
    ),
    'mysql': TechBrandMark(
      assetPath: '$_dir/mysql.svg',
      color: Color(0xFF4FA8C4),
    ),
    'sql': TechBrandMark(assetPath: '$_dir/sql.svg', color: Color(0xFF7FB3D5)),
    'figma': TechBrandMark(
      assetPath: '$_dir/figma.svg',
      color: Color(0xFFFF7262),
    ),
  };

  /// Lowercased with everything but letters and digits stripped, so spacing,
  /// dots and case in an admin-typed label do not decide whether a logo shows.
  static String normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');

  /// Tries the label first, then the badge id — a badge seeded with the id
  /// `rest` and the label `REST` has no mark either way, but one seeded as
  /// `github` with a label Marco has since reworded still finds its logo.
  static TechBrandMark? resolve({required String label, required String id}) =>
      _marks[normalize(label)] ?? _marks[normalize(id)];
}
