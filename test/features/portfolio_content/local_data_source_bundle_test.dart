import 'package:flutter_test/flutter_test.dart';
import 'package:marco_portfolio/core/services/shared_preference/shared_pref_keys.dart';
import 'package:marco_portfolio/core/services/shared_preference/shared_preference_helper.dart';
import 'package:marco_portfolio/features/portfolio_content/data/data_sources/portfolio_local_data_source_impl.dart';
import 'package:marco_portfolio/features/portfolio_content/data/seed/seed_certificates.dart';
import 'package:marco_portfolio/features/portfolio_content/data/seed/seed_pricing.dart';
import 'package:marco_portfolio/features/portfolio_content/data/seed/seed_projects.dart';
import 'package:marco_portfolio/features/portfolio_content/data/seed/seed_sections.dart';
import 'package:marco_portfolio/features/portfolio_content/data/seed/seed_site_content.dart';
import 'package:marco_portfolio/features/portfolio_content/data/seed/seed_skills.dart';
import 'package:marco_portfolio/features/portfolio_content/data/seed/seed_work_history.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/custom_section_item.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/portfolio_bundle.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `readAll` / `writeAll` are the seam the whole migration turns on: Phase 1
/// exports through `readAll` to bootstrap Firestore, and every later fetch
/// lands through `writeAll`. A collection quietly dropped by either one loses
/// content permanently and shows up only as a blank section much later.
///
/// This is the Phase 0 acceptance check from `docs/firebase-migration-plan.md`
/// turned into an assertion, so it keeps holding instead of being eyeballed
/// once. It compares against the seeds rather than hard-coded counts, so
/// adding a certificate does not break it — what is pinned is *no loss*, not
/// a particular number.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PortfolioLocalDataSourceImpl source;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await SharedPrefHelper().instantiatePreferences();
    source = PortfolioLocalDataSourceImpl(SharedPrefHelper());
    await source.resetToSeed();
  });

  group('readAll', () {
    test('carries every seeded collection with nothing dropped', () {
      final bundle = source.readAll();

      expect(bundle.projects, SeedProjects.all);
      expect(bundle.certificates, SeedCertificates.all);
      expect(bundle.workHistory, SeedWorkHistory.all);
      expect(bundle.pricingPackages, SeedPricing.packages);
      expect(bundle.pricingAddOns, SeedPricing.addOns);
      expect(bundle.siteContent, SeedSiteContent.value);
      expect(bundle.skillGroups, SeedSkills.groups);
      expect(bundle.techBadges, SeedSkills.techBadges);
      expect(bundle.sections, SeedSections.all);
    });

    test('every seeded collection is actually non-empty', () {
      // Guards the test above: comparing two empty lists passes and proves
      // nothing, which would hide a total seeding failure.
      final bundle = source.readAll();
      expect(bundle.projects, isNotEmpty);
      expect(bundle.certificates, isNotEmpty);
      expect(bundle.workHistory, isNotEmpty);
      expect(bundle.pricingPackages, isNotEmpty);
      expect(bundle.pricingAddOns, isNotEmpty);
      expect(bundle.skillGroups, isNotEmpty);
      expect(bundle.techBadges, isNotEmpty);
      expect(bundle.sections, isNotEmpty);
      expect(bundle.isEmpty, isFalse);
    });

    test('picks up custom section items written after seeding', () async {
      await source.saveCustomItems('extras', const <CustomSectionItem>[
        CustomSectionItem(id: 'x1', sectionId: 'extras', titleEn: 'Extra'),
      ]);

      final bundle = source.readAll();
      expect(bundle.customItems.keys, contains('extras'));
      expect(bundle.customItems['extras']!.single.id, 'x1');
    });

    test('defaults the content version before anything has been published', () {
      expect(source.readAll().contentVersion, 0);
    });
  });

  group('writeAll', () {
    test('round-trips a bundle through storage unchanged', () async {
      final original = source.readAll().copyWith(contentVersion: 5);
      await source.writeAll(original);

      // A fresh instance, so this reads storage rather than the in-memory
      // caches the first one filled — otherwise the test would pass even if
      // nothing were persisted at all.
      final reread = PortfolioLocalDataSourceImpl(SharedPrefHelper()).readAll();
      expect(reread, original);
    });

    test('records the version markers for the next read to compare', () async {
      await source.writeAll(
        source.readAll().copyWith(contentVersion: 42, schemaVersion: 1),
      );

      final prefs = SharedPrefHelper();
      expect(prefs.getInt(key: SharedPrefKeys.contentVersion), 42);
      expect(prefs.getInt(key: SharedPrefKeys.schemaVersion), 1);
    });

    test('sweeps custom sections that are absent from the incoming bundle', () async {
      await source.saveCustomItems('gone', const <CustomSectionItem>[
        CustomSectionItem(id: 'g1', sectionId: 'gone', titleEn: 'Doomed'),
      ]);
      expect(source.readAll().customItems.keys, contains('gone'));

      // A section deleted upstream must not survive locally: left behind, the
      // next export would silently resurrect it into Firestore.
      await source.writeAll(
        source.readAll().copyWith(
          customItems: const <String, List<CustomSectionItem>>{},
        ),
      );

      expect(source.readAll().customItems, isEmpty);
      expect(
        PortfolioLocalDataSourceImpl(SharedPrefHelper()).readAll().customItems,
        isEmpty,
      );
    });

    test('an empty bundle empties the store rather than being ignored', () async {
      await source.writeAll(const PortfolioBundle());

      final reread = PortfolioLocalDataSourceImpl(SharedPrefHelper()).readAll();
      expect(reread.projects, isEmpty);
      expect(reread.sections, isEmpty);
      expect(reread.isEmpty, isTrue);
    });
  });
}
