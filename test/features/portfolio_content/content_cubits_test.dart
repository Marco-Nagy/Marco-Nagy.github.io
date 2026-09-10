import 'package:flutter_test/flutter_test.dart';
import 'package:marco_portfolio/core/common/data_result.dart';
import 'package:marco_portfolio/core/services/shared_preference/shared_preference_helper.dart';
import 'package:marco_portfolio/features/portfolio_content/data/data_sources/bundled_content_loader.dart';
import 'package:marco_portfolio/features/portfolio_content/data/data_sources/portfolio_local_data_source_impl.dart';
import 'package:marco_portfolio/features/portfolio_content/data/data_sources/portfolio_remote_data_source.dart';
import 'package:marco_portfolio/features/portfolio_content/data/repositories/portfolio_repo_impl.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/portfolio_bundle.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/section_definition.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/site_content.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/skill_group_entity.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/tech_badge_entity.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/use_cases/sections_use_case.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/use_cases/site_content_use_case.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/use_cases/skills_use_case.dart';
import 'package:marco_portfolio/features/portfolio_content/presentation/view_model/sections_actions.dart';
import 'package:marco_portfolio/features/portfolio_content/presentation/view_model/sections_states.dart';
import 'package:marco_portfolio/features/portfolio_content/presentation/view_model/sections_view_model.dart';
import 'package:marco_portfolio/features/portfolio_content/presentation/view_model/site_content_actions.dart';
import 'package:marco_portfolio/features/portfolio_content/presentation/view_model/site_content_states.dart';
import 'package:marco_portfolio/features/portfolio_content/presentation/view_model/site_content_view_model.dart';
import 'package:marco_portfolio/features/portfolio_content/presentation/view_model/skills_actions.dart';
import 'package:marco_portfolio/features/portfolio_content/presentation/view_model/skills_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The three cubits Phase 3 added, over the real repository and local store.
///
/// Their contract is unusual and easy to break by accident: they feed the nav
/// bar, the footer and the splash mark, which are on screen before any read
/// completes. So every field must be non-null from construction and must never
/// go *backwards* — a failed read has to leave the last good value alone
/// rather than blanking the chrome that is already painted.
///
/// The ordering assertions matter for the same reason. `order` is an admin-set
/// integer with nothing stopping two sections from sharing one, so the nav
/// sorts rather than trusting the stored sequence.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PortfolioLocalDataSourceImpl local;
  late PortfolioRepoImpl repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await SharedPrefHelper().instantiatePreferences();
    local = PortfolioLocalDataSourceImpl(SharedPrefHelper());
    repo = PortfolioRepoImpl(local, _OfflineRemote(), _NoBundledContent());
  });

  // SharedPrefHelper caches its instance on first use, so without this every
  // test after the first would read the previous test's data.
  tearDown(SharedPrefHelper.resetForTesting);

  group('SectionsCubit', () {
    /// Deliberately stored out of order and with one section hidden — the two
    /// things `visible` exists to correct.
    Future<SectionsCubit> loadedWith(List<SectionDefinition> sections) async {
      await local.writeAll(PortfolioBundle(sections: sections));
      final cubit = SectionsCubit(SectionsUseCase(repo))
        ..doAction(LoadSections());
      await Future<void>.delayed(Duration.zero);
      return cubit;
    }

    test(
      'renders no links before the first read, rather than a placeholder',
      () {
        final cubit = SectionsCubit(SectionsUseCase(repo));

        expect(cubit.sections, isEmpty);
        expect(cubit.visible, isEmpty);
        expect(cubit.state, isA<SectionsInitial>());
      },
    );

    test('drops hidden sections and applies order', () async {
      final cubit = await loadedWith(<SectionDefinition>[
        const SectionDefinition(
          id: 'contact',
          type: SectionType.contact,
          order: 6,
        ),
        const SectionDefinition(
          id: 'pricing',
          type: SectionType.pricing,
          order: 5,
          visible: false,
        ),
        const SectionDefinition(id: 'home', type: SectionType.hero),
      ]);

      expect(cubit.visible.map((s) => s.id), <String>['home', 'contact']);
      // Hiding a section must not delete it: the admin still has to find it to
      // switch it back on.
      expect(cubit.sections, hasLength(3));
      expect(cubit.byId('pricing'), isNotNull);
    });

    test('byId returns null for a section that is not there', () async {
      final cubit = await loadedWith(<SectionDefinition>[
        const SectionDefinition(id: 'home', type: SectionType.hero),
      ]);

      expect(cubit.byId('nope'), isNull);
    });

    test('visible cannot be mutated by a caller', () async {
      final cubit = await loadedWith(<SectionDefinition>[
        const SectionDefinition(id: 'home', type: SectionType.hero),
      ]);

      expect(
        () => cubit.visible.add(
          const SectionDefinition(id: 'x', type: SectionType.hero),
        ),
        throwsUnsupportedError,
      );
    });
  });

  group('SkillsCubit', () {
    test('sorts both collections by order', () async {
      await local.writeAll(
        PortfolioBundle(
          skillGroups: <SkillGroupEntity>[
            const SkillGroupEntity(id: 'other', labelEn: 'Other', order: 6),
            const SkillGroupEntity(id: 'state', labelEn: 'State', order: 0),
          ],
          techBadges: <TechBadgeEntity>[
            const TechBadgeEntity(id: 'cicd', label: 'CI/CD', order: 5),
            const TechBadgeEntity(id: 'flutter', label: 'Flutter'),
          ],
        ),
      );

      final cubit = SkillsCubit(SkillsUseCase(repo))..doAction(LoadSkills());
      await Future<void>.delayed(Duration.zero);

      expect(cubit.orderedGroups.map((g) => g.id), <String>['state', 'other']);
      expect(cubit.orderedBadges.map((b) => b.id), <String>['flutter', 'cicd']);
    });

    test(
      'starts empty so the hero orbit has nothing to draw, not a spinner',
      () {
        final cubit = SkillsCubit(SkillsUseCase(repo));

        expect(cubit.orderedGroups, isEmpty);
        expect(cubit.orderedBadges, isEmpty);
      },
    );
  });

  // Phase 4c gave both of these cubits a UI that dispatches Save*, which
  // nothing had ever done. The failure mode to guard is an upsert that appends
  // instead of replacing: on screen that reads as the edited record appearing
  // twice, or a hidden section quietly coming back, and it survives a reload
  // because the duplicate is really in the store.
  group('editing through the cubits', () {
    test('hiding a section replaces it rather than adding a second', () async {
      await local.writeAll(
        PortfolioBundle(
          sections: <SectionDefinition>[
            const SectionDefinition(id: 'home', type: SectionType.hero),
            const SectionDefinition(
              id: 'pricing',
              type: SectionType.pricing,
              order: 1,
            ),
          ],
        ),
      );

      final cubit = SectionsCubit(SectionsUseCase(repo))
        ..doAction(LoadSections());
      await Future<void>.delayed(Duration.zero);

      cubit.doAction(
        SaveSection(cubit.byId('pricing')!.copyWith(visible: false)),
      );
      await Future<void>.delayed(Duration.zero);

      expect(cubit.sections, hasLength(2));
      expect(cubit.visible.map((s) => s.id), <String>['home']);

      // A fresh cubit over the same store: the toggle has to have reached
      // storage, not just the in-memory list the screen was reading.
      final reloaded = SectionsCubit(SectionsUseCase(repo))
        ..doAction(LoadSections());
      await Future<void>.delayed(Duration.zero);

      expect(reloaded.sections, hasLength(2));
      expect(reloaded.byId('pricing')!.visible, isFalse);
    });

    test('renaming a section keeps everything else on it', () async {
      await local.writeAll(
        PortfolioBundle(
          sections: <SectionDefinition>[
            const SectionDefinition(
              id: 'about',
              type: SectionType.statement,
              titleEn: 'About',
              titleAr: 'نبذة',
              order: 3,
            ),
          ],
        ),
      );

      final cubit = SectionsCubit(SectionsUseCase(repo))
        ..doAction(LoadSections());
      await Future<void>.delayed(Duration.zero);

      cubit.doAction(
        SaveSection(cubit.byId('about')!.copyWith(titleEn: 'Who I am')),
      );
      await Future<void>.delayed(Duration.zero);

      final saved = cubit.byId('about')!;
      expect(saved.titleEn, 'Who I am');
      expect(saved.titleAr, 'نبذة');
      expect(saved.order, 3);
      expect(saved.type, SectionType.statement);
    });

    test(
      'editing a skill group replaces it rather than adding a second',
      () async {
        await local.writeAll(
          PortfolioBundle(
            skillGroups: <SkillGroupEntity>[
              const SkillGroupEntity(
                id: 'state',
                labelEn: 'State',
                skills: <String>['Bloc'],
              ),
            ],
          ),
        );

        final cubit = SkillsCubit(SkillsUseCase(repo))..doAction(LoadSkills());
        await Future<void>.delayed(Duration.zero);

        cubit.doAction(
          SaveSkillGroup(
            cubit.orderedGroups.single.copyWith(
              skills: <String>['Bloc', 'Provider'],
            ),
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(cubit.orderedGroups, hasLength(1));
        expect(cubit.orderedGroups.single.skills, <String>['Bloc', 'Provider']);
      },
    );

    test('adding a skill group leaves the existing ones alone', () async {
      await local.writeAll(
        PortfolioBundle(
          skillGroups: <SkillGroupEntity>[
            const SkillGroupEntity(id: 'state', labelEn: 'State'),
          ],
        ),
      );

      final cubit = SkillsCubit(SkillsUseCase(repo))..doAction(LoadSkills());
      await Future<void>.delayed(Duration.zero);

      cubit.doAction(
        SaveSkillGroup(
          const SkillGroupEntity(id: 'ci', labelEn: 'CI/CD', order: 1),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(cubit.orderedGroups.map((g) => g.id), <String>['state', 'ci']);
    });
  });

  group('SiteContentCubit', () {
    test('holds usable defaults before any read lands', () {
      final cubit = SiteContentCubit(SiteContentUseCase(repo));

      // The monogram is the one field with a real default, because it is the
      // first thing the nav bar paints.
      expect(cubit.content.monogram, 'MN');
      expect(cubit.content.fullNameEn, isEmpty);
    });

    test('loads the stored content', () async {
      await local.writeAll(
        const PortfolioBundle(
          siteContent: SiteContent(fullNameEn: 'Marco Nagy', monogram: 'MNL'),
        ),
      );

      final cubit = SiteContentCubit(SiteContentUseCase(repo))
        ..doAction(LoadSiteContent());
      await Future<void>.delayed(Duration.zero);

      expect(cubit.content.fullNameEn, 'Marco Nagy');
      expect(cubit.content.monogram, 'MNL');
      expect(cubit.state, isA<SiteContentReady>());
    });

    test('a failed read leaves the last good value on screen', () async {
      final useCase = _SwitchableSiteContent();
      final cubit = SiteContentCubit(useCase)..doAction(LoadSiteContent());
      await Future<void>.delayed(Duration.zero);
      expect(cubit.content.fullNameEn, 'Marco Nagy');

      useCase.failing = true;
      cubit.doAction(LoadSiteContent());
      await Future<void>.delayed(Duration.zero);

      // The failure is reported for the admin form, but the footer and nav
      // keep the name they were already showing rather than blanking.
      expect(cubit.state, isA<SiteContentFailure>());
      expect(cubit.content.fullNameEn, 'Marco Nagy');
    });
  });
}

/// A visitor with no network. Reads return null, which the repository treats as
/// a normal state rather than an error.
class _OfflineRemote implements PortfolioRemoteDataSource {
  @override
  Future<PortfolioMeta?> fetchMeta() async => null;

  @override
  Future<PortfolioBundle?> fetchBundle() async => null;

  @override
  Future<PortfolioBundle> writeBundle(PortfolioBundle bundle) async =>
      throw UnimplementedError();
}

class _NoBundledContent implements BundledContentLoader {
  @override
  Future<PortfolioBundle?> load() async => null;
}

/// Succeeds once, then fails — the only way to reach the "keep the last good
/// value" branch, since the repository turns most real read problems into a
/// [Success] with fallback content.
class _SwitchableSiteContent implements SiteContentUseCase {
  bool failing = false;

  @override
  Future<DataResult<SiteContent>> get() async => failing
      ? const Fail<SiteContent>('offline')
      : const Success<SiteContent>(SiteContent(fullNameEn: 'Marco Nagy'));

  @override
  Future<DataResult<SiteContent>> save(SiteContent content) async => failing
      ? const Fail<SiteContent>('offline')
      : Success<SiteContent>(content);
}
