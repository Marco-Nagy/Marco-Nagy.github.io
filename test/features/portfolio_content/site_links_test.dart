import 'package:flutter_test/flutter_test.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/site_content.dart';
import 'package:marco_portfolio/features/portfolio_content/presentation/view_data/site_links.dart';

/// Phase 3 moved every outward URL out of `UrlOpener` and into this object.
///
/// These are the failure modes that would be *silent*: `UrlOpener.open` returns
/// false for a malformed URL and the UI shows one generic error, so a mangled
/// `mailto:` looks exactly like "the mail app didn't open" rather than pointing
/// at the string that built it.
void main() {
  const content = SiteContent(
    email: 'marconbishay@gmail.com',
    phone: '012 2040 7005',
    gitHubUrl: 'https://github.com/Marco-Nagy',
    linkedInUrl: 'https://linkedin.com/in/marco-nagy',
  );

  SiteLinks linksOf(SiteContent c, {bool isWeb = true}) =>
      SiteLinks.fromSiteContent(c, isWeb: isWeb);

  group('mailto', () {
    test('encodes a space as %20, never as +', () {
      final mailto = linksOf(
        content,
      ).mailto(subject: 'Project enquiry', body: 'Two words');

      // The whole reason the query is built by hand: `Uri(queryParameters:)`
      // uses form encoding, where a space is `+`. A mail client does not
      // decode that — it arrives in the subject line literally as a plus.
      expect(mailto, contains('subject=Project%20enquiry'));
      expect(mailto, contains('body=Two%20words'));
      expect(mailto, isNot(contains('+')));
    });

    test('encodes the newlines the contact form puts in the body', () {
      final mailto = linksOf(content).mailto(body: 'Hello\n\nMarco');

      expect(mailto, contains('body=Hello%0A%0AMarco'));
    });

    test('omits an empty subject and body rather than sending blank ones', () {
      expect(linksOf(content).mailto(), 'mailto:marconbishay@gmail.com');
      expect(
        linksOf(content).mailto(subject: '', body: ''),
        'mailto:marconbishay@gmail.com',
      );
    });

    test('keeps a subject without a body, and a body without a subject', () {
      expect(linksOf(content).mailto(subject: 'Hi'), endsWith('?subject=Hi'));
      expect(linksOf(content).mailto(body: 'Hi'), endsWith('?body=Hi'));
    });
  });

  group('tel', () {
    test('strips the spaces a dialer would reject', () {
      expect(linksOf(content).tel, 'tel:01220407005');
    });

    test('survives content with no phone number at all', () {
      expect(linksOf(const SiteContent()).tel, 'tel:');
    });
  });

  group('resume', () {
    test('a hosted CV wins on every platform', () {
      const hosted = SiteContent(hostedCvUrl: 'https://example.com/cv.pdf');

      expect(linksOf(hosted).resumeUrl, 'https://example.com/cv.pdf');
      expect(
        linksOf(hosted, isWeb: false).resumeUrl,
        'https://example.com/cv.pdf',
      );
    });

    test('falls back to the bundled asset on web, under the assets/ prefix', () {
      // Flutter web serves a bundled asset at `assets/<declared path>`, so the
      // segment appears twice. Dropping one 404s and the button silently fails.
      expect(linksOf(content).resumeUrl, 'assets/assets/cv/marco_nagy_cv.pdf');
    });

    test('is null off the web, because a bundled asset has no URL there', () {
      expect(linksOf(content, isWeb: false).resumeUrl, isNull);
    });

    test('treats a whitespace-only hosted URL as unset', () {
      const blank = SiteContent(hostedCvUrl: '   ');

      expect(linksOf(blank, isWeb: false).resumeUrl, isNull);
    });
  });

  test('trims content typed with stray whitespace in the admin form', () {
    const padded = SiteContent(
      email: '  marco@example.com ',
      gitHubUrl: ' https://github.com/Marco-Nagy  ',
    );
    final links = linksOf(padded);

    expect(links.email, 'marco@example.com');
    expect(links.gitHubUrl, 'https://github.com/Marco-Nagy');
    expect(links.mailto(), 'mailto:marco@example.com');
  });
}
