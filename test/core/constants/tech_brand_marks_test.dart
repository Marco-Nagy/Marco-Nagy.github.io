import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:marco_portfolio/core/constants/tech_brand_marks.dart';

/// The hero orbit's badges became editable content in Phase 3, but their brand
/// logos stayed build assets. This is the seam between the two, and both of its
/// failure modes are invisible at runtime: a badge whose logo cannot be
/// resolved, and a logo path that no longer matches a file, both fall back to a
/// generic glyph rather than throwing. The orbit keeps turning and nobody
/// notices the marks are gone.
void main() {
  group('asset paths', () {
    test('every mark points at a file that actually exists', () {
      final missing = <String>[];
      for (final label in const <String>[
        'Flutter',
        'Dart',
        'Firebase',
        'Android',
        'GitHub',
        '.NET',
        'C#',
        'GraphQL',
        'MySQL',
        'SQL',
        'Figma',
      ]) {
        final mark = TechBrandMarks.resolve(label: label, id: label);
        expect(mark, isNotNull, reason: '$label has no brand mark');
        if (!File(mark!.assetPath).existsSync()) missing.add(mark.assetPath);
      }

      expect(missing, isEmpty);
    });

    test('paths match the file names case-sensitively', () {
      // The release web build serves assets over HTTP, where `github.svg` and
      // `gitHub.svg` are different files — a case slip works on Windows,
      // passes an `existsSync` check on Windows too, and 404s only once the
      // site is deployed. So the name is compared against the real directory
      // listing rather than the filesystem's own lookup.
      final onDisk = Directory('assets/tech')
          .listSync()
          .whereType<File>()
          .map((f) => f.uri.pathSegments.last)
          .toSet();

      for (final label in const <String>['GitHub', 'GraphQL', 'Flutter']) {
        final mark = TechBrandMarks.resolve(label: label, id: label)!;
        final fileName = mark.assetPath.split('/').last;
        expect(
          onDisk,
          contains(fileName),
          reason: '$label resolves to $fileName, which is not in assets/tech',
        );
      }
    });
  });

  group('normalize', () {
    test('ignores case, spacing and punctuation in an admin-typed label', () {
      expect(TechBrandMarks.normalize('GitHub'), 'github');
      expect(TechBrandMarks.normalize('git hub'), 'github');
      expect(TechBrandMarks.normalize('Git-Hub'), 'github');
      expect(TechBrandMarks.normalize('.NET'), 'net');
      expect(TechBrandMarks.normalize('C#'), 'c');
    });
  });

  group('resolve', () {
    test('finds the logo however the label is spelled', () {
      final canonical = TechBrandMarks.resolve(label: 'GitHub', id: 'x')!;

      for (final spelling in const <String>['github', 'Git Hub', 'GITHUB']) {
        expect(
          TechBrandMarks.resolve(label: spelling, id: 'x')?.assetPath,
          canonical.assetPath,
        );
      }
    });

    test('falls back to the id when the label has been reworded', () {
      // Renaming a badge in the admin must not cost it its logo — the id is
      // stable and the label is the part Marco is free to change.
      final mark = TechBrandMarks.resolve(
        label: 'Cross-platform UI',
        id: 'flutter',
      );

      expect(mark, isNotNull);
      expect(mark!.assetPath, contains('flutter.svg'));
    });

    test('returns null for a badge with no logo, so the glyph takes over', () {
      // `bloc`, `rest`, `maps` and `cicd` are all in the published bundle and
      // have no SVG. Null here is the contract that keeps them rendering.
      for (final id in const <String>['bloc', 'rest', 'maps', 'cicd']) {
        expect(
          TechBrandMarks.resolve(label: id, id: id),
          isNull,
          reason: '$id unexpectedly resolved to a logo',
        );
      }
    });
  });
}
