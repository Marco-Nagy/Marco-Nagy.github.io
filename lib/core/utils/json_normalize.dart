import 'dart:convert';

/// Flattens a `toJson()` map into one Firestore's client SDK can actually
/// write.
///
/// Firestore's `WriteBatch.set()` requires every nested value to already be a
/// plain `Map`, `List`, `String`, `num`, `bool` or `null` — unlike
/// `dart:convert`'s `json.encode`, it does **not** fall back to calling a
/// nested object's own `toJson()` for you, and throws
/// `Unsupported field value: a custom _X object` on anything it does not
/// recognise.
///
/// freezed's generated `toJson()` does not recursively pre-convert nested
/// entities by default (`explicitToJson` is off project-wide), so, for
/// instance, `PortfolioBundle.toJson()`'s `projects` field is a list of maps
/// whose own nested fields (a project's `panels`, `cover`, `links`, …) are
/// still raw objects one level down. Every other place in this codebase that
/// looks like it "just works" with that shape — local storage, this app's own
/// round-trip tests — only works because it hands the result to
/// `json.encode`, and `json.encode` is what silently performs the missing
/// `toJson()` calls as it walks the tree. Firestore's SDK is the first
/// consumer in this codebase that does not extend that same courtesy.
///
/// Round-tripping through `json.encode`/`json.decode` performs exactly that
/// flattening on purpose: the result can only ever contain JSON-primitive
/// values, `Map`s and `List`s, because that is all `json.decode` is capable
/// of producing.
Map<String, dynamic> ensurePlainJson(Map<String, dynamic> value) =>
    json.decode(json.encode(value)) as Map<String, dynamic>;
