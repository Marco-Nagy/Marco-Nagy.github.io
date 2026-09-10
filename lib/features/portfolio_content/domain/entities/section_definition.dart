import 'package:freezed_annotation/freezed_annotation.dart';

part 'section_definition.freezed.dart';
part 'section_definition.g.dart';

/// How a section renders. Built-in sections each map to a dedicated screen;
/// custom sections reuse the same renderers through the view-data layer.
enum SectionType {
  hero,
  statement,
  timeline,
  listRows,
  imageGrid,
  chips,
  pricing,
  contact;

  /// Types a new custom section may choose. hero/pricing/contact are singletons
  /// by nature and are deliberately not duplicable.
  static const List<SectionType> customCapable = <SectionType>[
    listRows,
    imageGrid,
    timeline,
    chips,
    statement,
  ];
}

enum SectionKind {
  /// Shipped by default, content lives in its own typed entity, cannot be
  /// deleted.
  builtIn,

  /// Created in debug, content lives in [CustomSectionItem].
  custom,
}

/// Nav + page metadata for one section.
///
/// For built-in sections this stores only metadata — order, visibility and a
/// renameable bilingual title — while the content stays in its typed entity.
@freezed
abstract class SectionDefinition with _$SectionDefinition {
  const factory SectionDefinition({
    required String id,
    required SectionType type,
    @Default(SectionKind.builtIn) SectionKind kind,
    @Default('') String titleEn,
    @Default('') String titleAr,
    @Default(0) int order,
    @Default(true) bool visible,
  }) = _SectionDefinition;

  const SectionDefinition._();

  factory SectionDefinition.fromJson(Map<String, dynamic> json) =>
      _$SectionDefinitionFromJson(json);

  bool get isCustom => kind == SectionKind.custom;
}

/// Stable ids for the seeded built-in sections. The routes layer maps these to
/// concrete paths — the domain stays free of routing knowledge.
class BuiltInSectionIds {
  const BuiltInSectionIds._();

  static const String home = 'home';
  static const String about = 'about';
  static const String experience = 'experience';
  static const String projects = 'projects';
  static const String certificates = 'certificates';
  static const String pricing = 'pricing';
  static const String contact = 'contact';
}
