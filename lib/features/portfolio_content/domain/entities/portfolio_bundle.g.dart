// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_bundle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PortfolioBundle _$PortfolioBundleFromJson(
  Map<String, dynamic> json,
) => _PortfolioBundle(
  projects:
      (json['projects'] as List<dynamic>?)
          ?.map((e) => PersonalProject.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PersonalProject>[],
  certificates:
      (json['certificates'] as List<dynamic>?)
          ?.map((e) => Certificate.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Certificate>[],
  workHistory:
      (json['workHistory'] as List<dynamic>?)
          ?.map((e) => WorkHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <WorkHistoryEntry>[],
  pricingPackages:
      (json['pricingPackages'] as List<dynamic>?)
          ?.map((e) => PricingPackage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PricingPackage>[],
  pricingAddOns:
      (json['pricingAddOns'] as List<dynamic>?)
          ?.map((e) => PricingAddOn.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PricingAddOn>[],
  siteContent: json['siteContent'] == null
      ? const SiteContent()
      : SiteContent.fromJson(json['siteContent'] as Map<String, dynamic>),
  skillGroups:
      (json['skillGroups'] as List<dynamic>?)
          ?.map((e) => SkillGroupEntity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SkillGroupEntity>[],
  techBadges:
      (json['techBadges'] as List<dynamic>?)
          ?.map((e) => TechBadgeEntity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TechBadgeEntity>[],
  sections:
      (json['sections'] as List<dynamic>?)
          ?.map((e) => SectionDefinition.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SectionDefinition>[],
  customItems:
      (json['customItems'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          (e as List<dynamic>)
              .map((e) => CustomSectionItem.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      ) ??
      const <String, List<CustomSectionItem>>{},
  schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
  contentVersion: (json['contentVersion'] as num?)?.toInt() ?? 0,
  updatedAt: json['updatedAt'] as String? ?? '',
);

Map<String, dynamic> _$PortfolioBundleToJson(_PortfolioBundle instance) =>
    <String, dynamic>{
      'projects': instance.projects,
      'certificates': instance.certificates,
      'workHistory': instance.workHistory,
      'pricingPackages': instance.pricingPackages,
      'pricingAddOns': instance.pricingAddOns,
      'siteContent': instance.siteContent,
      'skillGroups': instance.skillGroups,
      'techBadges': instance.techBadges,
      'sections': instance.sections,
      'customItems': instance.customItems,
      'schemaVersion': instance.schemaVersion,
      'contentVersion': instance.contentVersion,
      'updatedAt': instance.updatedAt,
    };

_PortfolioMeta _$PortfolioMetaFromJson(Map<String, dynamic> json) =>
    _PortfolioMeta(
      contentVersion: (json['contentVersion'] as num?)?.toInt() ?? 0,
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
      updatedAt: json['updatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$PortfolioMetaToJson(_PortfolioMeta instance) =>
    <String, dynamic>{
      'contentVersion': instance.contentVersion,
      'schemaVersion': instance.schemaVersion,
      'updatedAt': instance.updatedAt,
    };
