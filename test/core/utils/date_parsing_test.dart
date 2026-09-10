import 'package:flutter_test/flutter_test.dart';
import 'package:marco_portfolio/core/utils/date_parsing.dart';

/// `parseMonthYear` reads free text an admin typed into a work-history date
/// field, so its whole job is to fail closed: every not-quite-MM/YYYY input
/// must come back null rather than a wrong date the About experience stat
/// would then silently compute from.
void main() {
  test('parses a well-formed MM/YYYY', () {
    expect(parseMonthYear('03/2020'), DateTime(2020, 3));
  });

  test('accepts a single-digit month', () {
    expect(parseMonthYear('3/2020'), DateTime(2020, 3));
  });

  test('tolerates stray spaces around the slash', () {
    expect(parseMonthYear(' 03 / 2020 '), DateTime(2020, 3));
  });

  test('rejects an out-of-range month', () {
    expect(parseMonthYear('13/2020'), isNull);
    expect(parseMonthYear('00/2020'), isNull);
  });

  test('rejects free text, including the current end-date convention', () {
    // The empty string is how a work-history entry spells "present" — this
    // function must not treat that as a date, or "present" would compute a
    // duration ending at year 0.
    expect(parseMonthYear(''), isNull);
    expect(parseMonthYear('Present'), isNull);
    expect(parseMonthYear('2020'), isNull);
    expect(parseMonthYear('2022–2023'), isNull);
    expect(parseMonthYear('March 2020'), isNull);
  });
}
