import 'package:flutter/material.dart';

import '../../../features/portfolio_content/domain/entities/media_ref.dart';
import '../../utils/extension/context_extensions.dart';
import '../../../features/portfolio_content/domain/entities/media_shot.dart';
import '../common/app_media.dart';
import '../common/safe_asset_image.dart';

/// Draws a screenshot inside a device bezel.
///
/// Every frame is plain Flutter painting — no package. `device_frame` on pub
/// ships a whole device catalogue and its own theming; four hand-drawn bezels
/// are smaller and obey the app's palette.
class DeviceFrame extends StatelessWidget {
  const DeviceFrame({
    required this.image,
    required this.frame,
    required this.width,
    this.label,
    this.playing = true,
    super.key,
  });

  final MediaRef image;
  final DeviceFrameType frame;

  /// Drives every other dimension, so a frame scales as one piece.
  final double width;
  final String? label;

  /// Whether a video screen recording inside the bezel should run. Panels that
  /// are off-screen or unselected pass false so they cost nothing.
  final bool playing;

  /// Screen aspect ratio per device, used to size the whole widget.
  static double aspectRatioOf(DeviceFrameType frame) => switch (frame) {
    DeviceFrameType.laptop => 16 / 11.2,
    DeviceFrameType.iphone => 9 / 19.5,
    DeviceFrameType.samsungS => 9 / 19.5,
    DeviceFrameType.none => 9 / 16,
  };

  @override
  Widget build(BuildContext context) {
    // allowPlatformView is false because a framed shot is never flat: the panel
    // rotates and translates it, and the bezel clips it. A YouTube embed is a
    // platform view that honours none of that, so inside a bezel it shows its
    // poster and a screen recording has to be a videoFile to actually play.
    final screenshot = AppMedia(
      media: image,
      playing: playing,
      allowPlatformView: false,
      fallback: AssetPlaceholder(
        icon: frame == DeviceFrameType.laptop
            ? Icons.laptop_mac_outlined
            : Icons.phone_iphone_outlined,
        label: label,
      ),
    );

    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: aspectRatioOf(frame),
        child: switch (frame) {
          DeviceFrameType.none => ClipRRect(
            borderRadius: BorderRadius.circular(width * 0.03),
            child: screenshot,
          ),
          DeviceFrameType.laptop => _LaptopBezel(
            width: width,
            child: screenshot,
          ),
          DeviceFrameType.iphone => _PhoneBezel(
            width: width,
            cornerFactor: 0.13,
            bezelFactor: 0.026,
            camera: _CameraStyle.dynamicIsland,
            child: screenshot,
          ),
          DeviceFrameType.samsungS => _PhoneBezel(
            width: width,
            cornerFactor: 0.09,
            bezelFactor: 0.016,
            camera: _CameraStyle.punchHole,
            child: screenshot,
          ),
        },
      ),
    );
  }
}

enum _CameraStyle { dynamicIsland, punchHole }

/// Shared phone bezel. The iPhone and Galaxy differ only in corner radius,
/// bezel thickness and camera treatment, so one widget covers both.
class _PhoneBezel extends StatelessWidget {
  const _PhoneBezel({
    required this.width,
    required this.child,
    required this.cornerFactor,
    required this.bezelFactor,
    required this.camera,
  });

  final double width;
  final Widget child;
  final double cornerFactor;
  final double bezelFactor;
  final _CameraStyle camera;

  @override
  Widget build(BuildContext context) {
    final radius = width * cornerFactor;
    final bezel = width * bezelFactor;
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(bezel),
      decoration: BoxDecoration(
        color: colors.deviceBezel,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: colors.deviceBezelEdge, width: width * 0.006),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.45),
            blurRadius: width * 0.14,
            offset: Offset(0, width * 0.05),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - bezel),
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: child),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: width * 0.022),
                child: switch (camera) {
                  _CameraStyle.dynamicIsland => Container(
                    width: width * 0.26,
                    height: width * 0.075,
                    decoration: BoxDecoration(
                      color: colors.deviceCamera,
                      borderRadius: BorderRadius.circular(width * 0.04),
                    ),
                  ),
                  _CameraStyle.punchHole => Container(
                    width: width * 0.045,
                    height: width * 0.045,
                    decoration: BoxDecoration(
                      color: colors.deviceCamera,
                      shape: BoxShape.circle,
                    ),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// MacBook-style bezel: screen plus a tapered base.
class _LaptopBezel extends StatelessWidget {
  const _LaptopBezel({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bezel = width * 0.012;
    final radius = width * 0.018;
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: Container(
            padding: EdgeInsets.all(bezel),
            decoration: BoxDecoration(
              color: colors.deviceBezel,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: colors.deviceBezelEdge,
                width: width * 0.004,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.4),
                  blurRadius: width * 0.09,
                  offset: Offset(0, width * 0.03),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: child,
            ),
          ),
        ),
        // Tapered base — a trapezoid read as the laptop's lower half.
        CustomPaint(
          size: Size(width, width * 0.032),
          painter: _LaptopBasePainter(
            base: colors.deviceBase,
            notch: colors.deviceBezel,
          ),
        ),
      ],
    );
  }
}

class _LaptopBasePainter extends CustomPainter {
  const _LaptopBasePainter({required this.base, required this.notch});

  final Color base;
  final Color notch;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(-size.width * 0.04, 0)
      ..lineTo(size.width * 1.04, 0)
      ..lineTo(size.width * 0.94, size.height)
      ..lineTo(size.width * 0.06, size.height)
      ..close();

    canvas.drawPath(path, Paint()..color = base);

    // Trackpad notch on the front lip.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.2),
          width: size.width * 0.14,
          height: size.height * 0.32,
        ),
        Radius.circular(size.height * 0.2),
      ),
      Paint()..color = notch,
    );
  }

  @override
  bool shouldRepaint(covariant _LaptopBasePainter oldDelegate) =>
      base != oldDelegate.base || notch != oldDelegate.notch;
}
