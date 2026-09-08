/// Turns share-page URLs into something a video player can actually read, and
/// names the hosts where that is not possible at all.
///
/// The rule behind all of it: `video_player` fetches bytes. It follows no
/// viewer page, runs no JavaScript, and — by deliberate choice here — sends no
/// credentials, since the only place this app could keep them is the visitor's
/// browser storage. So every link has to be publicly readable and has to answer
/// with the file itself.
class MediaUrl {
  const MediaUrl._();

  /// Nextcloud and ownCloud hand out `/s/<token>`, which serves an HTML viewer
  /// page — the bytes sit one segment deeper, at `/download`.
  ///
  /// Null when the URL already points at the file, or is not a share link of a
  /// shape we recognise.
  static String? directDownloadFor(String url) {
    final match = _nextcloudShare.firstMatch(url.trim());
    return match == null ? null : '${match.group(1)}/download';
  }

  /// Hosts that cannot stream into the app whatever URL shape is used.
  ///
  /// Google Drive fails twice over: a share link is an HTML page rather than a
  /// file, and the download endpoint sends no `Access-Control-Allow-Origin`, so
  /// the web build is refused before it reads a byte.
  static bool isUnsupportedHost(String url) {
    final host = Uri.tryParse(url.trim())?.host.toLowerCase() ?? '';
    return host == 'drive.google.com' || host == 'docs.google.com';
  }

  /// Matches a bare Nextcloud/ownCloud public share, with or without the
  /// `/index.php` prefix some installs keep, and without a trailing segment of
  /// its own.
  static final RegExp _nextcloudShare = RegExp(
    r'^(https?://[^/\s]+(?:/index\.php)?/s/[A-Za-z0-9_-]+)/?$',
  );
}
