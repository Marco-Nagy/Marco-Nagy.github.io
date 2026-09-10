// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SiteContent _$SiteContentFromJson(Map<String, dynamic> json) => _SiteContent(
  fullNameEn: json['fullNameEn'] as String? ?? '',
  fullNameAr: json['fullNameAr'] as String? ?? '',
  roleEn: json['roleEn'] as String? ?? '',
  roleAr: json['roleAr'] as String? ?? '',
  monogram: json['monogram'] as String? ?? 'MN',
  locationEn: json['locationEn'] as String? ?? '',
  locationAr: json['locationAr'] as String? ?? '',
  profileImage: json['profileImage'] == null
      ? const ImageRef()
      : ImageRef.fromJson(json['profileImage'] as Map<String, dynamic>),
  aboutPhotoImage: json['aboutPhotoImage'] == null
      ? const ImageRef()
      : ImageRef.fromJson(json['aboutPhotoImage'] as Map<String, dynamic>),
  email: json['email'] as String? ?? '',
  phone: json['phone'] as String? ?? '',
  gitHubUrl: json['gitHubUrl'] as String? ?? '',
  linkedInUrl: json['linkedInUrl'] as String? ?? '',
  hostedCvUrl: json['hostedCvUrl'] as String? ?? '',
  heroGreetingEn: json['heroGreetingEn'] as String? ?? '',
  heroGreetingAr: json['heroGreetingAr'] as String? ?? '',
  heroNameEn: json['heroNameEn'] as String? ?? '',
  heroNameAr: json['heroNameAr'] as String? ?? '',
  heroRoleEn: json['heroRoleEn'] as String? ?? '',
  heroRoleAr: json['heroRoleAr'] as String? ?? '',
  roleTagsEn:
      (json['roleTagsEn'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  roleTagsAr:
      (json['roleTagsAr'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  summaryEn: json['summaryEn'] as String? ?? '',
  summaryAr: json['summaryAr'] as String? ?? '',
  aboutLeadEn: json['aboutLeadEn'] as String? ?? '',
  aboutLeadAr: json['aboutLeadAr'] as String? ?? '',
  aboutStatementsEn:
      (json['aboutStatementsEn'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  aboutStatementsAr:
      (json['aboutStatementsAr'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  footerHeadlineEn: json['footerHeadlineEn'] as String? ?? '',
  footerHeadlineAr: json['footerHeadlineAr'] as String? ?? '',
  footerAvailabilityEn: json['footerAvailabilityEn'] as String? ?? '',
  footerAvailabilityAr: json['footerAvailabilityAr'] as String? ?? '',
  contactTitleEn: json['contactTitleEn'] as String? ?? '',
  contactTitleAr: json['contactTitleAr'] as String? ?? '',
  contactSubtitleEn: json['contactSubtitleEn'] as String? ?? '',
  contactSubtitleAr: json['contactSubtitleAr'] as String? ?? '',
  homeWorksHeadlineEn: json['homeWorksHeadlineEn'] as String? ?? '',
  homeWorksHeadlineAr: json['homeWorksHeadlineAr'] as String? ?? '',
  homeWorksSubtitleEn: json['homeWorksSubtitleEn'] as String? ?? '',
  homeWorksSubtitleAr: json['homeWorksSubtitleAr'] as String? ?? '',
  homeWorksMoreLabelEn: json['homeWorksMoreLabelEn'] as String? ?? '',
  homeWorksMoreLabelAr: json['homeWorksMoreLabelAr'] as String? ?? '',
  homeWorksViewAllEn: json['homeWorksViewAllEn'] as String? ?? '',
  homeWorksViewAllAr: json['homeWorksViewAllAr'] as String? ?? '',
);

Map<String, dynamic> _$SiteContentToJson(_SiteContent instance) =>
    <String, dynamic>{
      'fullNameEn': instance.fullNameEn,
      'fullNameAr': instance.fullNameAr,
      'roleEn': instance.roleEn,
      'roleAr': instance.roleAr,
      'monogram': instance.monogram,
      'locationEn': instance.locationEn,
      'locationAr': instance.locationAr,
      'profileImage': instance.profileImage,
      'aboutPhotoImage': instance.aboutPhotoImage,
      'email': instance.email,
      'phone': instance.phone,
      'gitHubUrl': instance.gitHubUrl,
      'linkedInUrl': instance.linkedInUrl,
      'hostedCvUrl': instance.hostedCvUrl,
      'heroGreetingEn': instance.heroGreetingEn,
      'heroGreetingAr': instance.heroGreetingAr,
      'heroNameEn': instance.heroNameEn,
      'heroNameAr': instance.heroNameAr,
      'heroRoleEn': instance.heroRoleEn,
      'heroRoleAr': instance.heroRoleAr,
      'roleTagsEn': instance.roleTagsEn,
      'roleTagsAr': instance.roleTagsAr,
      'summaryEn': instance.summaryEn,
      'summaryAr': instance.summaryAr,
      'aboutLeadEn': instance.aboutLeadEn,
      'aboutLeadAr': instance.aboutLeadAr,
      'aboutStatementsEn': instance.aboutStatementsEn,
      'aboutStatementsAr': instance.aboutStatementsAr,
      'footerHeadlineEn': instance.footerHeadlineEn,
      'footerHeadlineAr': instance.footerHeadlineAr,
      'footerAvailabilityEn': instance.footerAvailabilityEn,
      'footerAvailabilityAr': instance.footerAvailabilityAr,
      'contactTitleEn': instance.contactTitleEn,
      'contactTitleAr': instance.contactTitleAr,
      'contactSubtitleEn': instance.contactSubtitleEn,
      'contactSubtitleAr': instance.contactSubtitleAr,
      'homeWorksHeadlineEn': instance.homeWorksHeadlineEn,
      'homeWorksHeadlineAr': instance.homeWorksHeadlineAr,
      'homeWorksSubtitleEn': instance.homeWorksSubtitleEn,
      'homeWorksSubtitleAr': instance.homeWorksSubtitleAr,
      'homeWorksMoreLabelEn': instance.homeWorksMoreLabelEn,
      'homeWorksMoreLabelAr': instance.homeWorksMoreLabelAr,
      'homeWorksViewAllEn': instance.homeWorksViewAllEn,
      'homeWorksViewAllAr': instance.homeWorksViewAllAr,
    };
