import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../features/portfolio_content/domain/entities/media_shot.dart';
import 'device_frame.dart';

/// Renders one [MediaShot] exactly as it sits inside its panel — same frame,
/// rotation, scale and offset — without the panel around it.
///
/// The shot editor sets those five numbers with nothing else on screen to
/// judge them against; without this, "does 12° look right" is a question the
/// admin can only answer by saving, backing out to the panel, and looking.
class ShotPreview extends StatelessWidget {
  const ShotPreview({
    required this.shot,
    required this.width,
    required this.height,
    super.key,
  });

  final MediaShot shot;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        // The panel itself clips at its own edge — an offset or an oversized
        // scale is meant to spill past it, per the panel view's own comment.
        // Clipping here too keeps the preview honest about what the visitor
        // will actually see, not what the layer looks like unclipped.
        child: Center(
          child: Transform.translate(
            offset: Offset(shot.offsetX * width, shot.offsetY * height),
            child: Transform.rotate(
              angle: shot.rotationDegrees * math.pi / 180,
              child: DeviceFrame(
                image: shot.image,
                frame: shot.frame,
                width: width * 0.7 * shot.scale,
                // Resting, not running: this editor is for placement, not
                // playback, the same call `MediaRefField`'s preview makes.
                playing: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
