import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../../../features/portfolio_content/domain/entities/image_ref.dart';

/// What the picker hands back: the ref to store right now, plus what the form
/// needs to offer promoting it to a bundled asset.
class PickedImage {
  const PickedImage({
    required this.ref,
    required this.fileName,
    required this.byteCount,
  });

  final ImageRef ref;

  /// The file's original name, e.g. `home_dark.png`.
  final String fileName;
  final int byteCount;
}

/// A picked file's raw bytes, before anything has been done with them —
/// [ImagePickerService.pickBytes] uses this for a caller that needs to crop
/// or otherwise transform the image before it becomes an [ImageRef].
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
/// Always returns an *embedded* ref. Web has no writable `assets/` folder, so
/// embedding is the only form that renders the moment a file is picked. Turning
/// it into an `assets/...` path is a deliberate second step the form offers,
/// because that path resolves only once the file is copied into the bundle and
/// the app rebuilt.
@lazySingleton
class ImagePickerService {
  ImagePickerService(this._picker);

  final ImagePicker _picker;

  /// Null when the picker is dismissed without choosing a file.
  Future<PickedImage?> pick() async {
    final picked = await pickBytes();
    if (picked == null) return null;

    return PickedImage(
      // A full data URI rather than bare base64: it keeps the payload
      // self-describing, which is how `MediaRef.isAnimatedImage` can tell a GIF
      // from a still. `AppImage` strips the prefix before decoding.
      ref: ImageRef.embedded(
        'data:${picked.mime};base64,${base64Encode(picked.bytes)}',
      ),
      fileName: picked.fileName,
      byteCount: picked.bytes.length,
    );
  }

  /// The raw bytes of a picked file, before anything decides what to do with
  /// them. [pick] is [pickBytes] plus the embed step every other caller
  /// wants; a caller that needs to crop first — [ProfilePhotoField] — uses
  /// this directly and embeds only the cropped result.
  ///
  /// [maxDimension] and [imageQuality] are passed straight to the platform
  /// picker, which resizes/recompresses *before* handing bytes back — on web
  /// this is a canvas resize (`image_picker_for_web` implements both), not a
  /// no-op, so a caller that never needs full resolution should always set
  /// these rather than shrinking the result afterwards. [pick] leaves them
  /// unset, since `MediaRefField` callers (screenshots, feature graphics)
  /// legitimately want the original; [ProfilePhotoField] does not — a
  /// multi-megapixel source photo is exactly what made its crop editor feel
  /// laggy, being decoded and repainted at full resolution on every drag
  /// frame.
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

  /// Where a picked file should live once copied into the bundle.
  ///
  /// Sanitised because a picked name can carry spaces, capitals or non-latin
  /// characters, none of which survive as an asset key. `assets/$folder/` —
  /// not `assets/images/$folder/` — matches the folder pubspec.yaml actually
  /// declares (`assets/projects/`, the only [MediaRefField.assetFolder] every
  /// call site uses); the `images/` segment pointed at a directory that was
  /// never declared, so a pinned file 404'd no matter where it was copied.
  static String suggestedAssetPath(String folder, String fileName) {
    final safe = fileName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9._-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    return 'assets/$folder/$safe';
  }

  /// Embedded images live in `shared_preferences`, which on web is
  /// `localStorage` — roughly 5 MB for the whole site. Past this the form warns
  /// and points at the asset path instead.
  static const int embeddedWarnBytes = 700 * 1024;

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
