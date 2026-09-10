import 'package:freezed_annotation/freezed_annotation.dart';

import 'image_ref.dart';

part 'site_content.freezed.dart';
part 'site_content.g.dart';

/// Every singleton piece of copy on the site — identity, hero, about, footer
/// and contact details.
///
/// This replaced the compile-time identity constants the site used to ship
/// with, so every string here is editable through the admin and reaches
/// visitors without a rebuild.
@freezed
abstract class SiteContent with _$SiteContent {
  const factory SiteContent({
    // Identity.
    @Default('') String fullNameEn,
    @Default('') String fullNameAr,
    @Default('') String roleEn,
    @Default('') String roleAr,
    @Default('MN') String monogram,
    @Default('') String locationEn,
    @Default('') String locationAr,

    /// The hero's circular headshot.
    @Default(ImageRef()) ImageRef profileImage,

    /// The About section's rounded-square portrait — separate from
    /// [profileImage] because the two crop to different shapes from
    /// (typically) different source photos.
    ///
    /// Falls back to [profileImage] wherever it is read: an empty value here
    /// means "not set yet," not "show nothing," so an existing site does not
    /// go blank the moment this field ships ahead of a photo chosen for it.
    @Default(ImageRef()) ImageRef aboutPhotoImage,

    // Contact + outward links.
    @Default('') String email,
    @Default('') String phone,
    @Default('') String gitHubUrl,
    @Default('') String linkedInUrl,

    /// Optional hosted CV. Empty falls back to the bundled asset (web only).
    @Default('') String hostedCvUrl,

    // Hero.
    @Default('') String heroGreetingEn,
    @Default('') String heroGreetingAr,
    @Default('') String heroNameEn,
    @Default('') String heroNameAr,
    @Default('') String heroRoleEn,
    @Default('') String heroRoleAr,
    @Default(<String>[]) List<String> roleTagsEn,
    @Default(<String>[]) List<String> roleTagsAr,

    // About.
    @Default('') String summaryEn,
    @Default('') String summaryAr,
    @Default('') String aboutLeadEn,
    @Default('') String aboutLeadAr,
    @Default(<String>[]) List<String> aboutStatementsEn,
    @Default(<String>[]) List<String> aboutStatementsAr,

    // Footer.
    @Default('') String footerHeadlineEn,
    @Default('') String footerHeadlineAr,
    @Default('') String footerAvailabilityEn,
    @Default('') String footerAvailabilityAr,

    // Contact page copy.
    @Default('') String contactTitleEn,
    @Default('') String contactTitleAr,
    @Default('') String contactSubtitleEn,
    @Default('') String contactSubtitleAr,

    // Featured works — the Home page's projects band.
    //
    // Added in Phase 4 rather than Phase 3, deliberately: a publish only ever
    // writes back what Firestore already held, so a field added before the
    // form that authors it can never be given a value. These land with
    // `site_content_form_screen`, which is the first thing that can fill them.
    @Default('') String homeWorksHeadlineEn,
    @Default('') String homeWorksHeadlineAr,
    @Default('') String homeWorksSubtitleEn,
    @Default('') String homeWorksSubtitleAr,
    @Default('') String homeWorksMoreLabelEn,
    @Default('') String homeWorksMoreLabelAr,
    @Default('') String homeWorksViewAllEn,
    @Default('') String homeWorksViewAllAr,
  }) = _SiteContent;

  const SiteContent._();

  factory SiteContent.fromJson(Map<String, dynamic> json) =>
      _$SiteContentFromJson(json);

  /// The photo the About section should actually render: [aboutPhotoImage]
  /// when it has been set, [profileImage] otherwise. Centralised here rather
  /// than left to each call site, so "not set yet" only ever falls back one
  /// way in the whole app.
  ImageRef get aboutPhoto =>
      aboutPhotoImage.isEmpty ? profileImage : aboutPhotoImage;
}
