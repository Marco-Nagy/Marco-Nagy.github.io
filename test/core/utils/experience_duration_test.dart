import 'package:flutter_test/flutter_test.dart';
import 'package:marco_portfolio/core/utils/experience_duration.dart';

/// Two things can silently go wrong here: the month arithmetic (borrowing
/// across a year boundary, or going negative when a typo puts the end date
/// before the start), and the Arabic noun agreement, where a flat plural
/// reads as a mistake to a native speaker for 1, 2, and 11+.
void main() {
  group('between', () {
    test('whole years with no leftover months', () {
      final duration = ExperienceDuration.between(
        DateTime(2020, 3),
        DateTime(2023, 3),
      );

      expect(duration.years, 3);
      expect(duration.months, 0);
    });

    test('borrows across the year boundary', () {
      final duration = ExperienceDuration.between(
        DateTime(2020, 6),
        DateTime(2023, 3),
      );

      expect(duration.years, 2);
      expect(duration.months, 9);
    });

    test('less than a month is zero, not negative', () {
      final duration = ExperienceDuration.between(
        DateTime(2024, 1, 20),
        DateTime(2024, 1, 25),
      );

      expect(duration.isZero, isTrue);
    });

    test('clamps to zero rather than going negative', () {
      // An admin-entered end date earlier than the start — a typo, not a
      // state this app should ever compute a negative duration for.
      final duration = ExperienceDuration.between(
        DateTime(2023, 1),
        DateTime(2020, 1),
      );

      expect(duration.isZero, isTrue);
    });
  });

  group('format', () {
    test('English pluralises normally', () {
      expect(
        const ExperienceDuration(years: 1, months: 1).format(isArabic: false),
        '1 year 1 month',
      );
      expect(
        const ExperienceDuration(years: 3, months: 2).format(isArabic: false),
        '3 years 2 months',
      );
    });

    test('English drops whichever unit is zero', () {
      expect(
        const ExperienceDuration(years: 2, months: 0).format(isArabic: false),
        '2 years',
      );
      expect(
        const ExperienceDuration(years: 0, months: 5).format(isArabic: false),
        '5 months',
      );
    });

    test('reports under a month in each language', () {
      const zero = ExperienceDuration(years: 0, months: 0);
      expect(zero.format(isArabic: false), 'Less than a month');
      expect(zero.format(isArabic: true), 'أقل من شهر');
    });

    test('Arabic: 1 and 2 drop the numeral, the word carries the count', () {
      expect(
        const ExperienceDuration(years: 1, months: 0).format(isArabic: true),
        'سنة واحدة',
      );
      expect(
        const ExperienceDuration(years: 2, months: 0).format(isArabic: true),
        'سنتين',
      );
      expect(
        const ExperienceDuration(years: 0, months: 1).format(isArabic: true),
        'شهر واحد',
      );
      expect(
        const ExperienceDuration(years: 0, months: 2).format(isArabic: true),
        'شهرين',
      );
    });

    test('Arabic: 3 through 10 take the plural noun', () {
      expect(
        const ExperienceDuration(years: 3, months: 0).format(isArabic: true),
        '3 سنوات',
      );
      expect(
        const ExperienceDuration(years: 0, months: 10).format(isArabic: true),
        '10 أشهر',
      );
    });

    test('Arabic: 11 and above revert to the bare singular', () {
      expect(
        const ExperienceDuration(years: 11, months: 0).format(isArabic: true),
        '11 سنة',
      );
      expect(
        const ExperienceDuration(years: 0, months: 11).format(isArabic: true),
        '11 شهر',
      );
    });

    test('Arabic joins two present units with و, not a space', () {
      expect(
        const ExperienceDuration(years: 3, months: 2).format(isArabic: true),
        '3 سنوات وشهرين',
      );
    });
  });
}
