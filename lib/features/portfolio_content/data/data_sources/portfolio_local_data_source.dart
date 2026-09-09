import '../../domain/entities/certificate.dart';
import '../../domain/entities/custom_section_item.dart';
import '../../domain/entities/personal_project.dart';
import '../../domain/entities/portfolio_bundle.dart';
import '../../domain/entities/pricing_add_on.dart';
import '../../domain/entities/pricing_package.dart';
import '../../domain/entities/section_definition.dart';
import '../../domain/entities/site_content.dart';
import '../../domain/entities/skill_group_entity.dart';
import '../../domain/entities/tech_badge_entity.dart';
import '../../domain/entities/work_history_entry.dart';

/// The app's only persistence contract. Reads are synchronous because
/// shared_preferences keeps everything in memory once loaded; writes are async.
abstract class PortfolioLocalDataSource {
  /// Writes seed content on first launch only. Once the seed marker is set,
  /// deleting every item in debug is respected rather than undone.
  Future<void> seedIfEmpty();

  /// Discards local edits and restores the seeded content.
  Future<void> resetToSeed();

  // Whole-store access --------------------------------------------------------
  //
  // The per-entity getters above stay the app's day-to-day interface. These
  // two exist because Firestore stores all of it as one document: one read
  // per visitor instead of ~51, and one atomic write per admin save instead
  // of nine that could tear.

  /// Composes every stored collection, plus the cached version markers, into
  /// one bundle. Reads from the same in-memory caches the getters use, so
  /// calling this is not a fresh decode of the whole store.
  PortfolioBundle readAll();

  /// Replaces the entire local store with [bundle] and records its
  /// [PortfolioBundle.contentVersion] and [PortfolioBundle.schemaVersion].
  ///
  /// Custom-section keys absent from [bundle] are swept, so a section deleted
  /// remotely does not survive locally as an orphaned key.
  Future<void> writeAll(PortfolioBundle bundle);

  // Built-in section content.

  List<PersonalProject> getProjects();
  Future<void> saveProjects(List<PersonalProject> projects);

  List<Certificate> getCertificates();
  Future<void> saveCertificates(List<Certificate> certificates);

  List<WorkHistoryEntry> getWorkHistory();
  Future<void> saveWorkHistory(List<WorkHistoryEntry> entries);

  List<PricingPackage> getPricingPackages();
  Future<void> savePricingPackages(List<PricingPackage> packages);

  List<PricingAddOn> getPricingAddOns();
  Future<void> savePricingAddOns(List<PricingAddOn> addOns);

  // Site-wide content.

  SiteContent getSiteContent();
  Future<void> saveSiteContent(SiteContent content);

  List<SkillGroupEntity> getSkillGroups();
  Future<void> saveSkillGroups(List<SkillGroupEntity> groups);

  List<TechBadgeEntity> getTechBadges();
  Future<void> saveTechBadges(List<TechBadgeEntity> badges);

  // Section registry + custom section content.

  List<SectionDefinition> getSections();
  Future<void> saveSections(List<SectionDefinition> sections);

  List<CustomSectionItem> getCustomItems(String sectionId);
  Future<void> saveCustomItems(String sectionId, List<CustomSectionItem> items);

  /// Drops a custom section's items along with the section itself.
  Future<void> deleteCustomItems(String sectionId);
}
