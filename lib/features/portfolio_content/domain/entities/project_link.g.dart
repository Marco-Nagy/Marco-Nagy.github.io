// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProjectLink _$ProjectLinkFromJson(Map<String, dynamic> json) => _ProjectLink(
  type: $enumDecode(_$ProjectLinkTypeEnumMap, json['type']),
  url: json['url'] as String? ?? '',
);

Map<String, dynamic> _$ProjectLinkToJson(_ProjectLink instance) =>
    <String, dynamic>{
      'type': _$ProjectLinkTypeEnumMap[instance.type]!,
      'url': instance.url,
    };

const _$ProjectLinkTypeEnumMap = {
  ProjectLinkType.gitHub: 'gitHub',
  ProjectLinkType.playStore: 'playStore',
  ProjectLinkType.appStore: 'appStore',
  ProjectLinkType.web: 'web',
  ProjectLinkType.apk: 'apk',
};
