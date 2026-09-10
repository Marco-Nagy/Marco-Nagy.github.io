import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:marco_portfolio/core/constants/tech_brand_marks.dart';

/// The hero orbit's badge list is build configuration, so its one failure mode
/// is a path that no longer matches a file — and that failure is invisible at
/// runtime. `SafeAssetImage` degrades a missing SVG to a tinted glyph rather
/// than throwing, so the orbit keeps turning and nobody notices the logo is
/// gone until someone looks closely at the deployed site.
void main() {
  test('every mark points at a file that exists, matching case exactly', () {
    // Compared against the real directory listing rather than
    // `File.existsSync`, because the case slip that matters — `github.svg` vs
    // `gitHub.svg` — passes an existence check on Windows and 404s only once
    // the site is served over HTTP.
    final onDisk = Directory(
      'assets/tech',
    ).listSync().whereType<File>().map((f) => f.uri.pathSegments.last).toSet();

    for (final mark in TechBrandMarks.all) {
      expect(
        onDisk,
        contains(mark.assetPath.split('/').last),
        reason: '${mark.label} points at ${mark.assetPath}, which is not there',
      );
    }
  });

  test('every SVG in assets/tech is actually orbiting', () {
    // The other direction: a logo added to the folder but never listed here is
    // shipped weight that nothing draws.
    final listed = TechBrandMarks.all
        .map((m) => m.assetPath.split('/').last)
        .toSet();
    final onDisk = Directory('assets/tech')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .where((name) => name.endsWith('.svg'))
        .toSet();

    expect(onDisk.difference(listed), isEmpty);
  });

  test('paths sit under the declared assets/tech directory', () {
    // `pubspec.yaml` declares `assets/tech/`; a mark pointing anywhere else
    // resolves at debug and is simply absent from the release bundle.
    for (final mark in TechBrandMarks.all) {
      expect(mark.assetPath, startsWith('assets/tech/'));
    }
  });

  test('no duplicate labels or paths in the orbit', () {
    final labels = TechBrandMarks.all.map((m) => m.label).toList();
    final paths = TechBrandMarks.all.map((m) => m.assetPath).toList();

    expect(labels.toSet(), hasLength(labels.length));
    expect(paths.toSet(), hasLength(paths.length));
  });
}
