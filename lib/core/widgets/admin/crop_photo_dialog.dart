import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../localization/lang_keys.dart';
import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';

/// The shape a picked photo is cropped to. The captured output is always a
/// square PNG regardless of shape — [circle] only changes the on-screen mask
/// during editing, matching how the photo actually renders (`ClipOval` on
/// the hero, `ClipRRect` on the About card).
enum PhotoCropShape { circle, square }

/// Crops a freshly picked photo before it becomes an [ImageRef].
///
/// Hand-rolled rather than built on a cropping package: the obvious choice,
/// `crop_your_image`, depends on the pure-Dart `image` package for decode,
/// crop and encode, and wraps that work in `compute()` — which does not run
/// on a real background thread on Flutter Web (Dart-for-web has no general
/// isolate spawning), so the pixel work still blocked the main thread there.
/// This editor never leaves native Flutter/Skia primitives: [Image.memory]
/// decodes, [Transform] composites the pan/zoom, and
/// [RenderRepaintBoundary.toImage] captures the result — no pure-Dart pixel
/// loop anywhere in the path.
///
/// A modal dialog rather than inline in the form: the crop editor is a full
/// gesture surface (drag, pinch-zoom) that would fight the form's own scroll
/// view if it sat inside it.
class CropPhotoDialog extends StatefulWidget {
  const CropPhotoDialog({
    required this.imageBytes,
    required this.shape,
    super.key,
  });

  final Uint8List imageBytes;
  final PhotoCropShape shape;

  /// Null when the admin cancels without cropping.
  static Future<Uint8List?> open(
    BuildContext context, {
    required Uint8List imageBytes,
    required PhotoCropShape shape,
  }) {
    return showDialog<Uint8List>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CropPhotoDialog(imageBytes: imageBytes, shape: shape),
    );
  }

  @override
  State<CropPhotoDialog> createState() => _CropPhotoDialogState();
}

class _CropPhotoDialogState extends State<CropPhotoDialog> {
  static const double _frameSize = 280;
  static const double _minUserScale = 1;
  static const double _maxUserScale = 4;

  final GlobalKey _boundaryKey = GlobalKey();

  /// Null while [_decode] is still resolving — decode is native (Skia's own
  /// codec, not `image`'s pure-Dart one) and fast, but it is still async, so
  /// the frame has nothing to size itself against until this completes.
  ui.Image? _image;

  /// Scales the image beyond the "cover the frame" size every editor starts
  /// at — 1.0 is exactly cover, never less, so the frame can never show a gap.
  double _userScale = 1;
  Offset _offset = Offset.zero;

  // Gesture-start snapshots, so a drag/pinch reads as a delta from where it
  // began rather than accumulating rounding error update over update.
  double _scaleAtGestureStart = 1;
  Offset _offsetAtGestureStart = Offset.zero;
  Offset? _focalPointAtGestureStart;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  Future<void> _decode() async {
    final codec = await ui.instantiateImageCodec(widget.imageBytes);
    final frame = await codec.getNextFrame();
    if (!mounted) return;
    setState(() => _image = frame.image);
  }

  /// The scale at which the image exactly covers the [_frameSize] square,
  /// before any zoom the admin has applied — the same rule `BoxFit.cover`
  /// uses, computed by hand because the transform below needs the resulting
  /// displayed size, not just a fit mode.
  double _coverScale(ui.Image image) =>
      _frameSize / math.min(image.width, image.height);

  void _onScaleStart(ScaleStartDetails details) {
    _scaleAtGestureStart = _userScale;
    _offsetAtGestureStart = _offset;
    _focalPointAtGestureStart = details.focalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final image = _image;
    if (image == null) return;

    final nextScale = (_scaleAtGestureStart * details.scale).clamp(
      _minUserScale,
      _maxUserScale,
    );
    final focalDelta = details.focalPoint - _focalPointAtGestureStart!;

    setState(() {
      _userScale = nextScale;
      _offset = _clampOffset(
        _offsetAtGestureStart + focalDelta,
        image,
        _userScale,
      );
    });
  }

  /// Keeps the frame fully covered: the displayed image can be panned until
  /// its edge reaches the frame's edge, never further — past that the frame
  /// would show blank space the capture step has no content for.
  Offset _clampOffset(Offset offset, ui.Image image, double userScale) {
    final displayedWidth = image.width * _coverScale(image) * userScale;
    final displayedHeight = image.height * _coverScale(image) * userScale;
    final maxX = math.max(0.0, (displayedWidth - _frameSize) / 2);
    final maxY = math.max(0.0, (displayedHeight - _frameSize) / 2);
    return Offset(
      offset.dx.clamp(-maxX, maxX),
      offset.dy.clamp(-maxY, maxY),
    );
  }

  /// Applies a new zoom level from the slider and re-clamps [_offset]
  /// against it. Zooming out shrinks how far the image can be panned;
  /// without re-clamping here, a pan made at high zoom could leave the frame
  /// showing blank space the moment the slider zooms back out past it.
  void _applyScale(double value, ui.Image image) {
    setState(() {
      _userScale = value;
      _offset = _clampOffset(_offset, image, value);
    });
  }

  Future<void> _save() async {
    final boundary =
        _boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) {
      Navigator.of(context).pop();
      return;
    }

    // Capped rather than the raw device pixel ratio: a 3x-DPR frame at
    // _frameSize 280 is already ~840px, comfortably more than this photo is
    // ever displayed at, and an uncapped ratio on a high-density display
    // would produce a needlessly heavy embed for no visible gain.
    final pixelRatio = math.min(MediaQuery.devicePixelRatioOf(context), 3.0);
    final captured = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await captured.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (!mounted) return;
    Navigator.of(context).pop(byteData?.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final image = _image;

    return Dialog(
      backgroundColor: colors.pageTop,
      insetPadding: EdgeInsets.all(24.r),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480.w, maxHeight: 560.h),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                context.translate(LangKeys.adminCropPhoto),
                style: MyFonts.bold22.copyWith(color: colors.onNavy),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: _frameSize,
                height: _frameSize,
                child: image == null
                    ? Center(
                        child: CircularProgressIndicator(
                          color: colors.accent,
                        ),
                      )
                    : GestureDetector(
                        onScaleStart: _onScaleStart,
                        onScaleUpdate: _onScaleUpdate,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            // What is captured: the frame clips the
                            // transformed image to exactly _frameSize square,
                            // which is the crop itself — nothing more happens
                            // to these pixels between here and the embed.
                            RepaintBoundary(
                              key: _boundaryKey,
                              child: ClipRect(
                                child: SizedBox(
                                  width: _frameSize,
                                  height: _frameSize,
                                  // `Transform` passes its incoming
                                  // constraints straight through to its
                                  // child unchanged — without this,
                                  // the tight _frameSize constraints from
                                  // the box above flow through the
                                  // Transform below and force the "bigger,
                                  // zoomed" image SizedBox back down to
                                  // exactly frame size, leaving nothing
                                  // for panning to ever reveal. OverflowBox
                                  // hands its child unbounded constraints
                                  // instead, so the image can actually lay
                                  // out at its real cover+zoom size; the
                                  // ClipRect above still clips whatever of
                                  // it spills past the frame.
                                  child: OverflowBox(
                                    minWidth: 0,
                                    minHeight: 0,
                                    maxWidth: double.infinity,
                                    maxHeight: double.infinity,
                                    child: Transform.translate(
                                      offset: _offset,
                                      child: SizedBox(
                                        width:
                                            image.width *
                                            _coverScale(image) *
                                            _userScale,
                                        height:
                                            image.height *
                                            _coverScale(image) *
                                            _userScale,
                                        child: RawImage(
                                          image: image,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Purely decorative, outside the boundary above:
                            // a circle shape only previews as a circle here,
                            // it does not change what gets captured.
                            if (widget.shape == PhotoCropShape.circle)
                              IgnorePointer(
                                child: CustomPaint(
                                  size: Size.square(_frameSize),
                                  painter: _CircleMaskPainter(
                                    color: colors.pageTop.withValues(
                                      alpha: 0.55,
                                    ),
                                  ),
                                ),
                              ),
                            IgnorePointer(
                              // Explicitly sized rather than left to Stack's
                              // own constraint-passing for a non-positioned
                              // child: a plain Container with no child and no
                              // size collapses to zero under loose
                              // constraints, which is the same class of bug
                              // that hid the image above.
                              child: SizedBox.square(
                                dimension: _frameSize,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: colors.accent),
                                    borderRadius:
                                        widget.shape == PhotoCropShape.circle
                                        ? BorderRadius.circular(_frameSize)
                                        : BorderRadius.circular(12.r),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              SizedBox(height: 8.h),
              // A slider rather than pinch alone: this tool is opened mostly
              // via `flutter run -d chrome` on a desktop browser, where there
              // is no pinch gesture to send at all — `onScaleUpdate`'s
              // `details.scale` never leaves 1.0 from a plain mouse drag, so
              // zoom was unreachable for the primary way this admin tool is
              // actually used. Pinch still works wherever it exists (touch,
              // trackpad); this is the path that works everywhere else too.
              Row(
                children: <Widget>[
                  Icon(
                    Icons.zoom_out_rounded,
                    size: 18.r,
                    color: colors.onNavyFaint,
                  ),
                  Expanded(
                    child: Slider(
                      value: _userScale,
                      min: _minUserScale,
                      max: _maxUserScale,
                      onChanged: image == null
                          ? null
                          : (value) => _applyScale(value, image),
                    ),
                  ),
                  Icon(
                    Icons.zoom_in_rounded,
                    size: 18.r,
                    color: colors.onNavyFaint,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.translate(LangKeys.adminCancel)),
                  ),
                  SizedBox(width: 8.w),
                  FilledButton(
                    onPressed: image == null ? null : _save,
                    child: Text(context.translate(LangKeys.adminSave)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dims everything outside a centred circle — the editing-time preview for
/// [PhotoCropShape.circle]. Drawn with `Path.combine`'s difference rather
/// than four rectangles around the circle, so the mask has no seams at the
/// circle's edge.
class _CircleMaskPainter extends CustomPainter {
  const _CircleMaskPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Offset.zero & size);
    final hole = Path()
      ..addOval(
        Rect.fromCircle(
          center: size.center(Offset.zero),
          radius: size.shortestSide / 2,
        ),
      );
    final mask = Path.combine(PathOperation.difference, full, hole);
    canvas.drawPath(mask, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _CircleMaskPainter oldDelegate) =>
      oldDelegate.color != color;
}
