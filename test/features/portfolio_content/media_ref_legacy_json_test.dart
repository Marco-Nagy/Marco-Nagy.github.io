import 'package:flutter_test/flutter_test.dart';
import 'package:marco_portfolio/core/utils/json_normalize.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/image_ref.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/media_ref.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/media_shot.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/personal_project.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/project_video.dart';

/// Pins `MediaRef.fromJson`'s tolerance for the shape these fields used to
/// have, when `cover` and `MediaShot.image` were bare [ImageRef]s.
///
/// That JSON is not hypothetical: it is sitting in the local storage of every
/// browser that visited before the field grew video support, and it arrives
/// through the cache on the next visit. If the migration regresses, those
/// visitors do not see an error — `fromJson` throws on a `kind` that is not a
/// [MediaKind], the cached bundle fails to parse, and the content is gone.
///
/// The discriminator is the presence of an `image` key, because both shapes
/// carry `kind` and so `kind` cannot tell them apart. The last test here
/// guards that choice from the other side.
void main() {
  group('legacy bare-ImageRef payloads', () {
    test('an asset ref becomes the still of an image MediaRef', () {
      final media = MediaRef.fromJson(<String, dynamic>{
        'kind': 'asset',
        'value': 'assets/projects/flowery_store_1.png',
      });

      expect(media.kind, MediaKind.image);
      expect(media.image.kind, ImageSourceKind.asset);
      expect(media.image.value, 'assets/projects/flowery_store_1.png');
      expect(media.videoUrl, isEmpty);
      expect(media.isVideo, isFalse);
    });

    test('a network ref keeps its kind rather than defaulting to asset', () {
      // An uploaded Cloudinary URL stored before the migration. Losing the
      // `network` kind here would make it resolve as a local asset path.
      final media = MediaRef.fromJson(<String, dynamic>{
        'kind': 'network',
        'value': 'https://res.cloudinary.com/wh2ssugy/image/upload/a.png',
      });

      expect(media.image.kind, ImageSourceKind.network);
      expect(
        media.image.value,
        'https://res.cloudinary.com/wh2ssugy/image/upload/a.png',
      );
    });

    test('an embedded ref survives, and is still recognised as a GIF', () {
      final media = MediaRef.fromJson(<String, dynamic>{
        'kind': 'embedded',
        'value': 'data:image/gif;base64,R0lGODlhAQABAAAAACw=',
      });

      expect(media.image.isEmbedded, isTrue);
      expect(media.isAnimatedImage, isTrue);
    });

    test('an empty map parses to an empty MediaRef instead of throwing', () {
      // A field that was never filled in serialises as ImageRef's defaults,
      // which `toJson` writes out but which a hand-edited document can omit.
      final media = MediaRef.fromJson(<String, dynamic>{});

      expect(media.isEmpty, isTrue);
      expect(media.kind, MediaKind.image);
    });
  });

  group('current payloads are unaffected', () {
    // Re-read through ensurePlainJson, because that is the only shape this
    // factory ever actually meets. freezed leaves a nested entity as a raw
    // object in `toJson()` (`explicitToJson` is off project-wide), so a bare
    // `fromJson(toJson())` fails on a cast that nothing in production
    // performs — local storage flattens via `json.encode`, and the Firestore
    // writer calls this same helper. See `json_normalize.dart`.
    MediaRef reread(MediaRef media) =>
        MediaRef.fromJson(ensurePlainJson(media.toJson()));

    test('a full MediaRef round-trips', () {
      final original = MediaRef.videoFile(
        'https://res.cloudinary.com/wh2ssugy/video/upload/clip.mp4',
        poster: ImageRef.network('https://example.com/poster.png'),
      ).copyWith(muted: false, loop: false, autoplay: false);

      expect(reread(original), original);
    });

    test('a still round-trips', () {
      final original = MediaRef.asset('assets/projects/shot_1.png');

      expect(reread(original), original);
    });

    test('toJson always writes the image key, which is the discriminator', () {
      // The load-bearing invariant. A video with no poster still has to emit
      // `image`, or re-reading it would take the legacy branch and try to
      // decode `kind: "videoFile"` as an ImageSourceKind — so anyone who
      // makes this field conditional (`includeIfNull`, excluding defaults)
      // breaks every video that has no poster. This test fails first.
      final posterless = MediaRef.videoFile('https://example.com/clip.mp4');

      expect(posterless.image.isEmpty, isTrue);
      expect(ensurePlainJson(posterless.toJson()).containsKey('image'), isTrue);
      expect(reread(posterless), posterless);
    });
  });

  group('through the entities that embed it', () {
    test('PersonalProject.cover reads a legacy bare ref', () {
      final project = PersonalProject.fromJson(<String, dynamic>{
        'id': 'flowery_store',
        'title': 'Flowery Store',
        'cover': <String, dynamic>{
          'kind': 'asset',
          'value': 'assets/projects/flowery_store_1.png',
        },
      });

      expect(project.cover.kind, MediaKind.image);
      expect(project.cover.image.value, 'assets/projects/flowery_store_1.png');
    });

    test('MediaShot.image reads a legacy bare ref', () {
      final shot = MediaShot.fromJson(<String, dynamic>{
        'image': <String, dynamic>{
          'kind': 'network',
          'value': 'https://example.com/shot.png',
        },
      });

      expect(shot.image.kind, MediaKind.image);
      expect(shot.image.image.kind, ImageSourceKind.network);
      expect(shot.image.image.value, 'https://example.com/shot.png');
    });

    test('ProjectVideo.media reads a legacy bare ref', () {
      // This one never legitimately held a bare ImageRef, but it shares the
      // factory, so the tolerance has to hold here too rather than throwing.
      final video = ProjectVideo.fromJson(<String, dynamic>{
        'id': 'clip_1',
        'media': <String, dynamic>{
          'kind': 'asset',
          'value': 'assets/projects/clip.png',
        },
      });

      expect(video.media.image.value, 'assets/projects/clip.png');
      expect(video.media.hasPlayableVideo, isFalse);
    });
  });
}
