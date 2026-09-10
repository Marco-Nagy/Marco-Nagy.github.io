import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

/// Hands a URL to the platform. Social profiles and the CV open in a new tab;
/// in-app nav never goes through here.
///
/// Deliberately knows nothing about *which* URLs the site has — those come from
/// editable content, and live in `SiteLinks` behind `context.siteLinks`.
class UrlOpener {
  const UrlOpener._();

  static Future<bool> open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    try {
      return await launchUrl(
        uri,
        mode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    } on Exception {
      return false;
    }
  }
}
