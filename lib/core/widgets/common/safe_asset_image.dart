import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/extension/context_extensions.dart';
import '../motion/motion_durations.dart';

/// Renders an asset, or [fallback] when the asset is missing.
///
/// Screenshots and the headshot are dropped in by hand, so a missing file must
/// degrade to a styled placeholder instead of throwing a grey exception box.
class SafeAssetImage extends StatelessWidget {
  const SafeAssetImage({
    required this.assetPath,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.cacheWidth,
    this.cacheHeight,
    super.key,
  });

  final String assetPath;
  final Widget fallback;
  final BoxFit fit;
  final double? width;
  final double? height;

  /// Physical-pixel decode target — see `AppImage._cacheDim`.
  final int? cacheWidth;
  final int? cacheHeight;

  bool get _isVector => assetPath.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (assetPath.trim().isEmpty) return fallback;
    if (_isVector) {
      return _SafeSvgAsset(
        assetPath: assetPath,
        fallback: fallback,
        fit: fit,
        width: width,
        height: height,
      );
    }
    return Image.asset(
      assetPath,
      fit: fit,
      width: width,
      height: height,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      errorBuilder: (context, error, stackTrace) => fallback,
      // Decoding is asynchronous, so a large asset lands after its entrance
      // animation has already played. Without this the image pops in abruptly
      // and the section reads as if it never animated at all.
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: Motion.enter,
          curve: Motion.enterCurve,
          child: child,
        );
      },
    );
  }
}

/// SVG branch of [SafeAssetImage].
///
/// `SvgPicture.asset` has no error builder, so a missing file would throw
/// rather than degrade. Loading the markup ourselves first keeps the same
/// "never break on a missing asset" guarantee the raster path gives.
class _SafeSvgAsset extends StatelessWidget {
  const _SafeSvgAsset({
    required this.assetPath,
    required this.fallback,
    required this.fit,
    this.width,
    this.height,
  });

  final String assetPath;
  final Widget fallback;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: DefaultAssetBundle.of(context).loadString(assetPath),
      builder: (context, snapshot) {
        if (snapshot.hasError) return fallback;
        final markup = snapshot.data;
        // Nothing yet: hold the space rather than flashing the fallback for a
        // frame and then replacing it.
        if (markup == null) return SizedBox(width: width, height: height);
        return SvgPicture.string(
          markup,
          fit: fit,
          width: width,
          height: height,
        );
      },
    );
  }
}

/// The default placeholder: a lifted navy panel with a centered glyph.
class AssetPlaceholder extends StatelessWidget {
  const AssetPlaceholder({
    this.icon = Icons.image_outlined,
    this.label,
    super.key,
  });

  final IconData icon;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: context.gradients.surfacePanel),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: context.colors.onNavyFaint),
            if (label != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                label!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.colors.onNavyFaint,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
