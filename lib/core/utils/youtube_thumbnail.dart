import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Derives the still YouTube already hosts for a video.
///
/// It is a plain image URL, so any `Image.network` draws it — which means an
/// embed ref gets a usable poster without booting a player, on a rotated hover
/// preview as happily as in an admin form.
class YoutubeThumbnail {
  const YoutubeThumbnail._();

  /// Null when [url] carries no resolvable video id — a Vimeo link, or a typo.
  static String? forUrl(String url) {
    final id = YoutubePlayerController.convertUrlToId(url.trim());
    if (id == null) return null;

    // JPEG rather than the package's WebP default: this is handed to
    // Image.network on every platform the app ships to, and JPEG is the format
    // all of them decode without question.
    return ThumbnailFormat.jpeg.buildUrl(id, ThumbnailQuality.high.value);
  }
}
