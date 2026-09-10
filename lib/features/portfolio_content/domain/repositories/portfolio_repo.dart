import '../../../../core/common/data_result.dart';
import '../entities/certificate.dart';
import '../entities/custom_section_item.dart';
import '../entities/personal_project.dart';
import '../entities/portfolio_bundle.dart';
import '../entities/pricing_add_on.dart';
import '../entities/pricing_package.dart';
import '../entities/section_definition.dart';
import '../entities/site_content.dart';
import '../entities/skill_group_entity.dart';
import '../entities/tech_badge_entity.dart';
import '../entities/work_history_entry.dart';

/// Every mutation returns the full updated collection so a cubit can emit the
/// new list without a second read.
abstract class PortfolioRepo {
  Future<DataResult<List<PersonalProject>>> getProjects();
  Future<DataResult<List<PersonalProject>>> upsertProject(
    PersonalProject project,
  );
  Future<DataResult<List<PersonalProject>>> deleteProject(String id);

  Future<DataResult<List<Certificate>>> getCertificates();
  Future<DataResult<List<Certificate>>> upsertCertificate(
    Certificate certificate,
  );
  Future<DataResult<List<Certificate>>> deleteCertificate(String id);

  Future<DataResult<List<WorkHistoryEntry>>> getWorkHistory();
  Future<DataResult<List<WorkHistoryEntry>>> upsertWorkHistory(
    WorkHistoryEntry entry,
  );
  Future<DataResult<List<WorkHistoryEntry>>> deleteWorkHistory(String id);

  Future<DataResult<List<PricingPackage>>> getPricingPackages();
  Future<DataResult<List<PricingPackage>>> upsertPricingPackage(
    PricingPackage package,
  );
  Future<DataResult<List<PricingPackage>>> deletePricingPackage(String id);

  Future<DataResult<List<PricingAddOn>>> getPricingAddOns();
  Future<DataResult<List<PricingAddOn>>> upsertPricingAddOn(PricingAddOn addOn);
  Future<DataResult<List<PricingAddOn>>> deletePricingAddOn(String id);

  // Site-wide content.

  Future<DataResult<SiteContent>> getSiteContent();
  Future<DataResult<SiteContent>> saveSiteContent(SiteContent content);

  Future<DataResult<List<SkillGroupEntity>>> getSkillGroups();
  Future<DataResult<List<SkillGroupEntity>>> upsertSkillGroup(
    SkillGroupEntity group,
  );
  Future<DataResult<List<SkillGroupEntity>>> deleteSkillGroup(String id);

  Future<DataResult<List<TechBadgeEntity>>> getTechBadges();
  Future<DataResult<List<TechBadgeEntity>>> upsertTechBadge(
    TechBadgeEntity badge,
  );
  Future<DataResult<List<TechBadgeEntity>>> deleteTechBadge(String id);

  // Section registry.

  Future<DataResult<List<SectionDefinition>>> getSections();

  /// Persists the whole list at once — used by reorder, which changes every
  /// row's `order` in one gesture.
  Future<DataResult<List<SectionDefinition>>> saveSections(
    List<SectionDefinition> sections,
  );
  Future<DataResult<List<SectionDefinition>>> upsertSection(
    SectionDefinition section,
  );

  /// Removes a custom section and its items. Built-in sections are never
  /// deleted — hide them instead.
  Future<DataResult<List<SectionDefinition>>> deleteCustomSection(String id);

  // Custom section content.

  Future<DataResult<List<CustomSectionItem>>> getCustomItems(String sectionId);
  Future<DataResult<List<CustomSectionItem>>> upsertCustomItem(
    CustomSectionItem item,
  );
  Future<DataResult<List<CustomSectionItem>>> deleteCustomItem(
    String sectionId,
    String itemId,
  );

  // Whole-store access.

  /// Every collection as one [PortfolioBundle] — the shape Firestore stores
  /// and the admin exports. Reads the same in-memory caches the per-entity
  /// getters use, so this is not a fresh decode of the whole store.
  Future<DataResult<PortfolioBundle>> readBundle();

  /// Brings the local cache up to date with Firestore, once, at startup.
  ///
  /// Every other read on this interface stays a plain cache read. Putting the
  /// version check inside each of them instead would turn one page into
  /// dozens of round trips, and none of them could then be synchronous.
  ///
  /// Never fails in a way a visitor sees: an unreachable Firestore, a missing
  /// document and a stale cache all resolve to "render what we have", falling
  /// back through cache, then the committed JSON asset (D3), then whatever the
  /// local store holds — empty, on a device that has never synced at all.
  Future<DataResult<PortfolioBundle>> syncFromRemote();

  /// Discards local edits and reloads the last published content — what the
  /// admin's "Reset" action means now that content lives in Firestore rather
  /// than in hardcoded seed constants.
  ///
  /// Unlike [syncFromRemote], this always re-fetches: an admin's unpublished
  /// local edit never changes the cached [PortfolioBundle.contentVersion] (only
  /// a publish does), so a version-matches-cache check would treat "identical
  /// version, different content" as nothing to do and silently keep the edit —
  /// exactly the case this exists to undo.
  ///
  /// Falls back to the committed JSON asset if Firestore is unreachable, and
  /// fails outright — leaving the current local content untouched — only when
  /// neither is available. Untouched is the right failure mode: there is
  /// nothing trustworthy to replace it with, and wiping it would be worse than
  /// refusing.
  Future<DataResult<PortfolioBundle>> resetToPublished();

  /// Writes every local collection to Firestore as one new published version,
  /// via [PortfolioRemoteDataSource.writeBundle] — which bumps
  /// [PortfolioBundle.contentVersion] and stamps [PortfolioBundle.updatedAt] in
  /// the same batch that writes `content/bundle`, so a reader can never
  /// observe the version number ahead of the content it describes.
  ///
  /// Requires the signed-in owner account. That is enforced by Firestore's
  /// security rules, not checked here — a signed-out attempt is expected to
  /// surface as [Fail] from the write itself, the same as any other rejected
  /// request, rather than a separate client-side auth check duplicating what
  /// the rules already guarantee.
  Future<DataResult<PortfolioBundle>> publish();
}
