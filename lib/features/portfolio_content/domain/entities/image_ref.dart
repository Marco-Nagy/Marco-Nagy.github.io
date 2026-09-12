import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_ref.freezed.dart';
part 'image_ref.g.dart';

enum ImageSourceKind {
  /// A path into the bundled `assets/` folder — the shipping form.
  asset,

  /// An absolute http(s) URL.
  network,

  /// Base64 bytes captured by image_picker in debug. Handy while authoring, but
  /// excluded from the exported bundle by default because it bloats the JSON.
  embedded,
}

/// Points at an image without caring where it lives.
@freezed
abstract class ImageRef with _$ImageRef {
  const factory ImageRef({
    @Default(ImageSourceKind.asset) ImageSourceKind kind,
    @Default('') String value,
  }) = _ImageRef;

  const ImageRef._();

  factory ImageRef.fromJson(Map<String, dynamic> json) =>
      _$ImageRefFromJson(json);

  // Static rather than factories: freezed reads redirecting factories as union
  // cases, and these are just convenience wrappers over the one constructor.
  static ImageRef asset(String path) => ImageRef(value: path);

  static ImageRef network(String url) =>
      ImageRef(kind: ImageSourceKind.network, value: url);

  static ImageRef embedded(String base64) =>
      ImageRef(kind: ImageSourceKind.embedded, value: base64);

  /// Reads a stored string that could be either kind: an `http(s)` source is
  /// a network image, anything else a bundled asset.
  ///
  /// Lives here rather than in each form because it is a rule about what a
  /// stored value *means* — a Cloudinary URL saved into a field that used to
  /// hold only `assets/...` paths has to resolve as a network image
  /// everywhere it is read, not just wherever someone remembered to check.
  static ImageRef fromSource(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return const ImageRef();
    return trimmed.startsWith('http')
        ? ImageRef.network(trimmed)
        : ImageRef.asset(trimmed);
  }

  bool get isEmpty => value.trim().isEmpty;
  bool get isEmbedded => kind == ImageSourceKind.embedded;
}
