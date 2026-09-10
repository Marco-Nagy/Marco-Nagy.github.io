import 'package:flutter_test/flutter_test.dart';
import 'package:marco_portfolio/core/utils/json_normalize.dart';

import '../../features/portfolio_content/sample_bundle.dart';

/// Reproduces the bug this file exists to fix: publishing to Firestore
/// crashed in the browser with
/// `FirebaseError: [code=invalid-argument]: Function WriteBatch.set() called
/// with invalid data. Unsupported field value: a custom _PersonalProject
/// object`, even though the exact same `bundle.toJson()` value had already
/// passed `json.encode`/`json.decode` in `bundle_round_trip_test.dart`.
///
/// The two disagree because `json.encode` silently calls `.toJson()` on any
/// object it does not recognise as it walks the tree, and Firestore's client
/// SDK does not extend that same courtesy — so a round trip through
/// `dart:convert` alone can never catch this class of bug. This test instead
/// walks the *normalized* structure the way Firestore's own SDK effectively
/// does, asserting every leaf is a value Firestore actually accepts.
void main() {
  /// Firestore's own accepted leaf types, minus the ones this codebase never
  /// produces from a freezed `toJson()` (Timestamp, GeoPoint, DocumentReference,
  /// Blob) — those only ever come from Firestore's own SDK constructing them,
  /// never from application-side JSON.
  void expectFirestoreSafe(Object? value, String path) {
    switch (value) {
      case null:
      case String():
      case num():
      case bool():
        return;
      case Map<String, dynamic>():
        for (final entry in value.entries) {
          expectFirestoreSafe(entry.value, '$path.${entry.key}');
        }
      case List():
        for (var i = 0; i < value.length; i++) {
          expectFirestoreSafe(value[i], '$path[$i]');
        }
      default:
        fail(
          'Unsupported field value at $path: a custom ${value.runtimeType} '
          'object. Firestore would reject this exact way.',
        );
    }
  }

  test(
    'a bundle with nested entities still contains raw objects before '
    'normalizing — proving this test would have caught the bug',
    () {
      // Deliberately asserting the *unfixed* shape, so this test fails loudly
      // if a future freezed/json_serializable upgrade changes the default and
      // silently makes ensurePlainJson's flattening step redundant — in which
      // case the fix becomes unnecessary rather than merely additional.
      final raw = sampleBundle().toJson();
      final projects = raw['projects'] as List;
      final firstProject = projects.first;

      expect(
        firstProject,
        isNot(isA<Map<String, dynamic>>()),
        reason:
            'This assumption (freezed leaves nested entities unconverted) is '
            'exactly what ensurePlainJson exists to fix. If this now fails, '
            'the fix in json_normalize.dart may no longer be necessary — '
            'check before removing it.',
      );
    },
  );

  test('ensurePlainJson makes a full bundle safe for Firestore', () {
    final bundle = sampleBundle(contentVersion: 3);
    final plain = ensurePlainJson(bundle.toJson());

    expectFirestoreSafe(plain, 'bundle');
  });

  test('ensurePlainJson makes the meta document safe for Firestore', () {
    final meta = sampleBundle(contentVersion: 3).meta;
    final plain = ensurePlainJson(meta.toJson());

    expectFirestoreSafe(plain, 'meta');
  });

  test('ensurePlainJson preserves the data, not just its shape', () {
    final bundle = sampleBundle(contentVersion: 5);
    final plain = ensurePlainJson(bundle.toJson());

    expect(plain['contentVersion'], 5);
    expect((plain['projects'] as List).length, bundle.projects.length);
    expect(
      (plain['projects'] as List).first['title'],
      bundle.projects.first.title,
    );
  });
}
