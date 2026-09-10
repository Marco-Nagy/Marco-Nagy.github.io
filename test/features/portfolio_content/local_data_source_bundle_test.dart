import 'package:flutter_test/flutter_test.dart';
import 'package:marco_portfolio/core/services/shared_preference/shared_pref_keys.dart';
import 'package:marco_portfolio/core/services/shared_preference/shared_preference_helper.dart';
import 'package:marco_portfolio/features/portfolio_content/data/data_sources/portfolio_local_data_source_impl.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/custom_section_item.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/portfolio_bundle.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sample_bundle.dart';

/// `readAll` / `writeAll` are the seam the whole migration turns on: Phase 1
/// exports through `readAll` to bootstrap Firestore, and every later fetch
/// lands through `writeAll`. A collection quietly dropped by either one loses
/// content permanently and shows up only as a blank section much later.
///
/// This composes and decomposes a bundle purely through those two methods —
/// there is no seeding step in between any more. Local storage stopped being
/// something the app populates with default content the moment Firestore
/// became the source of truth; it is a cache that starts empty and is filled
/// by whatever `writeAll` is given, whether that is a synced remote bundle or,
/// here, a test fixture.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PortfolioLocalDataSourceImpl source;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await SharedPrefHelper().instantiatePreferences();
    source = PortfolioLocalDataSourceImpl(SharedPrefHelper());
  });

  // SharedPrefHelper caches its SharedPreferences instance on first use, so
  // without this every test after the first would keep reading whatever the
  // previous one wrote — setMockInitialValues replaces the mock's backing
  // store, not the already-cached instance.
  tearDown(SharedPrefHelper.resetForTesting);

  group('a fresh store', () {
    test('reads as a completely empty bundle', () {
      final bundle = source.readAll();
      expect(bundle.isEmpty, isTrue);
      expect(bundle.projects, isEmpty);
      expect(bundle.sections, isEmpty);
      expect(bundle.contentVersion, 0);
    });
  });

  group('writeAll then readAll', () {
    test('round-trips every collection with nothing dropped', () async {
      final written = sampleBundle(contentVersion: 3);
      await source.writeAll(written);

      final reread = source.readAll();
      expect(reread, written);
    });

    test('is actually read from storage, not an in-memory fluke', () async {
      await source.writeAll(sampleBundle(contentVersion: 3));

      // A fresh instance, so this can only see what was persisted — the
      // first instance's in-memory caches are not shared with it.
      final reread = PortfolioLocalDataSourceImpl(SharedPrefHelper()).readAll();
      expect(reread.contentVersion, 3);
      expect(reread.projects, isNotEmpty);
    });

    test('records the version markers for the sync path to compare', () async {
      await source.writeAll(
        sampleBundle(contentVersion: 42, schemaVersion: 1),
      );

      final prefs = SharedPrefHelper();
      expect(prefs.getInt(key: SharedPrefKeys.contentVersion), 42);
      expect(prefs.getInt(key: SharedPrefKeys.schemaVersion), 1);
    });

    test('picks up custom section items across the same round trip', () async {
      await source.writeAll(sampleBundle());

      final bundle = source.readAll();
      expect(bundle.customItems.keys, contains('section-1'));
      expect(bundle.customItems['section-1']!.single.id, 'item-1');
    });

    test('sweeps custom sections absent from the incoming bundle', () async {
      await source.saveCustomItems('gone', const <CustomSectionItem>[
        CustomSectionItem(id: 'g1', sectionId: 'gone', titleEn: 'Doomed'),
      ]);
      expect(source.readAll().customItems.keys, contains('gone'));

      // A section deleted upstream must not survive locally: left behind, the
      // next export would silently resurrect it into Firestore.
      await source.writeAll(sampleBundle());

      expect(source.readAll().customItems.keys, isNot(contains('gone')));
      expect(
        PortfolioLocalDataSourceImpl(
          SharedPrefHelper(),
        ).readAll().customItems.keys,
        isNot(contains('gone')),
      );
    });

    test('an empty bundle empties the store rather than being ignored', () async {
      await source.writeAll(sampleBundle(contentVersion: 3));
      await source.writeAll(const PortfolioBundle());

      final reread = PortfolioLocalDataSourceImpl(SharedPrefHelper()).readAll();
      expect(reread.projects, isEmpty);
      expect(reread.sections, isEmpty);
      expect(reread.isEmpty, isTrue);
    });
  });
}
