import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../features/portfolio_content/domain/entities/media_shot.dart';
import '../../../features/portfolio_content/domain/entities/shot_background.dart';
import '../../../features/portfolio_content/domain/entities/showcase_panel.dart';
import '../../utils/extension/context_extensions.dart';
import '../../utils/hex_color.dart';
import 'device_frame.dart';
import 'panel_caption.dart';
import 'shot_background_view.dart';

/// One device-framed screenshot: background, the shot rotated/scaled/offset
/// inside its bezel, caption on top.
///
/// Complete on its own — a screenshot is always a still inside a real device
/// frame; there is no video-tap state or edge-to-edge fill to account for
/// here the way [VideoCard]/[GifCard]/[FeatureGraphicCard] have to. Keeping
/// this card free of that branching is the point of splitting the four kinds
/// apart in the first place.
class ScreenshotCard extends StatelessWidget {
  const ScreenshotCard({
    required this.panel,
    required this.background,
    required this.caption,
    required this.subtitle,
    required this.width,
    super.key,
  });

  final ShowcasePanel panel;

  /// Already resolved: the panel's own override, else the project default.
  final ShotBackground background;

  /// Already resolved into the active language.
  final String caption;
  final String subtitle;

  final double width;

  static const double aspectRatio = 9 / 16;

  /// A portrait card is dominated by one phone.
  static const double _deviceWidthFactor = 0.74;

  MediaShot get _shot =>
      panel.shots.isEmpty ? const MediaShot() : panel.shots.first;

  @override
  Widget build(BuildContext context) {
    final panelWidth = width;
    final panelHeight = panelWidth / aspectRatio;
    final shot = _shot;

    return RepaintBoundary(
      child: SizedBox(
        width: panelWidth,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            // The device deliberately overflows the card edge, as in the
            // reference graphics where the phone is cropped by the bottom
            // border.
            clipBehavior: Clip.hardEdge,
            fit: StackFit.expand,
            children: <Widget>[
              ShotBackgroundView(background: background),
              Center(
                child: Transform.translate(
                  offset: Offset(
                    shot.offsetX * panelWidth,
                    shot.offsetY * panelHeight,
                  ),
                  child: Transform.rotate(
                    angle: shot.rotationDegrees * math.pi / 180,
                    child: DeviceFrame(
                      image: shot.image,
                      frame: shot.frame,
                      width: panelWidth * _deviceWidthFactor * shot.scale,
                      label: caption,
                    ),
                  ),
                ),
              ),
              PanelCaption(
                caption: caption,
                subtitle: subtitle,
                placement: panel.captionPlacement,
                color: HexColor.parse(
                  panel.captionColorHex,
                  context.colors.onNavy,
                ),
                panelWidth: panelWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
