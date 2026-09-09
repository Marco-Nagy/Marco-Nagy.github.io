import 'package:freezed_annotation/freezed_annotation.dart';

import 'media_ref.dart';
import 'project_link.dart';
import 'project_video.dart';
import 'shot_background.dart';
import 'showcase_panel.dart';

part 'personal_project.freezed.dart';
part 'personal_project.g.dart';

/// A personal project shown in the Projects showcase. Employer work (GARAS ERP,
/// Royal Tents) is deliberately excluded from this collection — it lives only in
/// [WorkHistoryEntry] bullets.
@freezed
abstract class PersonalProject with _$PersonalProject {
  const factory PersonalProject({
    required String id,
    required String title,
    @Default('') String titleAr,
    @Default('') String description,
    @Default('') String descriptionAr,
    @Default(<String>[]) List<String> features,
    @Default(<String>[]) List<String> featuresAr,
    @Default('') String category,
    @Default('') String categoryAr,

    /// Thumbnail used by the list row's hover reveal.
    @Default(MediaRef()) MediaRef cover,

    /// Composed showcase panels shown in the detail view — feature graphic,
    /// screenshots and GIFs. Video lives in [videos] instead: see
    /// [ProjectVideo] for why it isn't a panel.
    @Default(<ShowcasePanel>[]) List<ShowcasePanel> panels,

    /// The project's videos — screen recordings and YouTube walkthroughs.
    @Default(<ProjectVideo>[]) List<ProjectVideo> videos,

    /// Default background for this project's panels and videos. Five
    /// screenshots normally share one background, so it is stored once here
    /// rather than per panel.
    @Default(ShotBackground()) ShotBackground showcaseBackground,

    /// Outbound links — repo, store listings, live demo. Rendered in a fixed
    /// order of proof, not insertion order; see [ProjectLinkType].
    @Default(<ProjectLink>[]) List<ProjectLink> links,

    /// What he did — Clean Architecture, state management, localization. Kept
    /// out of the technologies/tools split deliberately: a skill is a
    /// capability, not a product name. Bilingual, unlike the two lists below.
    @Default(<String>[]) List<String> skills,
    @Default(<String>[]) List<String> skillsAr,

    /// What the app is built ON — Flutter, Firebase, ASP.NET Core. English in
    /// both languages: these are proper nouns, not prose, and translating a
    /// product name only makes it harder to search for.
    @Default(<String>[]) List<String> technologies,

    /// What it was built and shipped WITH, and never runs inside the app —
    /// Git, Figma, Postman. Same English-only rule as [technologies].
    @Default(<String>[]) List<String> tools,

    /// Per-project hover accent, as a 6-digit RRGGBB hex string.
    @Default('4CC9F0') String accentHex,
    @Default(0) int order,
  }) = _PersonalProject;

  const PersonalProject._();

  factory PersonalProject.fromJson(Map<String, dynamic> json) =>
      _$PersonalProjectFromJson(json);

  /// The background a given panel actually renders with.
  ShotBackground backgroundFor(ShowcasePanel panel) =>
      panel.backgroundOverride ?? showcaseBackground;
}
