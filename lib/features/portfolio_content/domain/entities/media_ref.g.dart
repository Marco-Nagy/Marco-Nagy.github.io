// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_ref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MediaRef _$MediaRefFromJson(Map<String, dynamic> json) => _MediaRef(
  kind:
      $enumDecodeNullable(_$MediaKindEnumMap, json['kind']) ?? MediaKind.image,
  image: json['image'] == null
      ? const ImageRef()
      : ImageRef.fromJson(json['image'] as Map<String, dynamic>),
  videoUrl: json['videoUrl'] as String? ?? '',
  muted: json['muted'] as bool? ?? true,
  loop: json['loop'] as bool? ?? true,
  autoplay: json['autoplay'] as bool? ?? true,
);

Map<String, dynamic> _$MediaRefToJson(_MediaRef instance) => <String, dynamic>{
  'kind': _$MediaKindEnumMap[instance.kind]!,
  'image': instance.image,
  'videoUrl': instance.videoUrl,
  'muted': instance.muted,
  'loop': instance.loop,
  'autoplay': instance.autoplay,
};

const _$MediaKindEnumMap = {
  MediaKind.image: 'image',
  MediaKind.videoFile: 'videoFile',
  MediaKind.videoEmbed: 'videoEmbed',
};
