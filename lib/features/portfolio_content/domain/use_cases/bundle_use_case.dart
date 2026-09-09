import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../../core/common/data_result.dart';
import '../entities/portfolio_bundle.dart';
import '../repositories/portfolio_repo.dart';

/// Whole-store operations, as opposed to the per-entity use cases beside it.
///
/// Exists so the admin chrome can reach the bundle through the same
/// domain layer as every other screen, instead of resolving a data source
/// directly from the DI container — the presentation layer never talks to
/// `data/` here.
@injectable
class BundleUseCase {
  const BundleUseCase(this._repo);

  final PortfolioRepo _repo;

  Future<DataResult<PortfolioBundle>> read() => _repo.readBundle();

  /// The bundle as the pretty-printed JSON that `assets/content/` ships and
  /// that seeds Firestore on first publish.
  ///
  /// Indented rather than compact: this text is committed to git, where a
  /// one-line file makes every content change a single unreadable diff. The
  /// size cost is irrelevant — the committed copy is a fallback that loads
  /// once, not the payload visitors fetch.
  Future<DataResult<BundleExport>> exportJson() async {
    final result = await read();
    return switch (result) {
      Fail<PortfolioBundle>(
        message: final message,
        error: final error,
        stackTrace: final stackTrace,
      ) =>
        Fail<BundleExport>(message, error, stackTrace),
      Success<PortfolioBundle>(data: final bundle) => Success<BundleExport>(
        BundleExport._of(bundle),
      ),
    };
  }
}

/// An export plus the two facts that decide whether it can be published.
///
/// Measured at export time rather than discovered at publish time: Firestore
/// rejects an oversized document outright, and finding that out only when the
/// admin presses Save — after authoring — is the worst moment to learn it.
class BundleExport {
  const BundleExport._({
    required this.json,
    required this.bytes,
    required this.embeddedImageCount,
  });

  factory BundleExport._of(PortfolioBundle bundle) {
    final text = const JsonEncoder.withIndent('  ').convert(bundle.toJson());
    return BundleExport._(
      json: text,
      bytes: utf8.encode(text).length,
      embeddedImageCount: _embeddedPattern.allMatches(text).length,
    );
  }

  /// Counted by scanning the encoded text rather than walking the entity tree.
  /// An [ImageRef] can be nested inside a project's shots, a shot background,
  /// a custom item or site content, and hand-walking all of those would need
  /// updating every time an entity gains an image field — silently missing
  /// cases in the meantime. The serialised form is the thing being measured
  /// anyway, so scanning it cannot drift from what actually gets published.
  static final RegExp _embeddedPattern = RegExp(r'"kind"\s*:\s*"embedded"');

  /// Firestore's hard per-document ceiling.
  static const int firestoreDocumentLimit = 1048576;

  /// Leaves headroom for Firestore's own per-field overhead, which a plain
  /// UTF-8 byte count does not include.
  static const int budgetBytes = 900 * 1024;

  final String json;
  final int bytes;

  /// Images still carrying base64 bytes inline. Each one is both dead weight
  /// in every visitor's payload and a step away from the Cloudinary upload
  /// that Phase 6b makes the real path.
  final int embeddedImageCount;

  bool get fitsFirestore => bytes < budgetBytes;

  bool get hasEmbeddedImages => embeddedImageCount > 0;

  String get sizeLabel => '${(bytes / 1024).toStringAsFixed(1)} KB';
}
