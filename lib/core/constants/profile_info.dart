/// Marco's static identity content. Unlike Projects/Certificates/Experience/Pricing
/// this is not admin-editable — it's who he is, not a content collection.
class ProfileInfo {
  const ProfileInfo._();

  static const String fullName = 'Marco Nagy';
  static const String fullNameAr = 'ماركو ناجي';
  static const String monogram = 'MN';
  static const String role = 'Flutter Developer';
  static const String roleAr = 'مطوّر تطبيقات Flutter';
  static const String location = 'Alexandria, Egypt';
  static const String locationAr = 'الإسكندرية، مصر';

  static const String email = 'marconbishay@gmail.com';
  static const String phone = '01220407005';
  static const String linkedInUrl = 'https://linkedin.com/in/marco-nagy';
  static const String gitHubUrl = 'https://github.com/Marco-Nagy';

  static const String summary =
      'Flutter Developer with 4+ years of experience building and maintaining '
      'production mobile applications, including ERP and e-commerce systems. '
      'Hands-on experience managing application state with Bloc, integrating '
      'REST APIs, and implementing local data persistence for offline usage. '
      'Open to remote, hybrid, or on-site Flutter roles within product-driven teams.';

  static const String summaryAr =
      'مطوّر تطبيقات Flutter بخبرة تتجاوز 4 سنوات في بناء وصيانة تطبيقات موبايل '
      'حية، منها أنظمة ERP ومنصات تجارة إلكترونية. خبرة عملية في إدارة الحالة '
      'باستخدام Bloc، وربط REST APIs، وتنفيذ التخزين المحلي لدعم العمل بدون '
      'إنترنت. متاح للعمل عن بُعد أو هجين أو حضوري ضمن فرق منتج.';

  /// Split into statement-style sentences for the About page's large left column.
  static const List<String> aboutStatements = <String>[
    'I build and maintain production Flutter apps — ERP systems, e-commerce '
        'platforms, and real-time delivery tracking — with 4+ years of shipping to '
        'real users.',
    'I specialize in Clean Architecture and Bloc, integrating REST APIs and '
        'implementing local persistence so apps stay useful offline.',
    'I also have a strong passion for reliability — unit testing, structured '
        'error handling, and CI/CD pipelines that keep releases boring.',
  ];

  static const List<String> aboutStatementsAr = <String>[
    'أبني وأصون تطبيقات Flutter حية — أنظمة ERP ومنصات تجارة إلكترونية وتتبع '
        'توصيل في الوقت الفعلي — بخبرة تتجاوز 4 سنوات من الإطلاق لمستخدمين حقيقيين.',
    'أتخصص في Clean Architecture وBloc، مع ربط REST APIs وتنفيذ التخزين المحلي '
        'ليظل التطبيق مفيدًا بدون إنترنت.',
    'ولديّ شغف كبير بالاعتمادية — الاختبارات الوحدوية ومعالجة الأخطاء المنظمة '
        'وخطوط CI/CD التي تجعل الإصدارات هادئة وخالية من المفاجآت.',
  ];

  /// Role tags rendered under the hero headline, joined with " / ".
  static const List<String> roleTags = <String>[
    'Flutter Developer',
    'Mobile Engineer',
    'Clean Architecture',
  ];

  static const List<String> roleTagsAr = <String>[
    'مطوّر Flutter',
    'مهندس تطبيقات موبايل',
    'Clean Architecture',
  ];
}
