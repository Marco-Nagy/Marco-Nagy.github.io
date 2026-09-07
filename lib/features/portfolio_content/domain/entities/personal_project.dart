import 'package:freezed_annotation/freezed_annotation.dart';

import 'media_ref.dart';
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

    /// What the list row's hover reveal shows, and the detail view leads
    /// with. A still, a looping GIF, a screen recording or a YouTube
    /// walkthrough — see [MediaRef].
    @Default(MediaRef()) MediaRef cover,

    /// Composed showcase panels shown in the detail view.
    @Default(<ShowcasePanel>[]) List<ShowcasePanel> panels,

    /// Default background for this project's panels. Five screenshots normally
    /// share one background, so it is stored once here rather than per panel.
    @Default(ShotBackground()) ShotBackground showcaseBackground,

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
