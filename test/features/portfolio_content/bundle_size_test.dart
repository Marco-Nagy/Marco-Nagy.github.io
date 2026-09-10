import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'sample_bundle.dart';

/// Firestore refuses any document over 1 MiB. The bundle is one document, so
/// that ceiling is a hard correctness boundary, not a performance nicety: an
/// oversized bundle cannot be published at all, and the failure arrives at the
/// moment of saving rather than while authoring.
///
/// The usual cause is base64 image bytes reaching the bundle —
/// `ImageSourceKind.embedded` is meant to be a debug-time convenience that is
/// pinned to an asset or uploaded before publishing, and nothing structurally
/// prevents one from surviving into an export.
///
/// This measures the one-item-per-collection fixture from `sample_bundle.dart`,
/// not real production content — real content now lives in Firestore, not in
/// this repo, so there is nothing to measure it against here any more. What
/// this guards is the *shape's* own overhead (field names, nesting, version
/// markers) and the no-embedded-image invariant, both of which a schema change
/// can break regardless of how much real content exists.
void main() {
  /// Firestore's own limit, in bytes.
  const int firestoreDocumentLimit = 1048576;

  /// Leaves room for the version fields and Firestore's own per-field
  /// overhead, which is not counted by a plain UTF-8 length.
  const int budget = 900 * 1024;

  int bytesOf(Object? value) => utf8.encode(json.encode(value)).length;

  String kb(int bytes) => '${(bytes / 1024).toStringAsFixed(1)} KB';

  test('reports where the weight actually is', () {
    final map = sampleBundle().toJson();
    final sizes = <String, int>{
      for (final entry in map.entries) entry.key: bytesOf(entry.value),
    };
    final ordered = sizes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // ignore: avoid_print
    print('--- sample bundle (one item per collection): ${kb(bytesOf(map))} total ---');
    for (final entry in ordered.where((e) => e.value > 16)) {
      // ignore: avoid_print
      print('${entry.key.padRight(18)} ${kb(entry.value)}');
    }
  });

  test('the sample bundle fits well inside a Firestore document', () {
    final bytes = bytesOf(sampleBundle().toJson());
    expect(
      bytes,
      lessThan(budget),
      reason:
          'Serialized bundle is ${kb(bytes)}, over the ${kb(budget)} budget '
          '(Firestore hard limit ${kb(firestoreDocumentLimit)}). If real '
          'production content approaches this, check for base64 images.',
    );
  });

  test('no base64 image bytes reach the bundle', () {
    final encoded = json.encode(sampleBundle().toJson());
    expect(
      encoded.contains('"embedded"'),
      isFalse,
      reason:
          'An ImageRef with kind=embedded carries base64 bytes inline. Pin it '
          'to an asset or upload it to Cloudinary before publishing.',
    );
    expect(
      encoded.contains('data:image'),
      isFalse,
      reason: 'A data: URI is inline image bytes by another name.',
    );
  });
}
