import 'package:freezed_annotation/freezed_annotation.dart';

import 'image_ref.dart';

part 'media_ref.freezed.dart';
part 'media_ref.g.dart';

enum MediaKind {
  /// A still or an animated GIF. Both are just images to Flutter — it decodes
  /// and animates a GIF on its own — so they share one kind rather than
  /// pretending the editor has to tell them apart.
  image,

  /// A direct video file (mp4/webm), as an asset path or a URL. Composited by
  /// Flutter, so it survives the rotation and clipping the hover reveal applies.
  videoFile,

  /// A YouTube watch/share/embed URL. Rendered by a platform view, which does
  /// *not* survive transforms — keep it to flat, upright surfaces.
  videoEmbed,
}

/// Anything visual the portfolio shows: a screenshot, a looping GIF, a screen
/// recording, or a YouTube walkthrough.
///
/// [image] is always meaningful — for a video it is the poster frame shown
/// before playback starts and wherever a video cannot render. That is why this
/// wraps [ImageRef] rather than replacing it.
@freezed
abstract class MediaRef with _$MediaRef {
  const factory MediaRef({
    @Default(MediaKind.image) MediaKind kind,

    /// The still, or a video's poster frame.
    @Default(ImageRef()) ImageRef image,

    /// Asset path or URL of the video. Empty for [MediaKind.image].
    @Default('') String videoUrl,
    @Default(true) bool muted,
    @Default(true) bool loop,

    /// Plays as soon as the media is revealed — hovering a project row, opening
    /// the detail view — instead of waiting for a tap.
    @Default(true) bool autoplay,
  }) = _MediaRef;

  const MediaRef._();

  /// Tolerates the shape this field used to have.
  ///
  /// `cover` and `MediaShot.image` were bare [ImageRef]s, and that JSON is
  /// already sitting in visitors' local storage. An [ImageRef] payload has no
  /// `image` key, which is what tells the two apart — both carry `kind`, so
  /// that one cannot discriminate.
  factory MediaRef.fromJson(Map<String, dynamic> json) =>
      json.containsKey('image')
      ? _$MediaRefFromJson(json)
      : MediaRef(image: ImageRef.fromJson(json));

  // Static rather than factories: freezed reads redirecting factories as union
  // cases, the same reason [ImageRef] spells its helpers this way.
  static MediaRef still(ImageRef image) => MediaRef(image: image);

  static MediaRef asset(String path) => MediaRef(image: ImageRef.asset(path));

  static MediaRef videoFile(String url, {ImageRef poster = const ImageRef()}) =>
      MediaRef(kind: MediaKind.videoFile, videoUrl: url, image: poster);

  static MediaRef videoEmbed(String url, {ImageRef poster = const ImageRef()}) =>
      MediaRef(kind: MediaKind.videoEmbed, videoUrl: url, image: poster);

  bool get isVideo => kind != MediaKind.image;

  /// True when there is nothing to draw — a video with no source, or a still
  /// with no image. A video with only a poster is *not* empty: the poster is a
  /// perfectly good thing to show.
  bool get isEmpty => isVideo ? videoUrl.trim().isEmpty && image.isEmpty : image.isEmpty;

  bool get hasPlayableVideo => isVideo && videoUrl.trim().isNotEmpty;
}
