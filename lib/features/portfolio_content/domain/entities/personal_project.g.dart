// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PersonalProject _$PersonalProjectFromJson(
  Map<String, dynamic> json,
) => _PersonalProject(
  id: json['id'] as String,
  title: json['title'] as String,
  titleAr: json['titleAr'] as String? ?? '',
  description: json['description'] as String? ?? '',
  descriptionAr: json['descriptionAr'] as String? ?? '',
  features:
      (json['features'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  featuresAr:
      (json['featuresAr'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  category: json['category'] as String? ?? '',
  categoryAr: json['categoryAr'] as String? ?? '',
  cover: json['cover'] == null
      ? const MediaRef()
      : MediaRef.fromJson(json['cover'] as Map<String, dynamic>),
  panels:
      (json['panels'] as List<dynamic>?)
          ?.map((e) => ShowcasePanel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ShowcasePanel>[],
  videos:
      (json['videos'] as List<dynamic>?)
          ?.map((e) => ProjectVideo.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ProjectVideo>[],
  showcaseBackground: json['showcaseBackground'] == null
      ? const ShotBackground()
      : ShotBackground.fromJson(
          json['showcaseBackground'] as Map<String, dynamic>,
        ),
  links:
      (json['links'] as List<dynamic>?)
          ?.map((e) => ProjectLink.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ProjectLink>[],
  skills:
      (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  skillsAr:
      (json['skillsAr'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  technologies:
      (json['technologies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  tools:
      (json['tools'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  accentHex: json['accentHex'] as String? ?? '4CC9F0',
  order: (json['order'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PersonalProjectToJson(_PersonalProject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'titleAr': instance.titleAr,
      'description': instance.description,
      'descriptionAr': instance.descriptionAr,
      'features': instance.features,
      'featuresAr': instance.featuresAr,
      'category': instance.category,
      'categoryAr': instance.categoryAr,
      'cover': instance.cover,
      'panels': instance.panels,
      'videos': instance.videos,
      'showcaseBackground': instance.showcaseBackground,
      'links': instance.links,
      'skills': instance.skills,
      'skillsAr': instance.skillsAr,
      'technologies': instance.technologies,
      'tools': instance.tools,
      'accentHex': instance.accentHex,
      'order': instance.order,
    };
