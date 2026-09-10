import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/common/data_result.dart';
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
import '../../domain/repositories/portfolio_repo.dart';
import '../data_sources/bundled_content_loader.dart';
import '../data_sources/portfolio_local_data_source.dart';
import '../data_sources/portfolio_remote_data_source.dart';

@LazySingleton(as: PortfolioRepo)
class PortfolioRepoImpl implements PortfolioRepo {
  PortfolioRepoImpl(this._local, this._remote, this._bundled);

  /// The cache and, for everything except [syncFromRemote], the only source
  /// these methods read. Kept synchronous on purpose: the view models were
  /// built around reads that cannot fail or wait.
  final PortfolioLocalDataSource _local;
  final PortfolioRemoteDataSource _remote;
  final BundledContentLoader _bundled;

  /// Every read/write goes through here so a storage failure surfaces as a
  /// [Fail] instead of an unhandled exception inside a cubit.
  ///
  /// The raw [error] is logged here — the only place it is, on this path —
  /// because [failureMessage] is deliberately a short, friendly string for a
  /// snackbar, not the real exception. Without this, the real cause (a
  /// Firestore permission-denied, a plugin error, whatever it actually was)
  /// never reaches anywhere a person can see it.
  Future<DataResult<T>> _guard<T>(
    Future<T> Function() action,
    String failureMessage,
  ) async {
    try {
      return Success<T>(await action());
    } on Object catch (error, stackTrace) {
      debugPrint('$failureMessage: $error');
      debugPrintStack(stackTrace: stackTrace);
      return Fail<T>(failureMessage, error, stackTrace);
    }
  }

  List<T> _sorted<T>(List<T> items, int Function(T) orderOf) {
    final copy = List<T>.of(items)
      ..sort((a, b) => orderOf(a).compareTo(orderOf(b)));
    return copy;
  }

  /// Replaces the entry with a matching id, or appends it at the end.
  List<T> _upserted<T>(List<T> items, T value, String Function(T) idOf) {
    final copy = List<T>.of(items);
    final index = copy.indexWhere((e) => idOf(e) == idOf(value));
    if (index == -1) {
      copy.add(value);
    } else {
      copy[index] = value;
    }
    return copy;
  }

  // Projects ------------------------------------------------------------------

  @override
  Future<DataResult<List<PersonalProject>>> getProjects() => _guard(
    () async => _sorted(_local.getProjects(), (p) => p.order),
    'Could not read projects from local storage',
  );

  @override
  Future<DataResult<List<PersonalProject>>> upsertProject(
    PersonalProject project,
  ) => _guard(() async {
    final next = _upserted(_local.getProjects(), project, (p) => p.id);
    await _local.saveProjects(next);
    return _sorted(next, (p) => p.order);
  }, 'Could not save the project');

  @override
  Future<DataResult<List<PersonalProject>>> deleteProject(String id) =>
      _guard(() async {
        final next = _local.getProjects().where((p) => p.id != id).toList();
        await _local.saveProjects(next);
        return _sorted(next, (p) => p.order);
      }, 'Could not delete the project');

  // Certificates --------------------------------------------------------------

  @override
  Future<DataResult<List<Certificate>>> getCertificates() => _guard(
    () async => _sorted(_local.getCertificates(), (c) => c.order),
    'Could not read certificates from local storage',
  );

  @override
  Future<DataResult<List<Certificate>>> upsertCertificate(
    Certificate certificate,
  ) => _guard(() async {
    final next = _upserted(_local.getCertificates(), certificate, (c) => c.id);
    await _local.saveCertificates(next);
    return _sorted(next, (c) => c.order);
  }, 'Could not save the certificate');

  @override
  Future<DataResult<List<Certificate>>> deleteCertificate(String id) =>
      _guard(() async {
        final next = _local.getCertificates().where((c) => c.id != id).toList();
        await _local.saveCertificates(next);
        return _sorted(next, (c) => c.order);
      }, 'Could not delete the certificate');

  // Work history --------------------------------------------------------------

  @override
  Future<DataResult<List<WorkHistoryEntry>>> getWorkHistory() => _guard(
    () async => _sorted(_local.getWorkHistory(), (e) => e.order),
    'Could not read work history from local storage',
  );

  @override
  Future<DataResult<List<WorkHistoryEntry>>> upsertWorkHistory(
    WorkHistoryEntry entry,
  ) => _guard(() async {
    final next = _upserted(_local.getWorkHistory(), entry, (e) => e.id);
    await _local.saveWorkHistory(next);
    return _sorted(next, (e) => e.order);
  }, 'Could not save the experience entry');

  @override
  Future<DataResult<List<WorkHistoryEntry>>> deleteWorkHistory(String id) =>
      _guard(() async {
        final next = _local.getWorkHistory().where((e) => e.id != id).toList();
        await _local.saveWorkHistory(next);
        return _sorted(next, (e) => e.order);
      }, 'Could not delete the experience entry');

  // Pricing -------------------------------------------------------------------

  @override
  Future<DataResult<List<PricingPackage>>> getPricingPackages() => _guard(
    () async => _sorted(_local.getPricingPackages(), (p) => p.order),
    'Could not read pricing packages from local storage',
  );

  @override
  Future<DataResult<List<PricingPackage>>> upsertPricingPackage(
    PricingPackage package,
  ) => _guard(() async {
    final next = _upserted(_local.getPricingPackages(), package, (p) => p.id);
    await _local.savePricingPackages(next);
    return _sorted(next, (p) => p.order);
  }, 'Could not save the package');

  @override
  Future<DataResult<List<PricingPackage>>> deletePricingPackage(String id) =>
      _guard(() async {
        final next = _local
            .getPricingPackages()
            .where((p) => p.id != id)
            .toList();
        await _local.savePricingPackages(next);
        return _sorted(next, (p) => p.order);
      }, 'Could not delete the package');

  @override
  Future<DataResult<List<PricingAddOn>>> getPricingAddOns() => _guard(
    () async => _sorted(_local.getPricingAddOns(), (a) => a.order),
    'Could not read add-ons from local storage',
  );

  @override
  Future<DataResult<List<PricingAddOn>>> upsertPricingAddOn(
    PricingAddOn addOn,
  ) => _guard(() async {
    final next = _upserted(_local.getPricingAddOns(), addOn, (a) => a.id);
    await _local.savePricingAddOns(next);
    return _sorted(next, (a) => a.order);
  }, 'Could not save the add-on');

  @override
  Future<DataResult<List<PricingAddOn>>> deletePricingAddOn(String id) =>
      _guard(() async {
        final next = _local
            .getPricingAddOns()
            .where((a) => a.id != id)
            .toList();
        await _local.savePricingAddOns(next);
        return _sorted(next, (a) => a.order);
      }, 'Could not delete the add-on');

  // Site-wide content ---------------------------------------------------------

  @override
  Future<DataResult<SiteContent>> getSiteContent() => _guard(
    () async => _local.getSiteContent(),
    'Could not read the site content from local storage',
  );

  @override
  Future<DataResult<SiteContent>> saveSiteContent(SiteContent content) =>
      _guard(() async {
        await _local.saveSiteContent(content);
        return content;
      }, 'Could not save the site content');

  @override
  Future<DataResult<List<SkillGroupEntity>>> getSkillGroups() => _guard(
    () async => _sorted(_local.getSkillGroups(), (g) => g.order),
    'Could not read skill groups from local storage',
  );

  @override
  Future<DataResult<List<SkillGroupEntity>>> upsertSkillGroup(
    SkillGroupEntity group,
  ) => _guard(() async {
    final next = _upserted(_local.getSkillGroups(), group, (g) => g.id);
    await _local.saveSkillGroups(next);
    return _sorted(next, (g) => g.order);
  }, 'Could not save the skill group');

  @override
  Future<DataResult<List<SkillGroupEntity>>> deleteSkillGroup(String id) =>
      _guard(() async {
        final next = _local.getSkillGroups().where((g) => g.id != id).toList();
        await _local.saveSkillGroups(next);
        return _sorted(next, (g) => g.order);
      }, 'Could not delete the skill group');

  @override
  Future<DataResult<List<TechBadgeEntity>>> getTechBadges() => _guard(
    () async => _sorted(_local.getTechBadges(), (b) => b.order),
    'Could not read tech badges from local storage',
  );

  @override
  Future<DataResult<List<TechBadgeEntity>>> upsertTechBadge(
    TechBadgeEntity badge,
  ) => _guard(() async {
    final next = _upserted(_local.getTechBadges(), badge, (b) => b.id);
    await _local.saveTechBadges(next);
    return _sorted(next, (b) => b.order);
  }, 'Could not save the tech badge');

  @override
  Future<DataResult<List<TechBadgeEntity>>> deleteTechBadge(String id) =>
      _guard(() async {
        final next = _local.getTechBadges().where((b) => b.id != id).toList();
        await _local.saveTechBadges(next);
        return _sorted(next, (b) => b.order);
      }, 'Could not delete the tech badge');

  // Section registry ----------------------------------------------------------

  @override
  Future<DataResult<List<SectionDefinition>>> getSections() => _guard(
    () async => _sorted(_local.getSections(), (s) => s.order),
    'Could not read the section list from local storage',
  );

  @override
  Future<DataResult<List<SectionDefinition>>> saveSections(
    List<SectionDefinition> sections,
  ) => _guard(() async {
    // Reorder hands us the intended visual order; renumber so `order` matches
    // the list position rather than trusting whatever the caller set.
    final renumbered = <SectionDefinition>[
      for (var i = 0; i < sections.length; i++) sections[i].copyWith(order: i),
    ];
    await _local.saveSections(renumbered);
    return renumbered;
  }, 'Could not save the section list');

  @override
  Future<DataResult<List<SectionDefinition>>> upsertSection(
    SectionDefinition section,
  ) => _guard(() async {
    final next = _upserted(_local.getSections(), section, (s) => s.id);
    await _local.saveSections(next);
    return _sorted(next, (s) => s.order);
  }, 'Could not save the section');

  @override
  Future<DataResult<List<SectionDefinition>>> deleteCustomSection(String id) =>
      _guard(() async {
        final current = _local.getSections();
        final matches = current.where((s) => s.id == id).toList();
        if (matches.isEmpty) return _sorted(current, (s) => s.order);
        if (!matches.first.isCustom) {
          // Built-in sections are structural — hiding is the supported action.
          throw StateError('Built-in section "$id" cannot be deleted');
        }
        final next = current.where((s) => s.id != id).toList();
        await _local.saveSections(next);
        await _local.deleteCustomItems(id);
        return _sorted(next, (s) => s.order);
      }, 'Could not delete the section');

  // Custom section content ----------------------------------------------------

  @override
  Future<DataResult<List<CustomSectionItem>>> getCustomItems(
    String sectionId,
  ) => _guard(
    () async => _sorted(_local.getCustomItems(sectionId), (i) => i.order),
    'Could not read this section\'s items from local storage',
  );

  @override
  Future<DataResult<List<CustomSectionItem>>> upsertCustomItem(
    CustomSectionItem item,
  ) => _guard(() async {
    final next = _upserted(
      _local.getCustomItems(item.sectionId),
      item,
      (i) => i.id,
    );
    await _local.saveCustomItems(item.sectionId, next);
    return _sorted(next, (i) => i.order);
  }, 'Could not save the item');

  @override
  Future<DataResult<List<CustomSectionItem>>> deleteCustomItem(
    String sectionId,
    String itemId,
  ) => _guard(() async {
    final next = _local
        .getCustomItems(sectionId)
        .where((i) => i.id != itemId)
        .toList();
    await _local.saveCustomItems(sectionId, next);
    return _sorted(next, (i) => i.order);
  }, 'Could not delete the item');

  // Whole-store access --------------------------------------------------------

  @override
  Future<DataResult<PortfolioBundle>> readBundle() => _guard(
    () async => _local.readAll(),
    'Could not read the content bundle from local storage',
  );

  /// Decision D2, in order of preference:
  ///
  /// 1. Remote says the cache is stale -> fetch, cache, use it.
  /// 2. Remote agrees with the cache, or cannot be reached -> use the cache.
  /// 3. No cache either -> the committed JSON asset (D3).
  /// 4. Not even that -> whatever the store holds, which is empty on a device
  ///    that has never synced.
  ///
  /// Steps 2-4 are why this returns [Success] on a failed fetch: a visitor
  /// offline is a state the site renders, not an error to report. Only a
  /// genuine storage fault reaches [Fail].
  @override
  Future<DataResult<PortfolioBundle>> syncFromRemote() => _guard(() async {
    final cached = _local.readAll();

    final meta = await _remote.fetchMeta();
    if (meta != null && !meta.isFromNewerSchema) {
      if (meta.isNewerThan(cached.contentVersion)) {
        final applied = await _fetchAndApply();
        if (applied != null) return applied;
      } else {
        // The common case, and the whole point of the meta document: one read,
        // no payload, cache already correct.
        return cached;
      }
    } else if (meta != null) {
      _warnNewerSchema(meta.schemaVersion);
    }

    if (!cached.isEmpty) return cached;

    // Cold start with nothing to show: a first visit during an outage, or a
    // cleared browser profile with Firestore unreachable.
    final bundled = await _bundled.load();
    if (bundled != null && !bundled.isEmpty) {
      await _local.writeAll(bundled);
      return bundled;
    }

    return _local.readAll();
  }, 'Could not synchronise content');

  @override
  Future<DataResult<PortfolioBundle>> resetToPublished() => _guard(() async {
    // Always re-fetches — see the interface doc for why a version-match
    // short-circuit (as syncFromRemote uses) would be wrong here.
    final applied = await _fetchAndApply();
    if (applied != null) return applied;

    final bundled = await _bundled.load();
    if (bundled != null && !bundled.isEmpty) {
      await _local.writeAll(bundled);
      return bundled;
    }

    throw StateError(
      'Firestore is unreachable and no committed content/portfolio_content.json '
      'fallback exists — nothing trustworthy to reset to.',
    );
  }, 'Could not reset to the published content');

  @override
  Future<DataResult<PortfolioBundle>> publish() => _guard(() async {
    final published = await _remote.writeBundle(_local.readAll());
    // Keeps the cache's version markers in step with what was just published,
    // so the next syncFromRemote reads its own write as already current
    // instead of re-fetching the content it just sent.
    await _local.writeAll(published);
    return published;
  }, 'Could not publish to Firestore');

  /// Fetches the bundle, applies the same newer-schema refusal
  /// [syncFromRemote] uses, and persists it. Null when the fetch failed or the
  /// schema guard rejected it — the caller decides what "nothing usable came
  /// back" means for it.
  Future<PortfolioBundle?> _fetchAndApply() async {
    final fetched = await _remote.fetchBundle();
    if (fetched == null || fetched.isFromNewerSchema) return null;
    await _local.writeAll(fetched);
    return fetched;
  }

  void _warnNewerSchema(int remoteSchemaVersion) {
    debugPrint(
      'Firestore content is schema v$remoteSchemaVersion, newer than this '
      'build (v${PortfolioBundle.currentSchemaVersion}) — staying on cache. '
      'Deploy the newer build to pick it up.',
    );
  }
}
