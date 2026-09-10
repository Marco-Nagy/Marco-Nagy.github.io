import 'package:flutter_test/flutter_test.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/image_ref.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/site_content.dart';

/// `aboutPhoto` is the one derived field on [SiteContent] — everything else
/// on the entity is read as-is. Its whole job is the fallback rule from the
/// admin form's photo pickers: About gets its own square crop when one has
/// been set, and silently reuses the hero's photo when it has not, so a site
/// that only ever fills in the Hero photo never shows a blank About portrait.
void main() {
  test('falls back to the hero photo when no About photo has been set', () {
    final content = SiteContent(
      profileImage: ImageRef.asset('assets/images/profile.png'),
    );

    expect(content.aboutPhoto, content.profileImage);
  });

  test('prefers its own photo once one has been set', () {
    final content = SiteContent(
      profileImage: ImageRef.asset('assets/images/profile.png'),
      aboutPhotoImage: ImageRef.asset('assets/images/about.png'),
    );

    expect(content.aboutPhoto.value, 'assets/images/about.png');
  });

  test('is empty when neither photo has ever been set', () {
    const content = SiteContent();

    expect(content.aboutPhoto.isEmpty, isTrue);
  });
}
