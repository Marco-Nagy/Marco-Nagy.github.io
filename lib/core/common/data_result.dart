/// Result wrapper used by the content repositories.
///
/// Covers both failure surfaces: local storage (corrupt JSON, schema drift) and
/// now Firestore. Note that an *unreachable* Firestore is not a [Fail] — the
/// read path falls back to cache and still yields [Success], because a visitor
/// offline is a state this app is designed to render, not an error to report.
sealed class DataResult<T> {
  const DataResult();
}

class Success<T> extends DataResult<T> {
  const Success(this.data);
  final T data;
}

class Fail<T> extends DataResult<T> {
  const Fail(this.message, [this.error, this.stackTrace]);
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
}
