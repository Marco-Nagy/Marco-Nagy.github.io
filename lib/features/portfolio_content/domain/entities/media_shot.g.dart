// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_shot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MediaShot _$MediaShotFromJson(Map<String, dynamic> json) => _MediaShot(
  image: json['image'] == null
      ? const MediaRef()
      : MediaRef.fromJson(json['image'] as Map<String, dynamic>),
  frame:
      $enumDecodeNullable(_$DeviceFrameTypeEnumMap, json['frame']) ??
      DeviceFrameType.none,
  rotationDegrees: (json['rotationDegrees'] as num?)?.toDouble() ?? 0,
  scale: (json['scale'] as num?)?.toDouble() ?? 1,
  offsetX: (json['offsetX'] as num?)?.toDouble() ?? 0,
  offsetY: (json['offsetY'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$MediaShotToJson(_MediaShot instance) =>
    <String, dynamic>{
      'image': instance.image,
      'frame': _$DeviceFrameTypeEnumMap[instance.frame]!,
      'rotationDegrees': instance.rotationDegrees,
      'scale': instance.scale,
      'offsetX': instance.offsetX,
      'offsetY': instance.offsetY,
    };

const _$DeviceFrameTypeEnumMap = {
  DeviceFrameType.none: 'none',
  DeviceFrameType.laptop: 'laptop',
  DeviceFrameType.iphone: 'iphone',
  DeviceFrameType.samsungS: 'samsungS',
};
