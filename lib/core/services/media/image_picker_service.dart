import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../../../features/portfolio_content/domain/entities/image_ref.dart';

/// What the picker hands back: the ref to store right now, plus the details the
/// form needs to offer promoting it to a bundled asset.
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

/// The single place the app reads an image off the device. Debug-only: nothing
/// in a release build reaches it, because every caller sits behind [AdminGate].
///
/// Always returns an *embedded* (base64) ref. Web has no writable `assets/`
/// folder, so embedding is the only form that renders the moment it is picked.
/// Turning it into an `assets/...` path is a deliberate second step the form
/// offers, because that path resolves only after the file is copied into the
/// bundle and the app rebuilt.
@lazySingleton
class ImagePickerService {
  ImagePickerService(this._picker);

  final ImagePicker _picker;

  /// Null when the picker is dismissed without choosing a file.
  Future<PickedImage?> pick() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    return PickedImage(
      ref: ImageRef.embedded(base64Encode(bytes)),
      fileName: file.name,
      byteCount: bytes.length,
    );
  }

  /// Where a picked file should live once copied into the bundle.
  ///
  /// Sanitised because a picked name can carry spaces, capitals or non-latin
  /// characters, none of which survive as an asset key.
  static String suggestedAssetPath(String folder, String fileName) {
    final safe = fileName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9._-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    return 'assets/images/$folder/$safe';
  }

  /// Embedded images live in `shared_preferences`, which on web is
  /// `localStorage` — roughly 5 MB for the whole site. Past this the form warns
  /// and points at the asset path instead.
  static const int embeddedWarnBytes = 700 * 1024;
}
