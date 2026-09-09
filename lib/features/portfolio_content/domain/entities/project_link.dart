import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_link.freezed.dart';
part 'project_link.g.dart';

/// What a project link opens. Drives both the icon and the label — "Source on
/// GitHub" reads very differently from "Try the live demo", and a visitor
/// should know which one they are about to tap before they tap it.
enum ProjectLinkType {
  gitHub,
  playStore,
  appStore,
  web,
  apk;

  /// Store links carry the official badge; everything else is icon + label in
  /// the site's own pill shape. Mixing a hand-drawn Play Store button into a
  /// row of real ones is the fastest way for a link row to look unofficial.
  bool get usesStoreBadge =>
      this == ProjectLinkType.playStore || this == appStore;
}

/// One outbound link on a project's detail page — a repo, a store listing, a
/// live demo, a sideloaded build.
///
/// Rendered in a fixed order of proof (web demo, then stores, then source,
/// then a raw APK) regardless of the order they were added in, so an admin
/// reordering the list has no effect on how it reads — see
/// `ProjectLinkType.usesStoreBadge` and the widget that sorts by `type.index`.
@freezed
abstract class ProjectLink with _$ProjectLink {
  const factory ProjectLink({
    required ProjectLinkType type,
    @Default('') String url,
  }) = _ProjectLink;

  const ProjectLink._();

  factory ProjectLink.fromJson(Map<String, dynamic> json) =>
      _$ProjectLinkFromJson(json);

  bool get isEmpty => url.trim().isEmpty;
}
