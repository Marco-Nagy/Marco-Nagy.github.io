import 'package:flutter_test/flutter_test.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/image_ref.dart';

/// `fromSource` decides what a stored string *means*, and every media field
/// now depends on it: the certificate scan, the media field's typed box, and
/// anything else holding a source that used to be an `assets/...` path and is
/// now usually a Cloudinary URL. Getting it wrong does not throw — it renders
/// a broken image, which is the kind of failure that reaches the live site
/// before anyone notices.
void main() {
  test('an http(s) source is a network image', () {
    expect(
      ImageRef.fromSource('https://res.cloudinary.com/x/image/upload/a.png').kind,
      ImageSourceKind.network,
    );
    expect(
      ImageRef.fromSource('http://example.com/a.png').kind,
      ImageSourceKind.network,
    );
  });

  test('a bundled path is an asset', () {
    final ref = ImageRef.fromSource('assets/images/profile.png');

    expect(ref.kind, ImageSourceKind.asset);
    expect(ref.value, 'assets/images/profile.png');
  });

  test('trims surrounding whitespace before deciding', () {
    // A pasted URL very often arrives with a trailing newline or space, and
    // an untrimmed value would both miss the `http` test and produce a URL
    // that 404s.
    final ref = ImageRef.fromSource('  https://example.com/a.png\n');

    expect(ref.kind, ImageSourceKind.network);
    expect(ref.value, 'https://example.com/a.png');
  });

  test('an empty or whitespace-only source is empty, not a broken asset', () {
    expect(ImageRef.fromSource('').isEmpty, isTrue);
    expect(ImageRef.fromSource('   ').isEmpty, isTrue);
  });
}
