import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

/// Thrown for every upload failure — a size rejection, a missing
/// configuration, or whatever Cloudinary's API itself reported. [message] is
/// shown to the admin as-is, so it is already the final, readable string.
class CloudinaryUploadException implements Exception {
  const CloudinaryUploadException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Uploads a picked image to Cloudinary and returns a delivery URL.
///
/// Signed, not the unsigned-preset flow the migration plan originally
/// sketched: `api_key`/`api_secret` come in via `--dart-define` rather than
/// living in source, so neither is ever committed. That is also why this
/// stays safe as a plain client-side call with no server of its own — the
/// values only ever exist on the machine running `flutter run`, and (like
/// every other admin affordance) are tree-shaken out of a release build
/// entirely, never reaching a visitor.
///
/// Run with, for example:
/// ```
/// flutter run -d chrome \
///   --dart-define=CLOUDINARY_API_KEY=... \
///   --dart-define=CLOUDINARY_API_SECRET=...
/// ```
@lazySingleton
class CloudinaryUploadService {
  /// Real requests use a fresh [http.Client]; a test hands in a
  /// [http.testing.MockClient] instead, so the signature math and response
  /// handling below can be verified without a live Cloudinary account.
  CloudinaryUploadService([http.Client? client]) : _client = client ?? http.Client();

  final http.Client _client;

  /// Not a secret — it is the account name, and appears in every delivery
  /// URL Cloudinary ever hands back regardless.
  static const String _cloudName = 'wh2ssugy';

  static const String _apiKey = String.fromEnvironment('CLOUDINARY_API_KEY');
  static const String _apiSecret = String.fromEnvironment(
    'CLOUDINARY_API_SECRET',
  );

  /// Every upload lands here, matching the folder the migration plan
  /// recorded when the account's upload settings were first configured.
  static const String _folder = 'portfolio';

  /// Cloudinary's free-plan cap for a single image. Checked before the
  /// request goes out, so a large file is a clear message in the form
  /// instead of an opaque 400 from the API.
  static const int maxImageBytes = 10 * 1024 * 1024;

  bool get isConfigured => _apiKey.isNotEmpty && _apiSecret.isNotEmpty;

  /// Uploads [bytes] and returns a delivery URL with `f_auto,q_auto` already
  /// injected, so every visitor gets the format and quality their browser
  /// handles best without every call site having to remember to add it.
  ///
  /// Throws [CloudinaryUploadException] for anything that stops the upload
  /// from producing a usable URL — never returns a partial or malformed one.
  Future<String> uploadImage(Uint8List bytes, {required String fileName}) =>
      _upload(bytes, fileName: fileName, kind: 'Image', transform: true);

  /// Uploads a document — the CV PDF — and returns its plain `secure_url`.
  ///
  /// Deliberately skips the `f_auto,q_auto` transform [uploadImage] applies:
  /// those are *image* directives, and Cloudinary treats a PDF as an image it
  /// is willing to rasterise, so asking it for an automatic format would hand
  /// back a picture of page one instead of the document.
  ///
  /// Note that a Cloudinary account blocks PDF delivery by default — the
  /// upload succeeds and the URL then 401s until
  /// `Settings → Security → PDF and ZIP files delivery` is enabled.
  Future<String> uploadDocument(Uint8List bytes, {required String fileName}) =>
      _upload(bytes, fileName: fileName, kind: 'File', transform: false);

  Future<String> _upload(
    Uint8List bytes, {
    required String fileName,
    required String kind,
    required bool transform,
  }) async {
    if (!isConfigured) {
      throw const CloudinaryUploadException(
        'Cloudinary is not configured for this run — start it with '
        '--dart-define=CLOUDINARY_API_KEY=... '
        '--dart-define=CLOUDINARY_API_SECRET=...',
      );
    }
    if (bytes.length > maxImageBytes) {
      final mb = (bytes.length / (1024 * 1024)).toStringAsFixed(1);
      throw CloudinaryUploadException(
        '$kind is $mb MB — Cloudinary\'s free plan caps a single upload at '
        '${maxImageBytes ~/ (1024 * 1024)} MB.',
      );
    }

    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
        .toString();
    final signature = sign(<String, String>{
      'folder': _folder,
      'timestamp': timestamp,
    });

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/auto/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['api_key'] = _apiKey
      ..fields['timestamp'] = timestamp
      ..fields['folder'] = _folder
      ..fields['signature'] = signature
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));

    final http.Response response;
    try {
      final streamed = await _client.send(request);
      response = await http.Response.fromStream(streamed);
    } on Object catch (error) {
      throw CloudinaryUploadException('Upload failed: $error');
    }

    if (response.statusCode != 200) {
      throw CloudinaryUploadException(_errorMessage(response));
    }

    final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } on Object {
      throw const CloudinaryUploadException(
        'Cloudinary returned a response that could not be read.',
      );
    }

    final secureUrl = body['secure_url'] as String?;
    if (secureUrl == null || secureUrl.isEmpty) {
      throw const CloudinaryUploadException(
        'Cloudinary\'s response had no secure_url.',
      );
    }
    return transform ? withDeliveryTransform(secureUrl) : secureUrl;
  }

  /// Cloudinary's signature scheme: every param that will actually be sent
  /// (besides `file`, `cloud_name`, `resource_type`, `api_key` and the
  /// signature itself) is sorted by key, joined as `k=v&k=v`, the api secret
  /// appended directly, and the whole thing SHA-1'd.
  ///
  /// Public — annotated [visibleForTesting] rather than left private —
  /// because this is the one piece of this service a unit test can check
  /// against an external, trusted answer: Cloudinary's own published signing
  /// example. A wrong signature fails silently in every other sense (no
  /// compile error, no type error) and shows up only as "Invalid Signature"
  /// on a real upload attempt, which is exactly the class of bug worth
  /// pinning here instead of discovering by hand.
  @visibleForTesting
  String sign(Map<String, String> params, {String? apiSecret}) {
    final secret = apiSecret ?? _apiSecret;
    final sortedKeys = params.keys.toList()..sort();
    final paramString = sortedKeys
        .map((key) => '$key=${params[key]}')
        .join('&');
    final digest = sha1.convert(utf8.encode('$paramString$secret'));
    return digest.toString();
  }

  static String _errorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>?;
      final message = error?['message'] as String?;
      if (message != null && message.isNotEmpty) return message;
    } on Object {
      // Falls through to the generic message below — the body was not the
      // JSON error shape Cloudinary normally sends.
    }
    return 'Cloudinary upload failed (HTTP ${response.statusCode}).';
  }

  /// Injects `f_auto,q_auto` right after `/upload/` in a `secure_url`. Every
  /// Cloudinary delivery URL has exactly one `/upload/` segment, so a plain
  /// substring insert is enough — no URL parsing needed.
  @visibleForTesting
  static String withDeliveryTransform(String secureUrl) {
    const marker = '/upload/';
    final index = secureUrl.indexOf(marker);
    if (index == -1) return secureUrl;
    final insertAt = index + marker.length;
    return '${secureUrl.substring(0, insertAt)}'
        'f_auto,q_auto/'
        '${secureUrl.substring(insertAt)}';
  }
}
