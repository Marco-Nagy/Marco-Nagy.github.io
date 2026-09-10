import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../di/di.dart';
import '../../../features/portfolio_content/domain/entities/image_ref.dart';
import '../../../features/portfolio_content/domain/entities/media_ref.dart';
import '../../localization/lang_keys.dart';
import '../../services/media/cloudinary_upload_service.dart';
import '../../services/media/image_picker_service.dart';
import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import '../../utils/media_url.dart';
import '../../utils/youtube_thumbnail.dart';
import '../common/app_media.dart';
import '../common/underline_text_field.dart';
import 'admin_choice_field.dart';
import 'admin_confirm_dialog.dart';

/// Edits one [MediaRef]: pick what kind of thing it is, paste a path or a URL,
/// and watch the thumbnail resolve underneath.
///
/// The preview is the point. A YouTube link resolves to the still YouTube
/// already hosts, and a video file opens far enough to show its first frame —
/// so "did I paste the right link" is answered on the spot instead of after a
/// save and a page reload.
class MediaRefField extends StatefulWidget {
  const MediaRefField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.assetFolder = 'projects',
    this.previewAspectRatio = 1,
    super.key,
  });

  final String label;
  final MediaRef value;
  final ValueChanged<MediaRef> onChanged;

  /// Folder under `assets/` a picked file is suggested for.
  final String assetFolder;

  /// Shape of the preview box, so a feature graphic previews wide and a phone
  /// screenshot previews tall rather than both lying about the crop.
  final double previewAspectRatio;

  @override
  State<MediaRefField> createState() => _MediaRefFieldState();
}

class _MediaRefFieldState extends State<MediaRefField> {
  late MediaRef _value = widget.value;

  /// What the preview draws. It trails [_value] by [_previewDelay] so that
  /// typing a URL does not open a video player for every half-finished prefix.
  late MediaRef _preview = widget.value;

  late final TextEditingController _source = TextEditingController(
    text: _sourceOf(widget.value),
  );

  Timer? _debounce;

  /// Set when a share URL was rewritten to its download form, so the box
  /// changing under the cursor is explained rather than just surprising.
  bool _normalized = false;

  /// Guards against a second picker opening while one is already up.
  bool _picking = false;

  /// True right after [_pinAsAsset] fills the box with a path — the file it
  /// names may not exist in the project yet, so the reminder to copy it in
  /// stays up until something else changes the source (typing, re-picking).
  bool _pendingAssetCopy = false;

  /// Set by [_pickAndUpload] when the upload itself fails — a size rejection,
  /// no configuration, or whatever Cloudinary's API reported. Cleared the
  /// moment anything else changes the field, so a stale error does not sit
  /// under a box that has since been fixed some other way.
  String? _uploadError;

  static const Duration _previewDelay = Duration(milliseconds: 600);

  /// The picked-file flow already fills this box with the suggested asset
  /// path the moment a file is chosen (see [_pickFile]); an embedded ref that
  /// reaches this field some other way — loaded from storage before ever
  /// being pinned — has no path yet, and showing its raw base64 payload here
  /// instead would fill the box with an unreadable megabyte of text.
  static String _sourceOf(MediaRef media) {
    if (!media.isVideo && media.image.isEmbedded) return '';
    return media.isVideo ? media.videoUrl : media.image.value;
  }

  /// An http source is a network image; anything else is a bundled asset. Same
  /// rule the rest of the app reads [ImageRef] by.
  static ImageRef _imageFrom(String value) => value.startsWith('http')
      ? ImageRef.network(value)
      : ImageRef.asset(value);

  @override
  void dispose() {
    _debounce?.cancel();
    _source.dispose();
    super.dispose();
  }

  void _emit(MediaRef next) {
    setState(() {
      _value = next;
      _normalized = false;
    });
    widget.onChanged(next);
    _schedulePreview();
  }

  /// The preview trails typing on purpose: without the pause, every half-typed
  /// prefix of a URL would open its own video controller. That same pause is
  /// where a share link gets rewritten to the form that actually serves bytes,
  /// since doing it mid-keystroke would fight the cursor.
  void _schedulePreview() {
    _debounce?.cancel();
    _debounce = Timer(_previewDelay, () {
      if (!mounted) return;

      final direct = _value.kind == MediaKind.videoFile
          ? MediaUrl.directDownloadFor(_value.videoUrl)
          : null;

      if (direct == null) {
        setState(() => _preview = _value);
        return;
      }

      final next = _value.copyWith(videoUrl: direct);
      _source.text = direct;
      widget.onChanged(next);
      setState(() {
        _value = next;
        _preview = next;
        _normalized = true;
      });
    });
  }

  void _onTyped(String text) {
    final value = text.trim();
    _pendingAssetCopy = false;
    _emit(
      _value.isVideo
          ? _value.copyWith(videoUrl: value)
          : _value.copyWith(image: _imageFrom(value)),
    );
  }

  /// Picks a file off the device and uploads it to Cloudinary, storing the
  /// returned delivery URL as a network [ImageRef] — a real upload, not the
  /// asset-path guess this used to make. That guess assumed the exact file
  /// had already been copied into the project by hand before picking it
  /// here, which was rarely true; this finishes the job itself instead of
  /// asking the admin to.
  Future<void> _pickAndUpload() async {
    if (_picking) return;
    setState(() {
      _picking = true;
      _uploadError = null;
    });
    try {
      final picked = await getIt<ImagePickerService>().pickBytes();
      if (picked == null || !mounted) return;

      final url = await getIt<CloudinaryUploadService>().uploadImage(
        picked.bytes,
        fileName: picked.fileName,
      );
      if (!mounted) return;

      _source.text = url;

      final next = _value.copyWith(
        kind: MediaKind.image,
        image: ImageRef.network(url),
        videoUrl: '',
      );
      setState(() {
        _value = next;
        _preview = next;
        _normalized = false;
        _pendingAssetCopy = false;
      });
      widget.onChanged(next);
    } on CloudinaryUploadException catch (error) {
      if (mounted) setState(() => _uploadError = error.message);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  /// Swaps the embedded bytes for the `assets/...` path a release build ships.
  /// The path only resolves after the file is copied in and the app rebuilt,
  /// which is why this is a separate, deliberate press — confirmed rather
  /// than instant, since the file disappears everywhere it's used the moment
  /// this runs and stays gone until that copy actually happens.
  Future<void> _pinAsAsset() async {
    final path = _source.text.trim();
    if (path.isEmpty) return;

    final confirmed = await AdminConfirmDialog.show(
      context,
      title: context.translate(LangKeys.fieldMediaPin),
      body: context.translate(LangKeys.fieldMediaPinWarning),
      confirmLabel: context.translate(LangKeys.fieldMediaPin),
    );
    if (!confirmed || !mounted) return;

    _pendingAssetCopy = true;
    _emit(_value.copyWith(image: _imageFrom(path)));
  }

  void _setKind(MediaKind kind) {
    if (kind == _value.kind) return;

    // The text in the box means something in either mode — a path or a URL — so
    // carry it across the switch rather than making it be retyped.
    final text = _source.text.trim();
    _emit(
      kind == MediaKind.image
          ? _value.copyWith(kind: kind, image: _imageFrom(text), videoUrl: '')
          : _value.copyWith(kind: kind, videoUrl: text),
    );
  }

  String _kindLabel(MediaKind kind) => context.translate(switch (kind) {
    MediaKind.image => LangKeys.mediaKindImage,
    MediaKind.videoFile => LangKeys.mediaKindVideoFile,
    MediaKind.videoEmbed => LangKeys.mediaKindVideoEmbed,
  });

  /// The one case worth calling out: a YouTube ref whose URL yields no video id
  /// will never play and never show a thumbnail, and nothing else on screen
  /// says so.
  bool get _unresolvedEmbed =>
      _value.kind == MediaKind.videoEmbed &&
      _value.videoUrl.trim().isNotEmpty &&
      YoutubeThumbnail.forUrl(_value.videoUrl) == null;

  bool get _unsupportedHost =>
      _value.kind == MediaKind.videoFile &&
      MediaUrl.isUnsupportedHost(_value.videoUrl);

  /// Set when what is in the box is not a URL or an asset path at all — a
  /// half-pasted link, or a clipboard that brought a shell command with it.
  /// Caught here rather than left to the player, which reports it from deep
  /// inside the web engine as an "Illegal scheme character".
  String? get _malformedSource {
    if (_value.kind != MediaKind.videoFile) return null;
    if (_value.videoUrl.trim().isEmpty) return null;
    return MediaUrl.rejectionFor(_value.videoUrl);
  }

  /// A hosted file has to be readable without signing in, because the player is
  /// given no credentials to sign in with.
  bool get _needsPublicLink =>
      _value.kind == MediaKind.videoFile &&
      _value.videoUrl.trim().startsWith('http') &&
      _malformedSource == null;

  String get _sourceHint => switch (_value.kind) {
    MediaKind.image => 'assets/projects/cover.png',
    MediaKind.videoFile => 'https://cloud.example.com/s/AbC123/download',
    MediaKind.videoEmbed => 'https://youtu.be/dQw4w9WgXcQ',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AdminChoiceField<MediaKind>(
          label: widget.label,
          value: _value.kind,
          options: MediaKind.values,
          labelOf: _kindLabel,
          onChanged: _setKind,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _Preview(
              media: _preview,
              aspectRatio: widget.previewAspectRatio,
              busy: _picking,
              // Tapping the picture to replace the picture is the gesture
              // everyone tries first.
              onTap: _pickAndUpload,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  UnderlineTextField(
                    label: context.translate(
                      _value.isVideo
                          ? LangKeys.fieldMediaVideoUrl
                          : LangKeys.fieldMediaImagePath,
                    ),
                    controller: _source,
                    hint: _sourceHint,
                    onChanged: _onTyped,
                  ),
                  if (_unresolvedEmbed)
                    _Note(
                      text: context.translate(
                        LangKeys.fieldMediaYoutubeUnresolved,
                      ),
                      color: colors.danger,
                    ),
                  if (_unsupportedHost)
                    _Note(
                      text: context.translate(
                        LangKeys.fieldMediaHostUnsupported,
                      ),
                      color: colors.danger,
                    ),
                  // The reason itself, not a translated stand-in: it names
                  // what is wrong with this exact string, and this whole
                  // surface is debug-only anyway.
                  if (_malformedSource != null)
                    _Note(text: _malformedSource!, color: colors.danger),
                  if (_normalized)
                    _Note(
                      text: context.translate(
                        LangKeys.fieldMediaLinkNormalized,
                      ),
                      color: colors.accent,
                    ),
                  if (_needsPublicLink && !_unsupportedHost)
                    _Note(
                      text: context.translate(
                        LangKeys.fieldMediaNeedsPublicLink,
                      ),
                      color: colors.onNavyFaint,
                    ),
                  if (_uploadError != null)
                    _Note(text: _uploadError!, color: colors.danger),
                  // Pinning assumes the file is already in the project; this
                  // is the one chance to catch "actually it isn't yet" before
                  // the preview quietly shows broken.
                  if (_pendingAssetCopy)
                    _Note(
                      text: context.translate(
                        LangKeys.fieldMediaPickPendingCopy,
                      ),
                      color: colors.onNavyFaint,
                    ),
                  // Shown as long as the Pin button is: pinning is silent
                  // and immediate, so the warning has to land before the
                  // press, not after the file has already vanished.
                  if (_value.image.isEmbedded)
                    _Note(
                      text: context.translate(LangKeys.fieldMediaPinWarning),
                      color: colors.onNavyFaint,
                    ),
                  Wrap(
                    spacing: 4.w,
                    children: <Widget>[
                      _MiniButton(
                        icon: Icons.cloud_upload_outlined,
                        label: context.translate(LangKeys.fieldMediaPick),
                        color: colors.accent,
                        onPressed: _picking ? null : _pickAndUpload,
                      ),
                      // Legacy repair only: a real upload never leaves the
                      // field embedded, so this can only appear for content
                      // picked before Cloudinary upload existed.
                      if (_value.image.isEmbedded)
                        _MiniButton(
                          icon: Icons.push_pin_outlined,
                          label: context.translate(LangKeys.fieldMediaPin),
                          color: colors.accent,
                          onPressed: _pinAsAsset,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.media,
    required this.aspectRatio,
    required this.busy,
    required this.onTap,
  });

  final MediaRef media;
  final double aspectRatio;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: 104.w,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: _Tappable(
          busy: busy,
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: colors.divider),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: AppMedia(
                media: media,
                // Resting, not running: the editor shows what the media is, it is
                // not a place to watch it. preload is what turns a URL into a
                // visible frame without playing it.
                playing: false,
                preload: true,
                allowPlatformView: false,
                fallback: Center(
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 26.r,
                    color: colors.onNavyFaint,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Wraps the preview so tapping it opens the picker, with a spinner while one
/// is up. Separate from [_Preview] only to keep the busy overlay out of the
/// decoration tree.
class _Tappable extends StatelessWidget {
  const _Tappable({
    required this.busy,
    required this.onTap,
    required this.child,
  });

  final bool busy;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: busy ? null : onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            child,
            if (busy)
              ColoredBox(
                color: colors.pageTop.withValues(alpha: 0.6),
                child: Center(
                  child: SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.accent,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A one-line note under the URL box. Colour carries the weight — danger for
/// "this will not work", accent for "something changed", faint for a caution.
class _Note extends StatelessWidget {
  const _Note({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Text(text, style: MyFonts.regular12.copyWith(color: color)),
    );
  }
}

/// A compact text button for the actions that sit under the source box.
class _MiniButton extends StatelessWidget {
  const _MiniButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        minimumSize: Size(0, 34.h),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon, size: 16.r, color: color),
      label: Text(label, style: MyFonts.regular12.copyWith(color: color)),
    );
  }
}
