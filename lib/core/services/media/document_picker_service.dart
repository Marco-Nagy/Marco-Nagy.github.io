import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:injectable/injectable.dart';

/// A picked document's bytes and original filename.
class PickedDocument {
  const PickedDocument({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

/// Reads a PDF off the device — the CV, and nothing else so far.
///
/// Separate from [ImagePickerService] because `image_picker` cannot open a
/// PDF at all: it is an image/video picker on every platform. `file_picker`
/// is used only here, for that reason; the photo fields stay on
/// `image_picker` for its resize options, which `file_picker` has no
/// equivalent for.
@lazySingleton
class DocumentPickerService {
  const DocumentPickerService();

  /// Null when the picker is dismissed without choosing a file.
  ///
  /// `readAsBytes()` rather than a `bytes` field: file_picker 12 dropped the
  /// eager-loading `withData` flag, and reads on demand instead — which is
  /// also the only way to get content on web, where a picked file has no
  /// path to open afterwards.
  Future<PickedDocument?> pickPdf() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: <String>['pdf'],
    );
    if (file == null) return null;

    return PickedDocument(
      bytes: await file.readAsBytes(),
      fileName: file.name,
    );
  }
}
