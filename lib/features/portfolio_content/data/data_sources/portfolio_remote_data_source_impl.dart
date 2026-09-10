import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/json_normalize.dart';
import '../../domain/entities/portfolio_bundle.dart';
import 'portfolio_remote_data_source.dart';

@LazySingleton(as: PortfolioRemoteDataSource)
class PortfolioRemoteDataSourceImpl implements PortfolioRemoteDataSource {
  PortfolioRemoteDataSourceImpl();

  /// Matches the paths in `firestore.rules`, where `content/{doc}` is public to
  /// read and writable only by the owner uid.
  static const String _collection = 'content';
  static const String _metaDoc = 'meta';
  static const String _bundleDoc = 'bundle';

  /// Resolved on use rather than injected.
  ///
  /// `main` deliberately lets `Firebase.initializeApp` fail without stopping
  /// the app, and `FirebaseFirestore.instance` throws when Firebase never
  /// initialised. Taking it as a constructor argument would move that throw
  /// into DI resolution — outside every guard, crashing the first cubit that
  /// asks for content — which would quietly undo the decision to keep an
  /// unreachable Firebase survivable.
  FirebaseFirestore? get _firestore {
    if (Firebase.apps.isEmpty) return null;
    try {
      return FirebaseFirestore.instance;
    } on Object catch (error) {
      debugPrint('Firestore unavailable, using cache: $error');
      return null;
    }
  }

  DocumentReference<Map<String, dynamic>>? _doc(String id) =>
      _firestore?.collection(_collection).doc(id);

  @override
  Future<PortfolioMeta?> fetchMeta() =>
      _read(_doc(_metaDoc), PortfolioMeta.fromJson, 'meta');

  @override
  Future<PortfolioBundle?> fetchBundle() =>
      _read(_doc(_bundleDoc), PortfolioBundle.fromJson, 'bundle');

  /// Reads one document, mapping every failure mode — offline, permission
  /// denied, missing document, undecodable payload — onto null. The read path
  /// treats all four identically: use the cache.
  ///
  /// The decode is guarded separately on purpose. A document that exists but
  /// cannot be parsed is schema drift, not a network problem, and it is the
  /// case most likely to be introduced by a future change to these entities —
  /// so it gets its own log line rather than being folded into "fetch failed".
  Future<T?> _read<T>(
    DocumentReference<Map<String, dynamic>>? ref,
    T Function(Map<String, dynamic>) fromJson,
    String label,
  ) async {
    if (ref == null) return null;
    Map<String, dynamic>? data;
    try {
      final snapshot = await ref.get();
      if (!snapshot.exists) return null;
      data = snapshot.data();
    } on Object catch (error) {
      debugPrint('Firestore $label fetch failed, using cache: $error');
      return null;
    }
    if (data == null) return null;
    try {
      return fromJson(data);
    } on Object catch (error, stack) {
      debugPrint('Firestore $label could not be decoded — schema drift?');
      debugPrint('$error');
      debugPrintStack(stackTrace: stack);
      assert(false, 'Undecodable $label document in Firestore: $error');
      return null;
    }
  }

  @override
  Future<PortfolioBundle> writeBundle(PortfolioBundle bundle) async {
    // Unlike a read, an unreachable Firestore here is a hard failure: the
    // admin pressed Save and must not be told it worked.
    final firestore = _firestore;
    if (firestore == null) {
      throw StateError(
        'Cannot publish: Firebase is not initialised on this client.',
      );
    }

    // Stamped here rather than by the caller so the invariant "a bumped
    // version always means new content" cannot be broken by a save path that
    // forgets to increment.
    final published = bundle.copyWith(
      contentVersion: bundle.contentVersion + 1,
      schemaVersion: PortfolioBundle.currentSchemaVersion,
      updatedAt: DateTime.now().toUtc().toIso8601String(),
    );

    // ensurePlainJson matters here specifically: freezed's toJson() does not
    // recursively pre-convert nested entities (a project's panels, cover, …),
    // so `published.toJson()` alone still contains raw Dart objects one level
    // down. Firestore's client SDK does not rescue that the way json.encode
    // does elsewhere in this codebase — it throws
    // "Unsupported field value: a custom _X object" instead.
    final bundleJson = ensurePlainJson(published.toJson());
    final metaJson = ensurePlainJson(published.meta.toJson());

    // One batch, so `meta` never advertises a version whose bundle has not
    // landed. Without this a visitor could read the new version number, skip
    // the fetch as "already current", and cache stale content indefinitely.
    final batch = firestore.batch()
      ..set(firestore.collection(_collection).doc(_bundleDoc), bundleJson)
      ..set(firestore.collection(_collection).doc(_metaDoc), metaJson);
    await batch.commit();

    return published;
  }
}
