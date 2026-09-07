import '../../domain/entities/custom_section_item.dart';
import '../../domain/entities/media_ref.dart';
import '../../domain/entities/shot_background.dart';
import '../../domain/entities/showcase_panel.dart';
import '../../domain/entities/personal_project.dart';
import 'localized_pick.dart';

/// What a numbered list row needs to render, resolved into one language.
///
/// Both a seeded [PersonalProject] and a [CustomSectionItem] map onto this, so
/// the row widget is written once and serves the built-in Projects section and
/// any custom `listRows` section alike.
class ListRowData {
  const ListRowData({
    required this.id,
    required this.index,
    required this.title,
    this.category = '',
    this.description = '',
    this.features = const <String>[],
    this.cover = const MediaRef(),
    this.panels = const <ShowcasePanel>[],
    this.background = const ShotBackground(),
    this.accentHex = '4CC9F0',
    this.linkUrl = '',
  });

  final String id;

  /// Pre-formatted two-digit index ("01", "02", …).
  final String index;
  final String title;
  final String category;
  final String description;
  final List<String> features;
  final MediaRef cover;
  final List<ShowcasePanel> panels;

  /// Default background the panels render on.
  final ShotBackground background;
  final String accentHex;
  final String linkUrl;

  factory ListRowData.fromProject(
    PersonalProject project,
    int position,
    bool isArabic,
  ) {
    return ListRowData(
      id: project.id,
      index: twoDigitIndex(position),
      title: pickText(isArabic, project.title, project.titleAr),
      category: pickText(isArabic, project.category, project.categoryAr),
      description: pickText(
        isArabic,
        project.description,
        project.descriptionAr,
      ),
      features: pickList(isArabic, project.features, project.featuresAr),
      cover: project.cover,
      panels: project.panels,
      background: project.showcaseBackground,
      accentHex: project.accentHex,
    );
  }

  factory ListRowData.fromCustomItem(
    CustomSectionItem item,
    int position,
    bool isArabic,
  ) {
    return ListRowData(
      id: item.id,
      index: twoDigitIndex(position),
      title: pickText(isArabic, item.titleEn, item.titleAr),
      category: pickText(isArabic, item.tagEn, item.tagAr),
      description: pickText(isArabic, item.descriptionEn, item.descriptionAr),
      features: pickList(isArabic, item.bulletsEn, item.bulletsAr),
      cover: item.images.isEmpty
          ? const MediaRef()
          : MediaRef.still(item.images.first),
      accentHex: item.accentHex,
      linkUrl: item.linkUrl,
    );
  }
}
