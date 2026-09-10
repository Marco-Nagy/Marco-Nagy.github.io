import 'package:flutter_test/flutter_test.dart';
import 'package:marco_portfolio/core/common/data_result.dart';
import 'package:marco_portfolio/core/services/shared_preference/shared_preference_helper.dart';
import 'package:marco_portfolio/features/portfolio_content/data/data_sources/bundled_content_loader.dart';
import 'package:marco_portfolio/features/portfolio_content/data/data_sources/portfolio_local_data_source_impl.dart';
import 'package:marco_portfolio/features/portfolio_content/data/data_sources/portfolio_remote_data_source.dart';
import 'package:marco_portfolio/features/portfolio_content/data/repositories/portfolio_repo_impl.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/certificate.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/portfolio_bundle.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/section_definition.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The read path from decision D2. Its whole job is to be boring in every
/// failure mode: a visitor with no network, a project not yet published, and a
/// cache already current must all end up rendering content, and only the third
/// of those may cost a second Firestore read.
///
/// The read count is the reason this file exists. `content/meta` exists purely
/// so a returning visitor spends one read instead of pulling the whole bundle,
/// and nothing in the type system stops a future edit from fetching the bundle
/// unconditionally — the counters here do.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Enough content that `isEmpty` is false, without dragging in the seeds.
  PortfolioBundle contentAt(int version, {String marker = 'remote'}) =>
      PortfolioBundle(
        sections: <SectionDefinition>[
          SectionDefinition(
            id: marker,
            titleEn: marker,
            type: SectionType.listRows,
            kind: SectionKind.custom,
          ),
        ],
        certificates: <Certificate>[
          Certificate(id: marker, title: marker),
        ],
        contentVersion: version,
      );

  late PortfolioLocalDataSourceImpl local;
  late _FakeRemote remote;
  late _FakeBundled bundled;
  late PortfolioRepoImpl repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await SharedPrefHelper().instantiatePreferences();
    local = PortfolioLocalDataSourceImpl(SharedPrefHelper());
    remote = _FakeRemote();
    bundled = _FakeBundled();
    repo = PortfolioRepoImpl(local, remote, bundled);
  });

  // SharedPrefHelper caches its SharedPreferences instance on first use
  // (`_prefs ??=`), so without this every test after the first in this file
  // would keep reading the previous test's data — setMockInitialValues
  // replaces the mock's backing store, not that already-cached instance.
  tearDown(SharedPrefHelper.resetForTesting);

  Future<PortfolioBundle> sync() async {
    final result = await repo.syncFromRemote();
    expect(result, isA<Success<PortfolioBundle>>());
    return (result as Success<PortfolioBundle>).data;
  }

  group('cache is current', () {
    test('costs one read and never fetches the bundle', () async {
      await local.writeAll(contentAt(4, marker: 'cached'));
      remote.meta = const PortfolioMeta(contentVersion: 4);
      remote.bundle = contentAt(4);

      final synced = await sync();

      expect(remote.metaReads, 1);
      expect(remote.bundleReads, 0, reason: 'the whole point of content/meta');
      expect(synced.sections.single.id, 'cached');
    });
  });

  group('cache is stale', () {
    test('fetches the bundle and rewrites the cache', () async {
      await local.writeAll(contentAt(1, marker: 'old'));
      remote.meta = const PortfolioMeta(contentVersion: 2);
      remote.bundle = contentAt(2, marker: 'new');

      final synced = await sync();

      expect(remote.bundleReads, 1);
      expect(synced.sections.single.id, 'new');
      // Persisted, not just returned: the next launch must not re-fetch.
      expect(local.readAll().sections.single.id, 'new');
      expect(local.readAll().contentVersion, 2);
    });
  });

  group('remote unavailable', () {
    test('falls back to the cache without failing', () async {
      await local.writeAll(contentAt(3, marker: 'cached'));
      remote.meta = null;

      final synced = await sync();

      expect(synced.sections.single.id, 'cached');
      expect(remote.bundleReads, 0);
    });

    test('a bundle fetch that fails mid-way leaves the cache intact', () async {
      await local.writeAll(contentAt(1, marker: 'cached'));
      remote.meta = const PortfolioMeta(contentVersion: 9);
      remote.bundle = null; // meta says newer, but the payload never arrives

      final synced = await sync();

      expect(synced.sections.single.id, 'cached');
      expect(local.readAll().contentVersion, 1, reason: 'version must not move');
    });
  });

  group('cold start', () {
    test('uses the committed JSON when there is no cache and no remote',
        () async {
      remote.meta = null;
      bundled.value = contentAt(0, marker: 'committed');

      final synced = await sync();

      expect(synced.sections.single.id, 'committed');
      expect(local.readAll().sections.single.id, 'committed');
    });

    test('prefers Firestore over the committed JSON', () async {
      remote.meta = const PortfolioMeta(contentVersion: 1);
      remote.bundle = contentAt(1, marker: 'remote');
      bundled.value = contentAt(0, marker: 'committed');

      expect((await sync()).sections.single.id, 'remote');
      expect(bundled.loads, 0, reason: 'no reason to read the floor asset');
    });

    test('survives having nothing at all', () async {
      remote.meta = null;
      bundled.value = null;

      final synced = await sync();

      expect(synced.isEmpty, isTrue);
    });
  });

  group('schema guard', () {
    test('refuses a bundle written by a newer build', () async {
      await local.writeAll(contentAt(1, marker: 'cached'));
      remote.meta = const PortfolioMeta(
        contentVersion: 2,
        schemaVersion: PortfolioBundle.currentSchemaVersion + 1,
      );
      remote.bundle = contentAt(2, marker: 'future');

      final synced = await sync();

      // Writing a shape this build cannot represent would corrupt a cache
      // that currently works, so a stale render is the better outcome.
      expect(synced.sections.single.id, 'cached');
      expect(remote.bundleReads, 0);
      expect(local.readAll().contentVersion, 1);
    });
  });
}

class _FakeRemote implements PortfolioRemoteDataSource {
  PortfolioMeta? meta;
  PortfolioBundle? bundle;
  int metaReads = 0;
  int bundleReads = 0;

  @override
  Future<PortfolioMeta?> fetchMeta() async {
    metaReads++;
    return meta;
  }

  @override
  Future<PortfolioBundle?> fetchBundle() async {
    bundleReads++;
    return bundle;
  }

  @override
  Future<PortfolioBundle> writeBundle(PortfolioBundle bundle) async =>
      bundle.copyWith(contentVersion: bundle.contentVersion + 1);
}

class _FakeBundled implements BundledContentLoader {
  PortfolioBundle? value;
  int loads = 0;

  @override
  Future<PortfolioBundle?> load() async {
    loads++;
    return value;
  }
}
