import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../di/di.dart';
import '../../localization/lang_keys.dart';
import '../../services/media/cloudinary_upload_service.dart';
import '../../services/media/document_picker_service.dart';
import '../../services/media/image_picker_service.dart';
import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import '../common/pill_button.dart';
import '../common/underline_text_field.dart';

/// A text field holding a URL, plus a button that uploads a file to
/// Cloudinary and fills the field with the result.
///
/// The box stays editable rather than being replaced by the picker outright,
/// unlike [ProfilePhotoField]: a CV or a certificate scan is as often already
/// hosted somewhere as it is a local file, and pasting that link is a
/// legitimate way to set this. The upload is the convenience, not the only
/// route.
class UrlUploadField extends StatefulWidget {
  const UrlUploadField({
    required this.label,
    required this.controller,
    required this.buttonLabel,
    required this.icon,
    required this.pickAndUpload,
    super.key,
  });

  /// Factory for the CV's hosted-PDF field.
  factory UrlUploadField.pdf({
    required String label,
    required TextEditingController controller,
    Key? key,
  }) => UrlUploadField(
    key: key,
    label: label,
    controller: controller,
    buttonLabel: LangKeys.adminUploadCv,
    icon: Icons.picture_as_pdf_outlined,
    pickAndUpload: _pickAndUploadPdf,
  );

  /// Factory for an image field that stores a plain URL string rather than a
  /// full `ImageRef` — the certificate scan.
  factory UrlUploadField.image({
    required String label,
    required TextEditingController controller,
    Key? key,
  }) => UrlUploadField(
    key: key,
    label: label,
    controller: controller,
    buttonLabel: LangKeys.fieldMediaPick,
    icon: Icons.cloud_upload_outlined,
    pickAndUpload: _pickAndUploadImage,
  );

  final String label;
  final TextEditingController controller;

  /// A [LangKeys] entry, resolved at build time.
  final String buttonLabel;
  final IconData icon;

  /// Returns the uploaded URL, or null when the picker was dismissed.
  /// Throws [CloudinaryUploadException] when the upload itself fails.
  final Future<String?> Function() pickAndUpload;

  static Future<String?> _pickAndUploadPdf() async {
    final picked = await getIt<DocumentPickerService>().pickPdf();
    if (picked == null) return null;
    return getIt<CloudinaryUploadService>().uploadDocument(
      picked.bytes,
      fileName: picked.fileName,
    );
  }

  static Future<String?> _pickAndUploadImage() async {
    final picked = await getIt<ImagePickerService>().pickBytes();
    if (picked == null) return null;
    return getIt<CloudinaryUploadService>().uploadImage(
      Uint8List.fromList(picked.bytes),
      fileName: picked.fileName,
    );
  }

  @override
  State<UrlUploadField> createState() => _UrlUploadFieldState();
}

class _UrlUploadFieldState extends State<UrlUploadField> {
  bool _busy = false;
  String? _error;

  Future<void> _upload() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final url = await widget.pickAndUpload();
      if (url == null || !mounted) return;
      // Assigning `.text` rather than calling an onChanged: this field is
      // driven by the form's own controller, which the form reads on save.
      widget.controller.text = url;
    } on CloudinaryUploadException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        UnderlineTextField(
          label: widget.label,
          controller: widget.controller,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: 8.h),
        PillButton(
          label: context.translate(
            _busy ? LangKeys.commonLoading : widget.buttonLabel,
          ),
          variant: PillButtonVariant.outlined,
          icon: widget.icon,
          showArrow: false,
          dense: true,
          onPressed: _busy ? null : _upload,
        ),
        if (_error != null)
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Text(
              _error!,
              style: MyFonts.regular12.copyWith(color: context.colors.danger),
            ),
          ),
        SizedBox(height: 12.h),
      ],
    );
  }
}
