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
/// modelled on a portrait phone screenshot, and none of it means anything for
/// a video. A recording is not composed inside a frame — it is played at
/// whatever shape it was recorded at.
///
/// That shape is [aspectRatio], stored per video rather than fixed for the
/// entity or derived from a frame choice: one project routinely holds both a
/// vertical screen recording and a landscape YouTube walkthrough, so the
/// ratio has to differ between two videos sitting side by side in the same
/// strip.
@freezed
abstract class ProjectVideo with _$ProjectVideo {
  const factory ProjectVideo({
    required String id,
    @Default(MediaRef()) MediaRef media,

    /// Width ÷ height. Defaults to a vertical 9:16 — the phone screen
    /// recording most of these are.
    @Default(9 / 16) double aspectRatio,
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

  factory ProjectVideo.fromJson(Map<String, dynamic> json) =>
      _$ProjectVideoFromJson(json);
}
