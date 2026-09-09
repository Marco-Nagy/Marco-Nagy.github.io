import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../../core/services/shared_preference/shared_pref_keys.dart';
import '../../../../core/services/shared_preference/shared_preference_helper.dart';
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
import '../seed/seed_certificates.dart';
import '../seed/seed_pricing.dart';
import '../seed/seed_projects.dart';
import '../seed/seed_sections.dart';
import '../seed/seed_site_content.dart';
import '../seed/seed_skills.dart';
import '../seed/seed_work_history.dart';
import 'portfolio_local_data_source.dart';

@LazySingleton(as: PortfolioLocalDataSource)
class PortfolioLocalDataSourceImpl implements PortfolioLocalDataSource {
  PortfolioLocalDataSourceImpl(this._prefs);

  final SharedPrefHelper _prefs;

  // In-memory cache, one entry per storage key -------------------------------
  //
  // `shared_preferences` already keeps its own strings in memory, but every
  // read here used to still re-run `json.decode` (and the `fromJson` mapping)
  // on that whole string from scratch — for most sections that is small
  // change, but a project can carry an embedded (not-yet-pinned) screenshot
  // or GIF as base64, and that string rides inside the *same* JSON blob as
  // every other project. Re-parsing megabytes of it on every single page
  // visit or save is real, synchronous, UI-thread work — which is what was
  // actually behind "the edit button hangs after adding a GIF": the hang was
  // never about rendering the GIF, it was about re-decoding the whole
  // projects list around it, repeatedly, for no reason.
  //
  // `compute()` is the usual fix for CPU-bound work like this, but it runs
  // the callback on the *same* thread on Flutter Web (there is no worker
  // isolate to hand it off to there), so it would not have helped the actual
  // platform this was slow on. Caching the decoded list instead removes
  // almost all of the repeated work outright, on every platform: decode runs
  // at most once per key per app session, and a write updates the cache
  // directly from the value just saved instead of reading its own write back.
  List<PersonalProject>? _projectsCache;
  List<Certificate>? _certificatesCache;
  List<WorkHistoryEntry>? _workHistoryCache;
  List<PricingPackage>? _pricingPackagesCache;
  List<PricingAddOn>? _pricingAddOnsCache;
  SiteContent? _siteContentCache;
  List<SkillGroupEntity>? _skillGroupsCache;
  List<TechBadgeEntity>? _techBadgesCache;
  List<SectionDefinition>? _sectionsCache;
  final Map<String, List<CustomSectionItem>> _customItemsCache =
      <String, List<CustomSectionItem>>{};

  @override
  Future<void> seedIfEmpty() async {
    if (_prefs.getBool(key: SharedPrefKeys.seeded)) return;
    await resetToSeed();
  }

  @override
  Future<void> resetToSeed() async {
    // Custom sections are a debug-time creation, so a reset clears them
    // entirely rather than trying to merge them with the seed.
    for (final key in _prefs.keysWithPrefix(
      SharedPrefKeys.customSectionItemsPrefix,
    )) {
      await _prefs.removePreference(key: key);
    }
    _customItemsCache.clear();

    await saveProjects(SeedProjects.all);
    await saveCertificates(SeedCertificates.all);
    await saveWorkHistory(SeedWorkHistory.all);
    await savePricingPackages(SeedPricing.packages);
    await savePricingAddOns(SeedPricing.addOns);
    await saveSiteContent(SeedSiteContent.value);
    await saveSkillGroups(SeedSkills.groups);
    await saveTechBadges(SeedSkills.techBadges);
    await saveSections(SeedSections.all);
    await _prefs.setBool(key: SharedPrefKeys.seeded, value: true);
  }

  // Whole-store access --------------------------------------------------------

  @override
  PortfolioBundle readAll() {
    return PortfolioBundle(
      projects: getProjects(),
      certificates: getCertificates(),
      workHistory: getWorkHistory(),
      pricingPackages: getPricingPackages(),
      pricingAddOns: getPricingAddOns(),
      siteContent: getSiteContent(),
      skillGroups: getSkillGroups(),
      techBadges: getTechBadges(),
      sections: getSections(),
      customItems: _readAllCustomItems(),
      schemaVersion: _prefs.containPreference(key: SharedPrefKeys.schemaVersion)
          ? _prefs.getInt(key: SharedPrefKeys.schemaVersion)
          : PortfolioBundle.currentSchemaVersion,
      contentVersion: _prefs.getInt(key: SharedPrefKeys.contentVersion),
    );
  }

  /// Sweeps every `portfolio_custom_items_*` key rather than deriving the ids
  /// from [getSections]: a section row and its items are separate keys, so
  /// reading from the sections list would silently drop items whose section
  /// row is missing — exactly the case worth surfacing rather than hiding.
  Map<String, List<CustomSectionItem>> _readAllCustomItems() {
    final prefix = SharedPrefKeys.customSectionItemsPrefix;
    final result = <String, List<CustomSectionItem>>{};
    for (final key in _prefs.keysWithPrefix(prefix)) {
      final sectionId = key.substring(prefix.length);
      if (sectionId.isEmpty) continue;
      final items = getCustomItems(sectionId);
      if (items.isNotEmpty) result[sectionId] = items;
    }
    return result;
  }

  @override
  Future<void> writeAll(PortfolioBundle bundle) async {
    // Sweep first: a custom section deleted upstream must not survive here as
    // an orphaned key that `readAll` would then hand back on the next export.
    for (final key in _prefs.keysWithPrefix(
      SharedPrefKeys.customSectionItemsPrefix,
    )) {
      await _prefs.removePreference(key: key);
    }
    _customItemsCache.clear();

    await saveProjects(bundle.projects);
    await saveCertificates(bundle.certificates);
    await saveWorkHistory(bundle.workHistory);
    await savePricingPackages(bundle.pricingPackages);
    await savePricingAddOns(bundle.pricingAddOns);
    await saveSiteContent(bundle.siteContent);
    await saveSkillGroups(bundle.skillGroups);
    await saveTechBadges(bundle.techBadges);
    await saveSections(bundle.sections);
    for (final entry in bundle.customItems.entries) {
      await saveCustomItems(entry.key, entry.value);
    }

    // Written last, so an interrupted write leaves the version *behind* the
    // content rather than ahead of it. A stale-low version costs one extra
    // fetch; a stale-high one would pin the visitor to a half-written cache.
    await _prefs.setInt(
      key: SharedPrefKeys.schemaVersion,
      value: bundle.schemaVersion,
    );
    await _prefs.setInt(
      key: SharedPrefKeys.contentVersion,
      value: bundle.contentVersion,
    );
  }

  // Shared JSON helpers -------------------------------------------------------

  /// A corrupt or schema-drifted payload falls back rather than leaving the
  /// visitor on an empty page. Only reached on a cache miss — see the class
  /// doc comment on the cache fields above.
  List<T> _decodeList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
    List<T> fallback,
  ) {
    final raw = _prefs.containPreference(key: key)
        ? _prefs.getString(key: key)
        : null;
    if (raw == null || raw.trim().isEmpty) return fallback;
    try {
      final decoded = json.decode(raw) as List<dynamic>;
      return decoded
          .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false);
    } on Object {
      return fallback;
    }
  }

  Future<void> _writeList<T>(
    String key,
    List<T> items,
    Map<String, dynamic> Function(T) toJson,
  ) {
    return _prefs.setString(
      key: key,
      stringValue: json.encode(items.map(toJson).toList()),
    );
  }

  T _decodeObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
    T fallback,
  ) {
    final raw = _prefs.containPreference(key: key)
        ? _prefs.getString(key: key)
        : null;
    if (raw == null || raw.trim().isEmpty) return fallback;
    try {
      return fromJson(Map<String, dynamic>.from(json.decode(raw) as Map));
    } on Object {
      return fallback;
    }
  }

  Future<void> _writeObject(String key, Map<String, dynamic> value) =>
      _prefs.setString(key: key, stringValue: json.encode(value));

  // Built-in section content --------------------------------------------------

  @override
  List<PersonalProject> getProjects() => _projectsCache ??= _decodeList(
    SharedPrefKeys.projects,
    PersonalProject.fromJson,
    const <PersonalProject>[],
  );

  @override
  Future<void> saveProjects(List<PersonalProject> projects) async {
    await _writeList(SharedPrefKeys.projects, projects, (p) => p.toJson());
    _projectsCache = projects;
  }

  @override
  List<Certificate> getCertificates() => _certificatesCache ??= _decodeList(
    SharedPrefKeys.certificates,
    Certificate.fromJson,
    const <Certificate>[],
  );

  @override
  Future<void> saveCertificates(List<Certificate> certificates) async {
    await _writeList(
      SharedPrefKeys.certificates,
      certificates,
      (c) => c.toJson(),
    );
    _certificatesCache = certificates;
  }

  @override
  List<WorkHistoryEntry> getWorkHistory() => _workHistoryCache ??= _decodeList(
    SharedPrefKeys.workHistory,
    WorkHistoryEntry.fromJson,
    const <WorkHistoryEntry>[],
  );

  @override
  Future<void> saveWorkHistory(List<WorkHistoryEntry> entries) async {
    await _writeList(SharedPrefKeys.workHistory, entries, (e) => e.toJson());
    _workHistoryCache = entries;
  }

  @override
  List<PricingPackage> getPricingPackages() =>
      _pricingPackagesCache ??= _decodeList(
        SharedPrefKeys.pricingPackages,
        PricingPackage.fromJson,
        const <PricingPackage>[],
      );

  @override
  Future<void> savePricingPackages(List<PricingPackage> packages) async {
    await _writeList(
      SharedPrefKeys.pricingPackages,
      packages,
      (p) => p.toJson(),
    );
    _pricingPackagesCache = packages;
  }

  @override
  List<PricingAddOn> getPricingAddOns() => _pricingAddOnsCache ??= _decodeList(
    SharedPrefKeys.pricingAddOns,
    PricingAddOn.fromJson,
    const <PricingAddOn>[],
  );

  @override
  Future<void> savePricingAddOns(List<PricingAddOn> addOns) async {
    await _writeList(SharedPrefKeys.pricingAddOns, addOns, (a) => a.toJson());
    _pricingAddOnsCache = addOns;
  }

  // Site-wide content ---------------------------------------------------------

  @override
  SiteContent getSiteContent() {
    final cached = _siteContentCache;
    if (cached != null) return cached;
    final content = _decodeObject(
      SharedPrefKeys.siteContent,
      SiteContent.fromJson,
      SeedSiteContent.value,
    );
    _siteContentCache = content;
    return content;
  }

  @override
  Future<void> saveSiteContent(SiteContent content) async {
    await _writeObject(SharedPrefKeys.siteContent, content.toJson());
    _siteContentCache = content;
  }

  @override
  List<SkillGroupEntity> getSkillGroups() => _skillGroupsCache ??= _decodeList(
    SharedPrefKeys.skillGroups,
    SkillGroupEntity.fromJson,
    const <SkillGroupEntity>[],
  );

  @override
  Future<void> saveSkillGroups(List<SkillGroupEntity> groups) async {
    await _writeList(SharedPrefKeys.skillGroups, groups, (g) => g.toJson());
    _skillGroupsCache = groups;
  }

  @override
  List<TechBadgeEntity> getTechBadges() => _techBadgesCache ??= _decodeList(
    SharedPrefKeys.techBadges,
    TechBadgeEntity.fromJson,
    const <TechBadgeEntity>[],
  );

  @override
  Future<void> saveTechBadges(List<TechBadgeEntity> badges) async {
    await _writeList(SharedPrefKeys.techBadges, badges, (b) => b.toJson());
    _techBadgesCache = badges;
  }

  // Section registry ----------------------------------------------------------

  @override
  List<SectionDefinition> getSections() => _sectionsCache ??= _decodeList(
    SharedPrefKeys.sectionDefinitions,
    SectionDefinition.fromJson,
    const <SectionDefinition>[],
  );

  @override
  Future<void> saveSections(List<SectionDefinition> sections) async {
    await _writeList(
      SharedPrefKeys.sectionDefinitions,
      sections,
      (s) => s.toJson(),
    );
    _sectionsCache = sections;
  }

  @override
  List<CustomSectionItem> getCustomItems(String sectionId) =>
      _customItemsCache[sectionId] ??= _decodeList(
        SharedPrefKeys.customSectionItems(sectionId),
        CustomSectionItem.fromJson,
        const <CustomSectionItem>[],
      );

  @override
  Future<void> saveCustomItems(
    String sectionId,
    List<CustomSectionItem> items,
  ) async {
    await _writeList(
      SharedPrefKeys.customSectionItems(sectionId),
      items,
      (i) => i.toJson(),
    );
    _customItemsCache[sectionId] = items;
  }

  @override
  Future<void> deleteCustomItems(String sectionId) async {
    await _prefs.removePreference(
      key: SharedPrefKeys.customSectionItems(sectionId),
    );
    _customItemsCache.remove(sectionId);
  }
}
