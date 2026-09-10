import 'package:freezed_annotation/freezed_annotation.dart';

import 'certificate.dart';
import 'custom_section_item.dart';
import 'personal_project.dart';
import 'pricing_add_on.dart';
import 'pricing_package.dart';
import 'section_definition.dart';
import 'site_content.dart';
import 'skill_group_entity.dart';
import 'tech_badge_entity.dart';
import 'work_history_entry.dart';

part 'portfolio_bundle.freezed.dart';
part 'portfolio_bundle.g.dart';

/// Every piece of editable content in one object — the unit that travels
/// between Firestore, the local cache and the committed JSON fallback.
///
/// **Why one bundle instead of a collection per entity.** A visitor reading
/// nine collections costs ~51 Firestore reads, which caps the free tier at
/// roughly 980 visitors a day. Reading `content/meta` (1 read), comparing
/// [contentVersion] against the cached copy, and fetching `content/bundle`
/// only when it differs costs a returning visitor exactly 1 read instead.
///
/// This codebase has no models/mappers layer — freezed domain entities are the
/// wire format — so this is a domain entity beside the other ten, not a data
/// model. The one limit to respect is Firestore's 1 MiB document cap: content
/// is text and sits far below it, and media lives at Cloudinary as URLs rather
/// than inline. `bundle_size_test.dart` asserts both.
@freezed
abstract class PortfolioBundle with _$PortfolioBundle {
  const factory PortfolioBundle({
    // Built-in section content.
    @Default(<PersonalProject>[]) List<PersonalProject> projects,
    @Default(<Certificate>[]) List<Certificate> certificates,
    @Default(<WorkHistoryEntry>[]) List<WorkHistoryEntry> workHistory,
    @Default(<PricingPackage>[]) List<PricingPackage> pricingPackages,
    @Default(<PricingAddOn>[]) List<PricingAddOn> pricingAddOns,

    // Site-wide content.
    @Default(SiteContent()) SiteContent siteContent,
    @Default(<SkillGroupEntity>[]) List<SkillGroupEntity> skillGroups,
    @Default(<TechBadgeEntity>[]) List<TechBadgeEntity> techBadges,

    // Section registry + custom section content, keyed by section id.
    @Default(<SectionDefinition>[]) List<SectionDefinition> sections,
    @Default(<String, List<CustomSectionItem>>{})
    Map<String, List<CustomSectionItem>> customItems,

    /// Bumped by hand when the *shape* of this object changes in a way older
    /// clients cannot read. A stored bundle from a newer schema is refused
    /// rather than silently half-decoded.
    @Default(1) int schemaVersion,

    /// Bumped on every admin save. A client whose cached value matches the
    /// one in `content/meta` skips fetching the bundle entirely — this single
    /// integer is what keeps a returning visitor at 1 read.
    @Default(0) int contentVersion,

    /// ISO-8601, matching the stringly-dated convention every other entity
    /// here uses. Informational: nothing branches on it.
    @Default('') String updatedAt,
  }) = _PortfolioBundle;

  const PortfolioBundle._();

  factory PortfolioBundle.fromJson(Map<String, dynamic> json) =>
      _$PortfolioBundleFromJson(json);

  /// The schema this build of the app writes and can read.
  static const int currentSchemaVersion = 1;

  /// True when the bundle came from a build newer than this one. The read path
  /// falls back to cache rather than decoding a shape it does not understand.
  bool get isFromNewerSchema => schemaVersion > currentSchemaVersion;

  /// Cheap emptiness check used to decide whether a cache or fallback actually
  /// holds content. A bundle with no projects *and* no sections has nothing to
  /// render, whatever else it carries.
  bool get isEmpty => projects.isEmpty && sections.isEmpty;

  /// The version markers alone, for writing `content/meta` beside the bundle.
  PortfolioMeta get meta => PortfolioMeta(
    contentVersion: contentVersion,
    schemaVersion: schemaVersion,
    updatedAt: updatedAt,
  );
}

/// The tiny `content/meta` document — the whole point of the read design.
///
/// A visitor fetches this (1 Firestore read), compares [contentVersion] with
/// the cached one, and only then decides whether the far larger `content/bundle`
/// is worth a second read. Keeping it a separate document is what makes the
/// common case cost one read instead of the bundle's full payload.
@freezed
abstract class PortfolioMeta with _$PortfolioMeta {
  const factory PortfolioMeta({
    @Default(0) int contentVersion,
    @Default(1) int schemaVersion,
    @Default('') String updatedAt,
  }) = _PortfolioMeta;

  const PortfolioMeta._();

  factory PortfolioMeta.fromJson(Map<String, dynamic> json) =>
      _$PortfolioMetaFromJson(json);

  /// True when the remote content is newer than what [cachedVersion] holds.
  bool isNewerThan(int cachedVersion) => contentVersion > cachedVersion;

  bool get isFromNewerSchema =>
      schemaVersion > PortfolioBundle.currentSchemaVersion;
}
