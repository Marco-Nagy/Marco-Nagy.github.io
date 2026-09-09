import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/certificate.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/custom_section_item.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/personal_project.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/portfolio_bundle.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/pricing_add_on.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/pricing_package.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/section_definition.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/site_content.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/skill_group_entity.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/tech_badge_entity.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/work_history_entry.dart';

import 'sample_bundle.dart';

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
/// Fixtures come from `sample_bundle.dart` with every field, including nested
/// ones (a project's panels/shots/links), set away from its default — a
/// default-valued fixture would pass even if a field never serialised, because
/// the decoded default and the missing-key default look identical.
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

  group('entity round trip', () {
    roundTrips<PersonalProject>(
      'project (nested panels, shots, videos, links)',
      sampleProject(),
      (p) => p.toJson(),
      PersonalProject.fromJson,
    );

    roundTrips<Certificate>(
      'certificate',
      sampleCertificate(),
      (c) => c.toJson(),
      Certificate.fromJson,
    );

    roundTrips<WorkHistoryEntry>(
      'work history entry',
      sampleWorkHistoryEntry(),
      (e) => e.toJson(),
      WorkHistoryEntry.fromJson,
    );

    roundTrips<PricingPackage>(
      'pricing package',
      samplePricingPackage(),
      (p) => p.toJson(),
      PricingPackage.fromJson,
    );

    roundTrips<PricingAddOn>(
      'pricing add-on',
      samplePricingAddOn(),
      (a) => a.toJson(),
      PricingAddOn.fromJson,
    );

    roundTrips<SkillGroupEntity>(
      'skill group',
      sampleSkillGroup(),
      (g) => g.toJson(),
      SkillGroupEntity.fromJson,
    );

    roundTrips<TechBadgeEntity>(
      'tech badge',
      sampleTechBadge(),
      (b) => b.toJson(),
      TechBadgeEntity.fromJson,
    );

    roundTrips<SectionDefinition>(
      'section definition',
      sampleSection(),
      (s) => s.toJson(),
      SectionDefinition.fromJson,
    );

    roundTrips<SiteContent>(
      'site content (43 fields)',
      sampleSiteContent(),
      (s) => s.toJson(),
      SiteContent.fromJson,
    );

    roundTrips<CustomSectionItem>(
      'custom section item',
      sampleCustomSectionItem(),
      (i) => i.toJson(),
      CustomSectionItem.fromJson,
    );
  });

  group('bundle round trip', () {
    test('survives encode/decode intact', () {
      final original = sampleBundle(contentVersion: 7);
      final decoded = PortfolioBundle.fromJson(
        json.decode(json.encode(original.toJson())) as Map<String, dynamic>,
      );
      expect(decoded, equals(original));
    });

    test('carries the version markers the read path branches on', () {
      final decoded = PortfolioBundle.fromJson(
        json.decode(
              json.encode(sampleBundle(contentVersion: 7).toJson()),
            )
            as Map<String, dynamic>,
      );
      expect(decoded.contentVersion, 7);
      expect(decoded.schemaVersion, PortfolioBundle.currentSchemaVersion);
    });

    test('keeps the nested custom-items map keyed by section', () {
      final decoded = PortfolioBundle.fromJson(
        json.decode(json.encode(sampleBundle().toJson()))
            as Map<String, dynamic>,
      );
      expect(decoded.customItems.keys, <String>['section-1']);
      expect(decoded.customItems['section-1']!.single.titleEn, 'Title');
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
