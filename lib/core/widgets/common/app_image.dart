import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../features/portfolio_content/domain/entities/image_ref.dart';
import 'safe_asset_image.dart';

/// Renders an [ImageRef] whatever its source, degrading to [fallback] rather
/// than throwing when the file is missing.
///
/// A missing asset is the normal case while authoring: an image picked in debug
/// is written to `assets/<section>/` but is not in the bundle until the next
/// build, so [AppImage] falls back instead of showing a grey exception box.
class AppImage extends StatelessWidget {
  const AppImage({
    required this.image,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    super.key,
  });

  final ImageRef image;
  final Widget fallback;
  final BoxFit fit;
  final double? width;
  final double? height;

  /// Physical-pixel decode target for [width]/[height], so the decoder never
  /// does more work than the box it's painted into calls for. Without this a
  /// full-resolution photo (or, far worse, every frame of a full-resolution
  /// GIF) gets decoded at its source size no matter how small it's drawn —
  /// the more GIF screenshots a project has, the more that waste compounds,
  /// which is exactly the shape of lag this was chasing.
  int? _cacheDim(double? logical, double dpr) =>
      logical == null ? null : (logical * dpr).round();

  @override
  Widget build(BuildContext context) {
    if (image.isEmpty) return fallback;

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = _cacheDim(width, dpr);
    final cacheHeight = _cacheDim(height, dpr);

    return switch (image.kind) {
      ImageSourceKind.asset => SafeAssetImage(
        assetPath: image.value,
        fallback: fallback,
        fit: fit,
        width: width,
        height: height,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
      ),
      ImageSourceKind.network => Image.network(
        image.value,
        fit: fit,
        width: width,
        height: height,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
      ImageSourceKind.embedded => _EmbeddedImage(
        base64Data: image.value,
        fallback: fallback,
        fit: fit,
        width: width,
        height: height,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
      ),
    };
  }
}

class _EmbeddedImage extends StatefulWidget {
  const _EmbeddedImage({
    required this.base64Data,
    required this.fallback,
    required this.fit,
    this.width,
    this.height,
    this.cacheWidth,
    this.cacheHeight,
  });

  final String base64Data;
  final Widget fallback;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  State<_EmbeddedImage> createState() => _EmbeddedImageState();
}

class _EmbeddedImageState extends State<_EmbeddedImage> {
  /// Decoded once per distinct payload and held here rather than redecoded in
  /// `build` — a screenshot editor rebuilds this widget on every slider tick
  /// (rotation, scale, offset) with the *same* base64 string, and handing
  /// `Image.memory` a freshly decoded `Uint8List` each time defeats Flutter's
  /// image cache (it keys on the bytes object, not their content), forcing a
  /// full re-decode every frame. For a multi-frame GIF that is expensive
  /// enough to make the sliders feel laggy; keeping the same bytes instance
  /// across rebuilds lets the cache recognise it as the same image.
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = _decode(widget.base64Data);
  }

  @override
  void didUpdateWidget(covariant _EmbeddedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.base64Data != widget.base64Data) {
      _bytes = _decode(widget.base64Data);
    }
  }

  /// Strips a `data:image/png;base64,` prefix if the value carries one.
  static Uint8List? _decode(String base64Data) {
    try {
      final comma = base64Data.indexOf(',');
      final payload = comma == -1
          ? base64Data
          : base64Data.substring(comma + 1);
      return base64Decode(payload);
    } on Object {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    if (bytes == null) return widget.fallback;
    return Image.memory(
      bytes,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      cacheWidth: widget.cacheWidth,
      cacheHeight: widget.cacheHeight,
      errorBuilder: (context, error, stackTrace) => widget.fallback,
    );
  }
}
