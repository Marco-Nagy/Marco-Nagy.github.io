import 'package:freezed_annotation/freezed_annotation.dart';

import 'media_ref.dart';
import 'media_shot.dart';
import 'shot_background.dart';
import 'showcase_panel.dart';

part 'project_video.freezed.dart';
part 'project_video.g.dart';

/// One video in a project's showcase — a screen recording or a YouTube
/// walkthrough, never a device-framed screenshot.
///
/// Deliberately its own entity rather than a [ShowcasePanel]: a panel's
/// `format`/[MediaShot] machinery (device bezel, rotation, scale, offset) is
/// modelled on a portrait phone screenshot, and a video is neither always
/// portrait nor ever rotated or offset inside its frame. Reuses
/// [DeviceFrameType] for [frame] rather than inventing a parallel enum,
/// since the choice a video actually needs — "flat landscape", "in a laptop
/// bezel", "in a phone bezel" — is the same bezel art the screenshot frame
/// already draws; only [aspectRatio] gives each case a video-appropriate
/// shape instead of the screenshot's own.
@freezed
abstract class ProjectVideo with _$ProjectVideo {
  const factory ProjectVideo({
    required String id,
    @Default(MediaRef()) MediaRef media,
    @Default(DeviceFrameType.none) DeviceFrameType frame,
    @Default('') String captionEn,
    @Default('') String captionAr,
    @Default('') String subtitleEn,
    @Default('') String subtitleAr,
    @Default(CaptionPlacement.top) CaptionPlacement captionPlacement,
    @Default('FFFFFF') String captionColorHex,

    /// Overrides the owning project's background when set.
    ShotBackground? backgroundOverride,
    @Default(0) int order,
  }) = _ProjectVideo;

  const ProjectVideo._();

  factory ProjectVideo.fromJson(Map<String, dynamic> json) =>
      _$ProjectVideoFromJson(json);

  /// Screen aspect ratio for [frame]. Laptop and phone bezels keep the same
  /// proportions [DeviceFrame] already draws them at, so the card and the
  /// bezel agree on the shape; `none` is a bare video with no bezel to match,
  /// so it gets a video-native 16:9 rather than [DeviceFrameType.none]'s
  /// screenshot meaning of a flat 9:16 portrait still.
  double get aspectRatio => switch (frame) {
    DeviceFrameType.laptop => 16 / 11.2,
    DeviceFrameType.iphone => 9 / 19.5,
    DeviceFrameType.samsungS => 9 / 19.5,
    DeviceFrameType.none => 16 / 9,
  };
}
