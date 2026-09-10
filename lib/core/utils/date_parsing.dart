/// Parses the free-text "MM/YYYY" convention used by [WorkHistoryEntry] and
/// [CustomSectionItem] date fields. Returns `null` for anything that doesn't
/// match — admin-entered text is never validated at input time, so callers
/// that compute from these dates must degrade silently rather than throw.
DateTime? parseMonthYear(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;

  final match = RegExp(r'^(\d{1,2})\s*/\s*(\d{4})$').firstMatch(trimmed);
  if (match == null) return null;

  final month = int.parse(match.group(1)!);
  final year = int.parse(match.group(2)!);
  if (month < 1 || month > 12) return null;

  return DateTime(year, month);
}
