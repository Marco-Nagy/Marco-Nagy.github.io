import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:injectable/injectable.dart';

import '../../domain/entities/portfolio_bundle.dart';

/// Reads the committed `assets/content/portfolio_content.json`, produced by the
/// admin's Export action and checked into git.
///
/// This is the cold-start floor: the content a visitor sees when Firestore is
/// unreachable *and* nothing is cached — a first visit during an outage, a
/// quota exhaustion, or a misconfigured rule. Without it those all render an
/// empty page; with it they render slightly stale content, which is the whole
/// point of keeping the file around after the migration.
///
/// It doubles as the project's backup: every export committed to git is a
/// restorable snapshot, which is why scheduled Firestore backups (a Blaze
/// feature) were skipped.
@lazySingleton
class BundledContentLoader {
  const BundledContentLoader();

  static const String assetPath = 'assets/content/portfolio_content.json';

  /// Null when the asset is absent or unreadable — both normal states, not
  /// errors. The file is optional by design: a fresh clone that has never
  /// exported simply has no floor beneath the cache yet.
  Future<PortfolioBundle?> load() async {
    String raw;
    try {
      raw = await rootBundle.loadString(assetPath);
    } on Object {
      // Absent asset is the expected case before the first export, so this
      // is deliberately not logged — it would fire on every cold start.
      return null;
    }
    if (raw.trim().isEmpty) return null;

    try {
      final bundle = PortfolioBundle.fromJson(
        Map<String, dynamic>.from(json.decode(raw) as Map),
      );
      // A committed file from a newer build is worse than no file: it would
      // be written into the cache and then read back through a schema that
      // cannot represent it.
      if (bundle.isFromNewerSchema) {
        debugPrint(
          '$assetPath is schema v${bundle.schemaVersion}, newer than this '
          'build (v${PortfolioBundle.currentSchemaVersion}) — ignoring it.',
        );
        return null;
      }
      return bundle;
    } on Object catch (error, stack) {
      // Unlike an absent file, a malformed one is a real mistake — a bad
      // paste, a truncated export — and it silently removes the last line of
      // defence, so it is loud in debug.
      debugPrint('$assetPath exists but could not be decoded: $error');
      debugPrintStack(stackTrace: stack);
      assert(false, 'Malformed $assetPath: $error');
      return null;
    }
  }
}
