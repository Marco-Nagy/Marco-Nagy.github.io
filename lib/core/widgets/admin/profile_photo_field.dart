import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../di/di.dart';
import '../../../features/portfolio_content/domain/entities/image_ref.dart';
import '../../localization/lang_keys.dart';
import '../../services/media/cloudinary_upload_service.dart';
import '../../services/media/image_picker_service.dart';
import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import '../common/app_image.dart';
import '../common/app_snack_bar.dart';
import '../common/pill_button.dart';
import 'admin_confirm_dialog.dart';
import 'admin_svg_icons.dart';
import 'crop_photo_dialog.dart';

/// Edits one of [SiteContent]'s two photo fields: pick a file, crop it to
/// [shape], and upload the result to Cloudinary — the same real-upload
/// convention [MediaRefField] uses for project media, not the embed-then-pin
/// workaround either field used before Phase 6b.
///
/// Deliberately no manual URL/path entry, unlike [MediaRefField]: a headshot
/// only ever comes from a file the admin has on hand, so the box that used to
/// take a pasted path bought nothing over a picker and could be left pointing
/// at a path that never existed.
class ProfilePhotoField extends StatefulWidget {
  const ProfilePhotoField({
    required this.label,
    required this.value,
    required this.shape,
    required this.onChanged,
    super.key,
  });

  final String label;
  final ImageRef value;
  final PhotoCropShape shape;
  final ValueChanged<ImageRef> onChanged;

  @override
  State<ProfilePhotoField> createState() => _ProfilePhotoFieldState();
}

class _ProfilePhotoFieldState extends State<ProfilePhotoField> {
  final ImagePickerService _picker = getIt<ImagePickerService>();

  /// Guards against a second picker opening while one is already up — the
  /// same guard [MediaRefField] keeps for the same reason.
  bool _busy = false;

  /// Set when the upload itself fails — a size rejection, no configuration,
  /// or whatever Cloudinary's API reported. Cleared the moment anything else
  /// changes the field.
  String? _uploadError;

  /// Well above anything this field ever displays (the hero photo tops out
  /// around a few hundred logical pixels, times DPR), and well below a raw
  /// phone photo (often 3000–4000px). Handing the crop editor anything larger
  /// than this bought no visible quality and made it decode and repaint a
  /// multi-megapixel image on every drag frame.
  static const double _maxPickDimension = 1600;
  static const int _pickImageQuality = 85;

  Future<void> _pickAndCrop() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _uploadError = null;
    });

    try {
      final picked = await _picker.pickBytes(
        maxDimension: _maxPickDimension,
        imageQuality: _pickImageQuality,
      );
      if (picked == null || !mounted) return;

      final cropped = await CropPhotoDialog.open(
        context,
        imageBytes: picked.bytes,
        shape: widget.shape,
      );
      if (cropped == null || !mounted) return;

      // The crop dialog always hands back a PNG (see CropPhotoDialog's own
      // `toByteData(format: ui.ImageByteFormat.png)`), regardless of the
      // source file's own format — the filename is renamed to match so
      // Cloudinary is not told a JPEG's name for PNG bytes.
      final pngName = '${picked.fileName.split('.').first}.png';
      final url = await getIt<CloudinaryUploadService>().uploadImage(
        cropped,
        fileName: pngName,
      );
      if (!mounted) return;

      widget.onChanged(ImageRef.network(url));
    } on CloudinaryUploadException catch (error) {
      if (mounted) setState(() => _uploadError = error.message);
    } on Object catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        context.translate(LangKeys.commonError),
        kind: SnackKind.error,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    final confirmed = await AdminConfirmDialog.show(context);
    if (!confirmed || !mounted) return;
    setState(() => _uploadError = null);
    widget.onChanged(const ImageRef());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasValue = !widget.value.isEmpty;
    final diameter = 72.r;

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ClipRRect(
            borderRadius: widget.shape == PhotoCropShape.circle
                ? BorderRadius.circular(diameter)
                : BorderRadius.circular(12.r),
            child: SizedBox.square(
              dimension: diameter,
              child: AppImage(
                image: widget.value,
                width: diameter,
                height: diameter,
                fallback: DecoratedBox(
                  decoration: BoxDecoration(color: colors.surfaceHigh),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: colors.onNavyFaint,
                    size: diameter * 0.5,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  widget.label,
                  style: MyFonts.caps10.copyWith(color: colors.onNavyFaint),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 8.h,
                  children: <Widget>[
                    PillButton(
                      label: context.translate(
                        hasValue
                            ? LangKeys.adminChangePhoto
                            : LangKeys.adminChoosePhoto,
                      ),
                      variant: PillButtonVariant.outlined,
                      svgIcon: AdminSvgIcons.add,
                      showArrow: false,
                      dense: true,
                      onPressed: _busy ? null : _pickAndCrop,
                    ),
                    if (hasValue)
                      PillButton(
                        label: context.translate(LangKeys.adminRemovePhoto),
                        variant: PillButtonVariant.outlined,
                        showArrow: false,
                        dense: true,
                        onPressed: _busy ? null : _remove,
                      ),
                  ],
                ),
                if (_uploadError != null)
                  Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Text(
                      _uploadError!,
                      style: MyFonts.regular12.copyWith(color: colors.danger),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
