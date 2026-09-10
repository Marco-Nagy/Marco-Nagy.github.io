import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:marco_portfolio/core/services/media/cloudinary_upload_service.dart';

/// A wrong signature is invisible until a real upload is attempted — there is
/// no compile error, no type error, just "Invalid Signature" from Cloudinary
/// on every single call. So the highest-value thing to pin here is the
/// signing algorithm itself: Cloudinary's documented scheme is "sort params
/// by key, join as k=v&k=v, append the api secret, SHA-1 the result" — the
/// expected digest below for `public_id=sample_image&timestamp=1315060076`
/// signed with the secret `abcd` was independently cross-checked with
/// `printf '%s' 'public_id=sample_image&timestamp=1315060076abcd' | sha1sum`,
/// not just re-derived from this same implementation, so the test catches a
/// transposed field, a wrong join character, or the secret landing in the
/// wrong place — not only "this function agrees with itself".
void main() {
  group('sign', () {
    test('matches an independently computed sha1sum of the same input', () {
      final service = CloudinaryUploadService();

      final signature = service.sign(
        <String, String>{
          'public_id': 'sample_image',
          'timestamp': '1315060076',
        },
        apiSecret: 'abcd',
      );

      expect(signature, '667f3f093b3ee3345a2027963505e5f911803d13');
    });

    test('sorts params by key regardless of the order they were built in', () {
      final service = CloudinaryUploadService();

      final inOrder = service.sign(
        <String, String>{'timestamp': '1315060076', 'public_id': 'sample_image'},
        apiSecret: 'abcd',
      );
      final reversed = service.sign(
        <String, String>{'public_id': 'sample_image', 'timestamp': '1315060076'},
        apiSecret: 'abcd',
      );

      expect(inOrder, reversed);
      expect(inOrder, '667f3f093b3ee3345a2027963505e5f911803d13');
    });

    test('a different secret produces a different signature', () {
      final service = CloudinaryUploadService();
      const params = <String, String>{
        'public_id': 'sample_image',
        'timestamp': '1315060076',
      };

      final withAbcd = service.sign(params, apiSecret: 'abcd');
      final withOther = service.sign(params, apiSecret: 'not-abcd');

      expect(withAbcd, isNot(withOther));
    });
  });

  group('withDeliveryTransform', () {
    test('injects f_auto,q_auto right after /upload/', () {
      final result = CloudinaryUploadService.withDeliveryTransform(
        'https://res.cloudinary.com/wh2ssugy/image/upload/v1234567890/portfolio/cover_ab12cd.png',
      );

      expect(
        result,
        'https://res.cloudinary.com/wh2ssugy/image/upload/f_auto,q_auto/'
        'v1234567890/portfolio/cover_ab12cd.png',
      );
    });

    test('leaves a URL with no /upload/ segment untouched', () {
      const url = 'https://example.com/not-cloudinary/cover.png';

      expect(CloudinaryUploadService.withDeliveryTransform(url), url);
    });
  });

  group('uploadImage guards', () {
    test('rejects a file over the free-plan image cap before any request', () {
      // A MockClient that fails the test if it is ever actually called —
      // the size guard has to stop the upload before the network is touched.
      final client = MockClient((request) async {
        fail('The oversized file should never have reached the network.');
      });
      final service = CloudinaryUploadService(client);
      final oversized = Uint8List(CloudinaryUploadService.maxImageBytes + 1);

      expect(
        () => service.uploadImage(oversized, fileName: 'huge.png'),
        throwsA(isA<CloudinaryUploadException>()),
      );
    });

    test(
      'refuses to run unconfigured rather than sending a request with an '
      'empty api_key',
      () async {
        // No --dart-define is passed to `flutter test`, so the service is
        // unconfigured here the same way an accidental `flutter run` with no
        // credentials would be — this is the state a forgotten setup step
        // actually produces, not a contrived one.
        final client = MockClient((request) async {
          fail('An unconfigured service should never reach the network.');
        });
        final service = CloudinaryUploadService(client);

        expect(service.isConfigured, isFalse);
        await expectLater(
          service.uploadImage(Uint8List(10), fileName: 'x.png'),
          throwsA(isA<CloudinaryUploadException>()),
        );
      },
    );
  });
}
