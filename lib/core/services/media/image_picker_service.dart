import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

/// A picked file's raw bytes, before anything has been done with them —
/// every caller crops, uploads, or both, so raw bytes are the only shape
/// this service hands back.
class PickedImageBytes {
  const PickedImageBytes({
    required this.bytes,
    required this.mime,
    required this.fileName,
  });

  final Uint8List bytes;
  final String mime;
  final String fileName;
}

/// The single place the app reads an image off the device. Debug-only in
/// practice: every caller sits behind [AdminGate].
///
/// Hands back raw bytes and nothing else. It used to also offer an embedded
/// (base64) ref and a suggested `assets/...` path to copy the file to by
/// hand — both were workarounds for having nowhere to put a picked file, and
/// both went away when uploads started going to Cloudinary.
@lazySingleton
class ImagePickerService {
  ImagePickerService(this._picker);

  final ImagePicker _picker;

  /// The raw bytes of a picked file, for a caller to crop, upload, or both.
  ///
  /// [maxDimension] and [imageQuality] are passed straight to the platform
  /// picker, which resizes/recompresses *before* handing bytes back — on web
  /// this is a canvas resize (`image_picker_for_web` implements both), not a
  /// no-op, so a caller that never needs full resolution should always set
  /// these rather than shrinking the result afterwards. `MediaRefField`
  /// leaves them unset, since a screenshot or feature graphic legitimately
  /// wants the original; [ProfilePhotoField] does not — a multi-megapixel
  /// source photo is exactly what made its crop editor feel laggy, being
  /// decoded and repainted at full resolution on every drag frame.
  ///
  /// Null when the picker is dismissed without choosing a file.
  Future<PickedImageBytes?> pickBytes({
    double? maxDimension,
    int? imageQuality,
  }) async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxDimension,
      maxHeight: maxDimension,
      imageQuality: imageQuality,
    );
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    return PickedImageBytes(
      bytes: bytes,
      mime: file.mimeType ?? _mimeFor(file.name),
      fileName: file.name,
    );
  }

  static String _mimeFor(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;
    return switch (ext) {
      'gif' => 'image/gif',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'svg' => 'image/svg+xml',
      _ => 'image/jpeg',
    };
  }
}
