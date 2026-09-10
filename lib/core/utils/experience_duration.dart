/// Whole-month span between two dates, expressed as years + leftover months.
class ExperienceDuration {
  const ExperienceDuration({required this.years, required this.months});

  factory ExperienceDuration.between(DateTime start, DateTime end) {
    final totalMonths = (end.year - start.year) * 12 + (end.month - start.month);
    final clamped = totalMonths < 0 ? 0 : totalMonths;
    return ExperienceDuration(years: clamped ~/ 12, months: clamped % 12);
  }

  final int years;
  final int months;

  bool get isZero => years == 0 && months == 0;

  /// Bilingual "X years Y months" / "X سنوات وY أشهر" rendering. English
  /// falls back to plain singular/plural; Arabic follows its 0/1/2/3-10/11+
  /// noun agreement since a flat plural reads as a mistake to a native
  /// speaker.
  String format({required bool isArabic}) {
    if (isZero) return isArabic ? 'أقل من شهر' : 'Less than a month';

    final parts = <String>[
      if (years > 0)
        isArabic
            ? _arabicUnit(years, _yearAr)
            : _englishUnit(years, 'year'),
      if (months > 0)
        isArabic
            ? _arabicUnit(months, _monthAr)
            : _englishUnit(months, 'month'),
    ];

    return parts.join(isArabic ? ' و' : ' ');
  }

  static String _englishUnit(int n, String unit) => '$n $unit${n == 1 ? '' : 's'}';

  // Arabic numeral-noun agreement: 1 and 2 drop the numeral entirely (the
  // word itself carries the count), 3-10 takes the plural, 11+ reverts to
  // the bare singular — writing "11 سنوات" or "2 سنة" both read as mistakes
  // to a native speaker.
  static String _arabicUnit(int n, _ArabicNoun noun) => switch (n) {
    1 => noun.one,
    2 => noun.two,
    >= 3 && <= 10 => '$n ${noun.plural}',
    _ => '$n ${noun.bare}',
  };
}

class _ArabicNoun {
  const _ArabicNoun({
    required this.bare,
    required this.one,
    required this.two,
    required this.plural,
  });

  final String bare;
  final String one;
  final String two;
  final String plural;
}

const _yearAr = _ArabicNoun(
  bare: 'سنة',
  one: 'سنة واحدة',
  two: 'سنتين',
  plural: 'سنوات',
);
const _monthAr = _ArabicNoun(
  bare: 'شهر',
  one: 'شهر واحد',
  two: 'شهرين',
  plural: 'أشهر',
);
