import 'package:flutter/material.dart';

/// One technology's logo in the hero orbit.
///
/// [assetPath] points at the brand's own logo. When that file is absent the
/// badge falls back to [fallbackIcon] tinted with [color], so the hero is never
/// broken by a missing asset — drop the logo in and it takes over.
class TechBrandMark {
  const TechBrandMark({
    required this.label,
    required this.assetPath,
    required this.color,
    required this.fallbackIcon,
  });

  final String label;

  /// Case-sensitive: the web build serves assets over HTTP, where `gitHub.svg`
  /// and `github.svg` are different files.
  final String assetPath;

  /// The lighter stop of the brand's colour. Tints the fallback glyph so it
  /// stays legible on navy.
  final Color color;

  /// Drawn until the logo asset exists.
  final IconData fallbackIcon;
}

/// The badges orbiting the hero photo, in the order they are placed.
///
/// This is build configuration, not editable content — decided 2026-09-10.
/// A badge cannot exist without its SVG being in `assets/tech/` and declared in
/// `pubspec.yaml`, which is a rebuild either way, so routing the *list* through
/// Firestore bought only reordering and hiding at the cost of the list and the
/// logos drifting apart. They had already drifted: the published `techBadges`
/// held six entries, four of which had no logo at all.
///
/// `TechBadgeEntity` still exists in the bundle and the data layer — this
/// decision governs what the hero renders, not what the schema carries.
class TechBrandMarks {
  const TechBrandMarks._();

  static const String _dir = 'assets/tech';

  static const List<TechBrandMark> all = <TechBrandMark>[
    TechBrandMark(
      label: 'Flutter',
      assetPath: '$_dir/flutter.svg',
      color: Color(0xFF54C5F8),
      fallbackIcon: Icons.flutter_dash,
    ),
    TechBrandMark(
      label: 'Dart',
      assetPath: '$_dir/dart.svg',
      color: Color(0xFF41C4FF),
      fallbackIcon: Icons.code_rounded,
    ),
    TechBrandMark(
      label: 'Firebase',
      assetPath: '$_dir/firebase.svg',
      color: Color(0xFFFFCA28),
      fallbackIcon: Icons.local_fire_department_rounded,
    ),
    TechBrandMark(
      label: 'Android',
      assetPath: '$_dir/android.svg',
      color: Color(0xFF6FE39F),
      fallbackIcon: Icons.android_rounded,
    ),
    TechBrandMark(
      label: 'GitHub',
      // A light colour on purpose: the GitHub mark is dark and would disappear
      // against a dark one on this navy ground.
      assetPath: '$_dir/gitHub.svg',
      color: Color(0xFFF0F6FC),
      fallbackIcon: Icons.merge_type_rounded,
    ),
    TechBrandMark(
      label: '.NET',
      assetPath: '$_dir/dotnet.svg',
      color: Color(0xFF9B7BFF),
      fallbackIcon: Icons.hexagon_rounded,
    ),
    TechBrandMark(
      label: 'C#',
      assetPath: '$_dir/csharp.svg',
      color: Color(0xFFB980C8),
      fallbackIcon: Icons.tag_rounded,
    ),
    TechBrandMark(
      label: 'GraphQL',
      assetPath: '$_dir/graphQL.svg',
      color: Color(0xFFF06FC4),
      fallbackIcon: Icons.hub_rounded,
    ),
    TechBrandMark(
      label: 'MySQL',
      assetPath: '$_dir/mysql.svg',
      color: Color(0xFF4FA8C4),
      fallbackIcon: Icons.storage_rounded,
    ),
    TechBrandMark(
      label: 'SQL',
      assetPath: '$_dir/sql.svg',
      color: Color(0xFF7FB3D5),
      fallbackIcon: Icons.table_chart_rounded,
    ),
    TechBrandMark(
      label: 'Figma',
      assetPath: '$_dir/figma.svg',
      color: Color(0xFFFF7262),
      fallbackIcon: Icons.brush_rounded,
    ),
  ];
}
