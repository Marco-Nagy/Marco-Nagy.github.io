import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../di/di.dart';
import '../../../features/portfolio_content/domain/entities/image_ref.dart';
import '../../../features/portfolio_content/domain/entities/media_ref.dart';
import '../../localization/lang_keys.dart';
import '../../services/media/image_picker_service.dart';
import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import '../../utils/media_url.dart';
import '../../utils/youtube_thumbnail.dart';
import '../common/app_media.dart';
import '../common/underline_text_field.dart';
import 'admin_choice_field.dart';

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

  /// Folder under `assets/images/` a picked file is suggested for.
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

  /// Size of an image picked this session, so the storage warning applies to
  /// exactly the payload it was measured from.
  int? _pickedBytes;

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
    _emit(
      _value.isVideo
          ? _value.copyWith(videoUrl: value)
          : _value.copyWith(image: _imageFrom(value)),
    );
  }

  /// Reads a file off the device and embeds it, so the result is on screen
  /// immediately — the only option on web, which has no writable `assets/`.
  /// The box below is filled with where that file *should* live once copied
  /// into the bundle, ready for [_pinAsAsset].
  Future<void> _pickFile() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final picked = await getIt<ImagePickerService>().pick();
      if (picked == null || !mounted) return;

      _source.text = ImagePickerService.suggestedAssetPath(
        widget.assetFolder,
        picked.fileName,
      );
      _pickedBytes = picked.byteCount;

      final next = _value.copyWith(
        kind: MediaKind.image,
        image: picked.ref,
        videoUrl: '',
      );
      setState(() {
        _value = next;
        _preview = next;
        _normalized = false;
      });
      widget.onChanged(next);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  /// Swaps the embedded bytes for the `assets/...` path a release build ships.
  /// The path only resolves after the file is copied in and the app rebuilt,
  /// which is why this is a separate, deliberate press.
  void _pinAsAsset() {
    final path = _source.text.trim();
    if (path.isEmpty) return;
    _pickedBytes = null;
    _emit(_value.copyWith(image: _imageFrom(path)));
  }

  bool get _isHeavyEmbed =>
      _value.image.isEmbedded &&
      (_pickedBytes ?? 0) > ImagePickerService.embeddedWarnBytes;

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

  /// A hosted file has to be readable without signing in, because the player is
  /// given no credentials to sign in with.
  bool get _needsPublicLink =>
      _value.kind == MediaKind.videoFile &&
      _value.videoUrl.trim().startsWith('http');

  String get _sourceHint => switch (_value.kind) {
    MediaKind.image => 'assets/images/projects/cover.png',
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
              onTap: _pickFile,
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
                  if (_isHeavyEmbed)
                    _Note(
                      text: context.translate(LangKeys.fieldMediaHeavyEmbed),
                      color: colors.danger,
                    ),
                  Wrap(
                    spacing: 4.w,
                    children: <Widget>[
                      _MiniButton(
                        icon: Icons.image_outlined,
                        label: context.translate(LangKeys.fieldMediaPick),
                        color: colors.accent,
                        onPressed: _picking ? null : _pickFile,
                      ),
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
