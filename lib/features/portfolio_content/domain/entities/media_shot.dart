import 'package:freezed_annotation/freezed_annotation.dart';

import 'media_ref.dart';

part 'media_shot.freezed.dart';
part 'media_shot.g.dart';

/// The device bezel drawn around a screenshot. The frame is a *rendering*
/// choice, never a transformation of the file — so it can be changed later
/// without re-uploading and it costs nothing in the exported bundle.
enum DeviceFrameType {
  none,
  laptop,
  iphone,
  samsungS;

  /// Portrait frames sit in a side column; the laptop takes full width.
  bool get isLandscape => this == DeviceFrameType.laptop;

  static const List<DeviceFrameType> selectable = <DeviceFrameType>[
    none,
    laptop,
    iphone,
    samsungS,
  ];
}

/// One screenshot placed inside a showcase panel.
///
/// [scale] above 1 deliberately lets the device overflow the panel edge — the
/// reference graphics crop the phone at the bottom rather than fitting it whole.
@freezed
abstract class MediaShot with _$MediaShot {
  const factory MediaShot({
    /// Kept named `image` so the stored JSON key does not move; [MediaRef]
    /// reads the bare [ImageRef] payload this used to hold.
    @Default(MediaRef()) MediaRef image,
    @Default(DeviceFrameType.none) DeviceFrameType frame,
    @Default(0) double rotationDegrees,
    @Default(1) double scale,

    /// Fractional offset inside the panel: 0 is centred, 1 is a full panel
    /// width/height away.
    @Default(0) double offsetX,
    @Default(0) double offsetY,
  }) = _MediaShot;

  factory MediaShot.fromJson(Map<String, dynamic> json) =>
      _$MediaShotFromJson(json);
}
