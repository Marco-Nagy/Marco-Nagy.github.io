// Plain Dart — no Flutter dependency, so it can run in CI before a build
// starts rather than after one succeeds. Run from the repo root:
//
//   dart run tool/validate_assets.dart
//
// Exits 1 on any failure, printing every problem found rather than stopping
// at the first one — a single run is meant to be the whole punch list.
//
// Checks, per docs/firebase-migration-plan.md Phase 6d:
//   1. A path referenced from Dart source, pubspec.yaml or the committed
//      content bundle that does not exist on disk.
//   2. A referenced path that exists, but outside every directory
//      pubspec.yaml actually declares under `flutter: assets:`.
//   3. A file sitting in a declared assets directory that nothing
//      references — dead weight shipped for no reason.
//   4. A filename with characters outside `[a-z0-9._-]` — spaces,
//      capitals, parentheses and non-ASCII all break somewhere between a
//      case-sensitive web server and a URL that cannot be typed back.
//   5. Any `"kind": "embedded"` in the committed bundle — base64 must
//      never reach Firestore, where it would blow the 1 MiB document
//      limit long before it got that far.
import 'dart:convert';
import 'dart:io';

/// Files that exist for humans reading the repo, not for the app to load —
/// excluded from every check below rather than tripping the filename or
/// orphan rules on every single asset directory.
bool _isDocFile(String basename) => basename.toLowerCase() == 'readme.md';

// `AppLocalizations` loads `'translations/${locale.languageCode}.json'` —
// the directory is a literal but the filename is interpolated, the opposite
// shape from an asset path built as `'$_dir/name.ext'`, so neither of the
// two literal-matching regexes below can see it. Small and fixed enough
// (one file per supported language) that a targeted allowance is more
// honest than stretching a regex to cover a shape this different.
bool _isKnownTranslationFile(String path) =>
    RegExp(r'^translations/[a-z]{2}\.json$').hasMatch(path);

final RegExp _validFilename = RegExp(r'^[a-z0-9._-]+$');

// Requires a real-looking extension at the end, so a directory declaration
// (`assets/tech/`) or a doc-comment example (`assets/$folder/`, `assets/...`)
// does not read as a file reference — both are common in this codebase's
// comments and neither names an actual required asset.
final RegExp _assetPathLiteral = RegExp(
  r'''assets/[a-zA-Z0-9._/-]+\.[a-zA-Z0-9]{2,4}(?=['"])''',
);

// Catches a path built through interpolation, e.g. `'$_dir/flutter.svg'` in
// TechBrandMarks — the literal `assets/tech/flutter.svg` never appears as a
// contiguous substring anywhere in source, only its filename tail does.
// Matched separately and checked by basename against every declared
// directory, since which directory the variable prefix resolves to is not
// something a regex can follow.
final RegExp _interpolatedTail = RegExp(
  r'''\$[a-zA-Z_][a-zA-Z0-9_]*/([a-zA-Z0-9._-]+\.[a-zA-Z0-9]{2,4})(?=['"])''',
);

void main() {
  final repoRoot = Directory.current;
  final problems = <String>[];

  final pubspecFile = File('${repoRoot.path}/pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    stderr.writeln(
      'pubspec.yaml not found — run this from the repo root: '
      'dart run tool/validate_assets.dart',
    );
    exit(1);
  }
  final pubspecText = pubspecFile.readAsStringSync();

  final declaredDirs = _declaredAssetDirs(pubspecText);
  if (declaredDirs.isEmpty) {
    stderr.writeln('No "flutter: assets:" entries found in pubspec.yaml.');
    exit(1);
  }

  // --- What actually exists on disk under a declared directory. ---------
  final filesOnDisk = <String>{};
  for (final dir in declaredDirs) {
    final directory = Directory('${repoRoot.path}/$dir');
    if (!directory.existsSync()) {
      problems.add('Declared in pubspec.yaml but missing on disk: $dir');
      continue;
    }
    for (final entity in directory.listSync(recursive: true)) {
      if (entity is! File) continue;
      final relative = entity.path
          .substring(repoRoot.path.length + 1)
          .replaceAll(r'\', '/');
      filesOnDisk.add(relative);
    }
  }

  // --- Filenames outside the safe character set. -------------------------
  for (final path in filesOnDisk) {
    final basename = path.split('/').last;
    if (_isDocFile(basename)) continue;
    if (!_validFilename.hasMatch(basename)) {
      problems.add('Filename outside [a-z0-9._-]: $path');
    }
  }

  // --- Every `assets/...` string literal this repo actually references. -
  final referenced = <String>{};
  // Filenames only reachable by matching an interpolated path's tail — a
  // file counts as referenced if its basename is in here, regardless of
  // which declared directory it actually lives in.
  final referencedBasenames = <String>{};

  void scanForReferences(String text) {
    referenced.addAll(_assetPathLiteral.allMatches(text).map((m) => m[0]!));
    referencedBasenames.addAll(
      _interpolatedTail.allMatches(text).map((m) => m[1]!),
    );
  }

  scanForReferences(pubspecText);

  final libDir = Directory('${repoRoot.path}/lib');
  if (libDir.existsSync()) {
    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      scanForReferences(entity.readAsStringSync());
    }
  }

  final bundleFile = File('${repoRoot.path}/assets/content/portfolio_content.json');
  Object? bundle;
  if (bundleFile.existsSync()) {
    try {
      bundle = jsonDecode(bundleFile.readAsStringSync());
    } on FormatException catch (error) {
      problems.add('assets/content/portfolio_content.json is not valid JSON: $error');
    }
  } else {
    problems.add('Missing the D3 cold-start floor: assets/content/portfolio_content.json');
  }

  final embeddedFound = <String>[];
  if (bundle != null) {
    _walkJson(bundle, path: r'$', onString: (value, path) {
      if (_assetPathLiteral.hasMatch(value)) {
        for (final match in _assetPathLiteral.allMatches(value)) {
          referenced.add(match[0]!);
        }
      }
    }, onEmbedded: (path) => embeddedFound.add(path));
  }

  // --- Referenced but missing, or outside every declared directory. ------
  for (final path in referenced) {
    final exists = filesOnDisk.contains(path) || File('${repoRoot.path}/$path').existsSync();
    if (!exists) {
      problems.add('Referenced but missing on disk: $path');
      continue;
    }
    final inDeclaredDir = declaredDirs.any(
      (dir) => path == dir || path.startsWith(dir.endsWith('/') ? dir : '$dir/'),
    );
    if (!inDeclaredDir) {
      problems.add('Referenced path exists but is outside every declared assets directory: $path');
    }
  }

  // --- Orphans: on disk, in a declared directory, never referenced. ------
  for (final path in filesOnDisk) {
    final basename = path.split('/').last;
    if (_isDocFile(basename) || _isKnownTranslationFile(path)) continue;
    if (!referenced.contains(path) && !referencedBasenames.contains(basename)) {
      problems.add('Orphaned — nothing references it: $path');
    }
  }

  // --- Embedded base64 in the committed bundle. ---------------------------
  for (final path in embeddedFound) {
    problems.add('ImageSourceKind.embedded in the committed bundle at $path — base64 must never reach Firestore');
  }

  if (problems.isEmpty) {
    stdout.writeln('validate_assets: no problems found across ${declaredDirs.length} declared directories, ${filesOnDisk.length} files.');
    exit(0);
  }

  stderr.writeln('validate_assets found ${problems.length} problem(s):\n');
  for (final problem in problems) {
    stderr.writeln('  - $problem');
  }
  exit(1);
}

/// Directories under `flutter: assets:` in pubspec.yaml, without a full YAML
/// parser: the block is a plain `- path/` list with two-space indentation,
/// which a line-oriented scan reads reliably without adding a dependency to
/// a script that has to run standalone in CI.
List<String> _declaredAssetDirs(String pubspecText) {
  final lines = pubspecText.split('\n');
  final dirs = <String>[];
  var inAssetsBlock = false;

  for (final line in lines) {
    if (RegExp(r'^\s{2}assets:\s*$').hasMatch(line)) {
      inAssetsBlock = true;
      continue;
    }
    if (inAssetsBlock) {
      final match = RegExp(r'^\s{4}-\s*(\S+)').firstMatch(line);
      if (match != null) {
        var dir = match[1]!;
        if (dir.endsWith('/')) dir = dir.substring(0, dir.length - 1);
        dirs.add(dir);
        continue;
      }
      // Any other line at this indentation (or shallower) ends the block.
      if (!line.startsWith('    ')) inAssetsBlock = false;
    }
  }
  return dirs;
}

/// Walks a decoded JSON tree, calling [onString] for every string value and
/// [onEmbedded] for every map whose `kind` is `embedded` — matching how
/// [ImageRef] and [MediaRef] serialise their `ImageSourceKind`.
void _walkJson(
  Object? node, {
  required String path,
  required void Function(String value, String path) onString,
  required void Function(String path) onEmbedded,
}) {
  switch (node) {
    case Map<String, dynamic>():
      if (node['kind'] == 'embedded') onEmbedded(path);
      for (final entry in node.entries) {
        _walkJson(entry.value, path: '$path.${entry.key}', onString: onString, onEmbedded: onEmbedded);
      }
    case List():
      for (var i = 0; i < node.length; i++) {
        _walkJson(node[i], path: '$path[$i]', onString: onString, onEmbedded: onEmbedded);
      }
    case String():
      onString(node, path);
    default:
      break;
  }
}
