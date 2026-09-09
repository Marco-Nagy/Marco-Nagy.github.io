import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin singleton wrapper over [SharedPreferences]. Call
/// [instantiatePreferences] once in `main` before `runApp`.
class SharedPrefHelper {
  factory SharedPrefHelper() => _instance;
  SharedPrefHelper._internal();

  static final SharedPrefHelper _instance = SharedPrefHelper._internal();

  static SharedPreferences? _prefs;

  Future<void> instantiatePreferences() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Drops the cached [SharedPreferences] instance so the next
  /// [instantiatePreferences] re-reads it.
  ///
  /// `??=` above means a real app only ever calls [instantiatePreferences]
  /// once, which is correct there — but it also means a test file with
  /// several `setUp`s sharing one process would otherwise have every test
  /// after the first silently keep reading the first test's data, because
  /// `SharedPreferences.setMockInitialValues` replaces the *mock's* store,
  /// not this already-cached instance. Call this from `tearDown` in any test
  /// that touches [SharedPrefHelper].
  @visibleForTesting
  static void resetForTesting() => _prefs = null;

  SharedPreferences get _requirePrefs {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError(
        'SharedPrefHelper used before instantiatePreferences() was awaited.',
      );
    }
    return prefs;
  }

  bool containPreference({required String key}) =>
      _requirePrefs.containsKey(key);

  String? getString({required String key}) => _requirePrefs.getString(key);

  Future<bool> setString({required String key, required String stringValue}) =>
      _requirePrefs.setString(key, stringValue);

  bool getBool({required String key}) => _requirePrefs.getBool(key) ?? false;

  Future<bool> setBool({required String key, required bool value}) =>
      _requirePrefs.setBool(key, value);

  /// Defaults to 0 so a never-written content version compares as older than
  /// anything Firestore reports, forcing the first fetch.
  int getInt({required String key}) => _requirePrefs.getInt(key) ?? 0;

  Future<bool> setInt({required String key, required int value}) =>
      _requirePrefs.setInt(key, value);

  Future<bool> removePreference({required String key}) =>
      _requirePrefs.remove(key);

  /// Used to sweep every per-section custom-items key when a section is
  /// deleted or the whole store is reset.
  Set<String> keysWithPrefix(String prefix) =>
      _requirePrefs.getKeys().where((key) => key.startsWith(prefix)).toSet();
}
