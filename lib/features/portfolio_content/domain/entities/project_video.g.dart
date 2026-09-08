// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProjectVideo _$ProjectVideoFromJson(Map<String, dynamic> json) =>
    _ProjectVideo(
      id: json['id'] as String,
      media: json['media'] == null
          ? const MediaRef()
          : MediaRef.fromJson(json['media'] as Map<String, dynamic>),
      aspectRatio: (json['aspectRatio'] as num?)?.toDouble() ?? 9 / 16,
      captionEn: json['captionEn'] as String? ?? '',
      captionAr: json['captionAr'] as String? ?? '',
      subtitleEn: json['subtitleEn'] as String? ?? '',
      subtitleAr: json['subtitleAr'] as String? ?? '',
      captionPlacement:
          $enumDecodeNullable(
            _$CaptionPlacementEnumMap,
            json['captionPlacement'],
          ) ??
          CaptionPlacement.top,
      captionColorHex: json['captionColorHex'] as String? ?? 'FFFFFF',
      backgroundOverride: json['backgroundOverride'] == null
          ? null
          : ShotBackground.fromJson(
              json['backgroundOverride'] as Map<String, dynamic>,
            ),
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ProjectVideoToJson(_ProjectVideo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'media': instance.media,
      'aspectRatio': instance.aspectRatio,
      'captionEn': instance.captionEn,
      'captionAr': instance.captionAr,
      'subtitleEn': instance.subtitleEn,
      'subtitleAr': instance.subtitleAr,
      'captionPlacement': _$CaptionPlacementEnumMap[instance.captionPlacement]!,
      'captionColorHex': instance.captionColorHex,
      'backgroundOverride': instance.backgroundOverride,
      'order': instance.order,
    };

const _$CaptionPlacementEnumMap = {
  CaptionPlacement.top: 'top',
  CaptionPlacement.bottom: 'bottom',
  CaptionPlacement.start: 'start',
  CaptionPlacement.end: 'end',
  CaptionPlacement.none: 'none',
};
