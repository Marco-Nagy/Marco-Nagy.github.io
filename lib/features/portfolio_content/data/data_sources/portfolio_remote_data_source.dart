import '../../domain/entities/portfolio_bundle.dart';

/// Firestore side of the content store.
///
/// Deliberately two documents, not nine collections: `content/meta` is tiny and
/// read on every visit, `content/bundle` is the whole payload and read only
/// when [PortfolioMeta.contentVersion] says the cache is stale. That split is
/// what keeps a returning visitor at a single Firestore read.
///
/// **Reads return null instead of throwing.** A visitor with no network, a
/// blocked region, or a project that has not been seeded yet is a normal state
/// this app is designed to survive — the repository falls back to cache, then
/// to the committed JSON. Only [writeBundle] throws, because a failed admin
/// save must be visible rather than silently dropped.
abstract class PortfolioRemoteDataSource {
  /// One Firestore read. Null when unreachable or not yet published.
  Future<PortfolioMeta?> fetchMeta();

  /// One Firestore read of the full bundle. Null when unreachable or absent.
  Future<PortfolioBundle?> fetchBundle();

  /// Publishes [bundle] and its meta document in one batch, so a reader can
  /// never see a bumped version pointing at content that has not landed yet.
  ///
  /// Increments [PortfolioBundle.contentVersion] and stamps
  /// [PortfolioBundle.updatedAt] itself, and returns exactly what was written
  /// so the caller can refresh its cache without reading back. Throws when the
  /// write is rejected — an unauthenticated client hits the security rules
  /// here, which is the intended and only real boundary.
  Future<PortfolioBundle> writeBundle(PortfolioBundle bundle);
}
