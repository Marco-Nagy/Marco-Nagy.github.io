import 'dart:ui' show Color;

import 'navy_colors.dart';

/// Two colours that were chosen to sit together.
///
/// Offering the pair as one swatch is the whole difference between picking a
/// gradient and picking two colours that merely happen to be next to each
/// other — which is how a showcase panel ends up muddy.
class GradientPreset {
  const GradientPreset(this.name, this.fromHex, this.toHex);

  final String name;

  /// Stored as hex because that is what [ShotBackground] keeps: `colorHex` and
  /// `colorHex2`, straight into JSON.
  final String fromHex;
  final String toHex;
}

/// The swatches offered when picking a colour for content — a project accent,
/// a panel gradient, a caption.
///
/// Drawn from the app's own tokens rather than a generic colour wheel, so a
/// picked colour belongs to the palette the site already uses. The gradient
/// partners are the tints the seeded projects pair with, kept here so a new
/// project can reach for the same ones instead of guessing a lighter shade.
class ContentPalette {
  const ContentPalette._();

  /// Grouped only for the swatch rows to wrap sensibly; nothing reads the
  /// groups apart.
  static const List<Color> all = <Color>[
    // Brand
    NavyColors.accent,
    NavyColors.accentSoft,
    NavyColors.accentDim,

    // Per-project accents already in use
    NavyColors.projectPink,
    NavyColors.projectGreen,
    NavyColors.projectAmber,

    // Gradient partners the seeded panels pair with
    Color(0xFFFFC2D8),
    Color(0xFFE91E63),
    Color(0xFFF8BBD0),
    Color(0xFF3A1C71),
    Color(0xFFFFAF7B),

    // Grounds and text
    NavyColors.navyDeep,
    NavyColors.navyBase,
    NavyColors.navyLift,
    NavyColors.navyGlow,
    NavyColors.white,
    NavyColors.whiteMuted,
    NavyColors.danger,
  ];

  /// Ready-made grounds for a project showcase, ordered site-first.
  ///
  /// The first three are the pairs the seeded projects already use, so a new
  /// project can match the ones beside it; the rest are built from the app's
  /// own navy and accent tokens.
  static const List<GradientPreset> gradients = <GradientPreset>[
    GradientPreset('Site navy', '0A1533', '1B3F8F'),
    GradientPreset('Deep navy', '050B1B', '122350'),
    GradientPreset('Glow', '1B3F8F', '4CC9F0'),
    GradientPreset('Accent', '2A6E8A', '4CC9F0'),
    GradientPreset('Ice', '4CC9F0', '7BDCF7'),
    GradientPreset('Mint', '3DDC97', '4CC9F0'),
    GradientPreset('Blossom', 'FF6FA5', 'FFC2D8'),
    GradientPreset('Rose', 'E91E63', 'F8BBD0'),
    GradientPreset('Dusk', '3A1C71', 'FFAF7B'),
    GradientPreset('Ember', 'FFB020', 'FF6FA5'),
  ];

  /// What a project starts on before anyone opens the background sheet. A flat
  /// `none` reads as a bug in the showcase rather than a choice.
  static const GradientPreset defaultGradient = GradientPreset(
    'Site navy',
    '0A1533',
    '1B3F8F',
  );
}
