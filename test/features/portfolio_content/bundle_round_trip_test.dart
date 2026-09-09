import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:marco_portfolio/features/portfolio_content/data/seed/seed_certificates.dart';
import 'package:marco_portfolio/features/portfolio_content/data/seed/seed_pricing.dart';
import 'package:marco_portfolio/features/portfolio_content/data/seed/seed_projects.dart';
import 'package:marco_portfolio/features/portfolio_content/data/seed/seed_sections.dart';
import 'package:marco_portfolio/features/portfolio_content/data/seed/seed_site_content.dart';
import 'package:marco_portfolio/features/portfolio_content/data/seed/seed_skills.dart';
import 'package:marco_portfolio/features/portfolio_content/data/seed/seed_work_history.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/certificate.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/custom_section_item.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/image_ref.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/personal_project.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/portfolio_bundle.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/pricing_add_on.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/pricing_package.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/section_definition.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/site_content.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/skill_group_entity.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/tech_badge_entity.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/work_history_entry.dart';

/// Serialisation is the one thing in this migration that can destroy content
/// silently. A field that does not survive `toJson`/`fromJson` does not throw —
/// it comes back as its default, so a save writes the emptied value over the
/// real one and the loss only shows up as a blank section much later.
///
/// Every case here round-trips through a real JSON **string**, not just the
/// intermediate map. Encoding is what catches a type Firestore cannot hold —
/// a `DateTime`, a `Color`, a raw enum — which a map-only comparison passes
/// straight over. freezed's structural `==` then makes the assertion free.
///
/// This lands with Phase 0 deliberately: Phase 1 deletes `data/seed/`, and
/// these seeds are the only realistic content the round trip can be proven
/// against before they go.
void main() {
  /// Encode → decode → compare, the way Firestore will actually treat it.
  void roundTrips<T>(
    String label,
    T value,
    Map<String, dynamic> Function(T) toJson,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    test(label, () {
      final decoded = fromJson(
        json.decode(json.encode(toJson(value))) as Map<String, dynamic>,
      );
      expect(decoded, equals(value));
    });
  }

  /// Runs [roundTrips] over a whole seeded collection, so every real record is
  /// covered rather than one hand-picked representative.
  void eachRoundTrips<T>(
    String label,
    List<T> values,
    Map<String, dynamic> Function(T) toJson,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    test(label, () {
      expect(values, isNotEmpty, reason: 'seed is empty, so this proves nothing');
      for (var i = 0; i < values.length; i++) {
        final decoded = fromJson(
          json.decode(json.encode(toJson(values[i]))) as Map<String, dynamic>,
        );
        expect(decoded, equals(values[i]), reason: '$label[$i]');
      }
    });
  }

  group('entity round trip', () {
    eachRoundTrips<PersonalProject>(
      'projects',
      SeedProjects.all,
      (p) => p.toJson(),
      PersonalProject.fromJson,
    );

    eachRoundTrips<Certificate>(
      'certificates',
      SeedCertificates.all,
      (c) => c.toJson(),
      Certificate.fromJson,
    );

    eachRoundTrips<WorkHistoryEntry>(
      'work history',
      SeedWorkHistory.all,
      (e) => e.toJson(),
      WorkHistoryEntry.fromJson,
    );

    eachRoundTrips<PricingPackage>(
      'pricing packages',
      SeedPricing.packages,
      (p) => p.toJson(),
      PricingPackage.fromJson,
    );

    eachRoundTrips<PricingAddOn>(
      'pricing add-ons',
      SeedPricing.addOns,
      (a) => a.toJson(),
      PricingAddOn.fromJson,
    );

    eachRoundTrips<SkillGroupEntity>(
      'skill groups',
      SeedSkills.groups,
      (g) => g.toJson(),
      SkillGroupEntity.fromJson,
    );

    eachRoundTrips<TechBadgeEntity>(
      'tech badges',
      SeedSkills.techBadges,
      (b) => b.toJson(),
      TechBadgeEntity.fromJson,
    );

    eachRoundTrips<SectionDefinition>(
      'sections',
      SeedSections.all,
      (s) => s.toJson(),
      SectionDefinition.fromJson,
    );

    roundTrips<SiteContent>(
      'site content (43 fields)',
      SeedSiteContent.value,
      (s) => s.toJson(),
      SiteContent.fromJson,
    );

    // No seed exists for custom sections — they are created in debug — so this
    // one is built by hand, with every field set away from its default. A
    // default-valued fixture would pass even if the field never serialised.
    roundTrips<CustomSectionItem>(
      'custom section item',
      const CustomSectionItem(
        id: 'item-1',
        sectionId: 'section-1',
        titleEn: 'Title',
        titleAr: 'عنوان',
        subtitleEn: 'Subtitle',
        subtitleAr: 'عنوان فرعي',
        descriptionEn: 'Description',
        descriptionAr: 'وصف',
        bulletsEn: <String>['one', 'two'],
        bulletsAr: <String>['واحد', 'اثنان'],
        tagEn: 'Tag',
        tagAr: 'وسم',
        dateStart: '2024-01',
        dateEnd: '2025-06',
        year: '2025',
        images: <ImageRef>[ImageRef()],
        accentHex: 'FF00AA',
        linkUrl: 'https://example.com',
        order: 3,
      ),
      (i) => i.toJson(),
      CustomSectionItem.fromJson,
    );
  });

  group('bundle round trip', () {
    /// The whole store, exactly as Phase 1 will export it to bootstrap
    /// Firestore. If this passes, that upload cannot lose a field.
    PortfolioBundle seeded() => PortfolioBundle(
      projects: SeedProjects.all,
      certificates: SeedCertificates.all,
      workHistory: SeedWorkHistory.all,
      pricingPackages: SeedPricing.packages,
      pricingAddOns: SeedPricing.addOns,
      siteContent: SeedSiteContent.value,
      skillGroups: SeedSkills.groups,
      techBadges: SeedSkills.techBadges,
      sections: SeedSections.all,
      customItems: const <String, List<CustomSectionItem>>{
        'section-1': <CustomSectionItem>[
          CustomSectionItem(id: 'i1', sectionId: 'section-1', titleEn: 'One'),
        ],
      },
      contentVersion: 7,
      updatedAt: '2026-09-09T18:37:40.000Z',
    );

    test('survives encode/decode intact', () {
      final original = seeded();
      final decoded = PortfolioBundle.fromJson(
        json.decode(json.encode(original.toJson())) as Map<String, dynamic>,
      );
      expect(decoded, equals(original));
    });

    test('carries the version markers the read path branches on', () {
      final decoded = PortfolioBundle.fromJson(
        json.decode(json.encode(seeded().toJson())) as Map<String, dynamic>,
      );
      expect(decoded.contentVersion, 7);
      expect(decoded.schemaVersion, PortfolioBundle.currentSchemaVersion);
      expect(decoded.updatedAt, '2026-09-09T18:37:40.000Z');
    });

    test('keeps the nested custom-items map keyed by section', () {
      final decoded = PortfolioBundle.fromJson(
        json.decode(json.encode(seeded().toJson())) as Map<String, dynamic>,
      );
      expect(decoded.customItems.keys, <String>['section-1']);
      expect(decoded.customItems['section-1']!.single.titleEn, 'One');
    });

    test('an empty bundle is still valid JSON in both directions', () {
      const empty = PortfolioBundle();
      final decoded = PortfolioBundle.fromJson(
        json.decode(json.encode(empty.toJson())) as Map<String, dynamic>,
      );
      expect(decoded, equals(empty));
      expect(decoded.isEmpty, isTrue);
    });

    test('reports a bundle written by a newer schema', () {
      const future = PortfolioBundle(
        schemaVersion: PortfolioBundle.currentSchemaVersion + 1,
      );
      expect(future.isFromNewerSchema, isTrue);
      expect(const PortfolioBundle().isFromNewerSchema, isFalse);
    });
  });
}
