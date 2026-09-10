import '../../../../core/styles/app_images.dart';
import '../../domain/entities/site_content.dart';

/// Every outward URL the site can open, resolved from [SiteContent].
///
/// This exists so `UrlOpener` can stay a leaf utility that knows nothing but
/// how to hand a string to the platform. The alternative — letting `UrlOpener`
/// reach into the DI container for a presentation cubit — would make the most
/// widely imported helper in the app depend on the container and on a cubit,
/// inverting the direction every other layer here respects.
class SiteLinks {
  const SiteLinks({
    this.email = '',
    this.phone = '',
    this.gitHubUrl = '',
    this.linkedInUrl = '',
    this.resumeUrl,
  });

  final String email;
  final String phone;
  final String gitHubUrl;
  final String linkedInUrl;

  /// Null when there is nothing openable: a bundled asset has no URL off the
  /// web, so `hostedCvUrl` has to be set for the RESUME button to work there.
  final String? resumeUrl;

  /// [isWeb] is passed in rather than read from `kIsWeb` so this stays a pure
  /// function, testable without a platform — the rule the rest of `view_data`
  /// follows with its `isArabic` flag.
  factory SiteLinks.fromSiteContent(
    SiteContent content, {
    required bool isWeb,
  }) {
    final hosted = content.hostedCvUrl.trim();
    return SiteLinks(
      email: content.email.trim(),
      phone: content.phone.trim(),
      gitHubUrl: content.gitHubUrl.trim(),
      linkedInUrl: content.linkedInUrl.trim(),
      // Flutter web serves bundled assets under an extra `assets/` prefix.
      resumeUrl: hosted.isNotEmpty
          ? hosted
          : (isWeb ? 'assets/${AppImages.cvPdf}' : null),
    );
  }

  /// A `mailto:` with an optional pre-filled subject and body.
  ///
  /// Encoded with [Uri.encodeComponent], not `Uri.encodeQueryComponent` and not
  /// `Uri(queryParameters:)`. Both of those are *form* encoders: they turn a
  /// space into `+`, which is right for an HTTP form post and wrong here — a
  /// mail client does not decode it, so the subject line arrives reading
  /// `Project+enquiry`. The contact form's body carries spaces and newlines in
  /// every message it sends, so this is the normal path, not an edge case.
  String mailto({String? subject, String? body}) {
    final parts = <String, String>{
      if (subject != null && subject.isNotEmpty) 'subject': subject,
      if (body != null && body.isNotEmpty) 'body': body,
    };
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: parts.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}='
                '${Uri.encodeComponent(e.value)}',
          )
          .join('&'),
    );
    return uri.toString();
  }

  /// Whitespace stripped: a dialer rejects `tel:` with spaces in it.
  String get tel => 'tel:${phone.replaceAll(RegExp(r'\s'), '')}';
}
