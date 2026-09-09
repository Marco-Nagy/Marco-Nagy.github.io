import '../../domain/entities/custom_section_item.dart';
import '../../domain/entities/media_ref.dart';
import '../../domain/entities/project_video.dart';
import '../../domain/entities/shot_background.dart';
import '../../domain/entities/showcase_panel.dart';
import '../../domain/entities/personal_project.dart';
import '../../domain/entities/project_link.dart';
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
    this.videos = const <ProjectVideo>[],
    this.background = const ShotBackground(),
    this.accentHex = '4CC9F0',
    this.linkUrl = '',
    this.links = const <ProjectLink>[],
    this.skills = const <String>[],
    this.technologies = const <String>[],
    this.tools = const <String>[],
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

  /// Empty for a custom-section row — only [PersonalProject] carries videos.
  final List<ProjectVideo> videos;

  /// Default background the panels and videos render on.
  final ShotBackground background;
  final String accentHex;
  final String linkUrl;

  /// Outbound links (repo, stores, demo) — populated for [PersonalProject]
  /// rows only; custom-section items use the single [linkUrl] instead.
  final List<ProjectLink> links;

  /// Skills · technologies · tools chip groups. Empty for custom-section rows —
  /// only [PersonalProject] carries them.
  final List<String> skills;
  final List<String> technologies;
  final List<String> tools;

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
      videos: project.videos,
      background: project.showcaseBackground,
      accentHex: project.accentHex,
      links: project.links,
      skills: pickList(isArabic, project.skills, project.skillsAr),
      technologies: project.technologies,
      tools: project.tools,
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
