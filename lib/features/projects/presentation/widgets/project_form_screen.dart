import 'package:flutter/material.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/navigation_extensions.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/text_list_converter.dart';
import '../../../../core/styles/colors/content_palette.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/admin/admin_color_field.dart';
import '../../../../core/widgets/admin/admin_form_screen.dart';
import '../../../../core/widgets/admin/admin_sub_list.dart';
import '../../../../core/widgets/admin/media_ref_field.dart';
import '../../../../core/widgets/common/underline_text_field.dart';
import 'background_form_sheet.dart';
import 'feature_graphic_form_screen.dart';
import 'gif_form_screen.dart';
import 'link_form_sheet.dart';
import 'screenshot_form_screen.dart';
import 'video_form_screen.dart';
import '../../../portfolio_content/domain/entities/media_ref.dart';
import '../../../portfolio_content/domain/entities/project_video.dart';
import '../../../portfolio_content/domain/entities/shot_background.dart';
import '../../../portfolio_content/domain/entities/showcase_panel.dart';
import '../../../portfolio_content/domain/entities/personal_project.dart';
import '../../../portfolio_content/domain/entities/project_link.dart';

/// Debug-mode add/edit screen for one project.
///
/// A full page rather than a sheet: by the time cover, panels, background and
/// links are all in play, this form is the deepest and longest one in the
/// admin surface — the one case where a dialog stops being quick to use and
/// starts being something to scroll inside of. Its own sub-editors (panel,
/// shot, background, link) stay bottom sheets; they open and close in one
/// save each, which is exactly what a sheet is for.
///
/// The text fields are controller-backed as usual; `cover`, `panels` and
/// `showcaseBackground` are structured values, so they live in state and are
/// edited by their own widgets and sheets. Everything else on the project —
/// anything a future field has not claimed yet — still rides through untouched
/// on `copyWith`.
class ProjectFormScreen extends StatefulWidget {
  const ProjectFormScreen({this.project, super.key});

  /// Null when adding.
  final PersonalProject? project;

  /// Opens the screen and resolves to the built project, or null if dismissed.
  static Future<PersonalProject?> open(
    BuildContext context, {
    PersonalProject? project,
  }) {
    return AdminFormScreen.open<PersonalProject>(
      context,
      ProjectFormScreen(project: project),
    );
  }

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  /// Resolved once, so a rebuild never hands the same new project a second id.
  late final String _id = widget.project?.id ?? IdGenerator.next('project');

  late final TextEditingController _titleEn;
  late final TextEditingController _titleAr;
  late final TextEditingController _categoryEn;
  late final TextEditingController _categoryAr;
  late final TextEditingController _descriptionEn;
  late final TextEditingController _descriptionAr;
  late final TextEditingController _featuresEn;
  late final TextEditingController _featuresAr;
  late final TextEditingController _skillsEn;
  late final TextEditingController _skillsAr;
  late final TextEditingController _technologies;
  late final TextEditingController _tools;
  late MediaRef _cover;
  late List<ShowcasePanel> _panels;
  late List<ProjectVideo> _videos;
  late ShotBackground _background;
  late List<ProjectLink> _links;
  late String _accentHex;
  late final TextEditingController _order;

  @override
  void initState() {
    super.initState();
    final project = widget.project;

    _titleEn = TextEditingController(text: project?.title ?? '');
    _titleAr = TextEditingController(text: project?.titleAr ?? '');
    _categoryEn = TextEditingController(text: project?.category ?? '');
    _categoryAr = TextEditingController(text: project?.categoryAr ?? '');
    _descriptionEn = TextEditingController(text: project?.description ?? '');
    _descriptionAr = TextEditingController(text: project?.descriptionAr ?? '');
    _featuresEn = TextEditingController(
      text: TextListConverter.toText(project?.features ?? <String>[]),
    );
    _featuresAr = TextEditingController(
      text: TextListConverter.toText(project?.featuresAr ?? <String>[]),
    );
    _skillsEn = TextEditingController(
      text: TextListConverter.toText(project?.skills ?? <String>[]),
    );
    _skillsAr = TextEditingController(
      text: TextListConverter.toText(project?.skillsAr ?? <String>[]),
    );
    _technologies = TextEditingController(
      text: TextListConverter.toText(project?.technologies ?? <String>[]),
    );
    _tools = TextEditingController(
      text: TextListConverter.toText(project?.tools ?? <String>[]),
    );
    _cover = project?.cover ?? const MediaRef();
    _panels = List<ShowcasePanel>.of(project?.panels ?? <ShowcasePanel>[]);
    _videos = List<ProjectVideo>.of(project?.videos ?? <ProjectVideo>[]);
    // A new project starts on the site gradient rather than ShotBackground's
    // `none`: an empty ground looks like the showcase failed to load, and it
    // is the one default nobody would deliberately choose.
    _background =
        project?.showcaseBackground ??
        ShotBackground(
          style: ShotBackgroundStyle.linearGradient,
          colorHex: ContentPalette.defaultGradient.fromHex,
          colorHex2: ContentPalette.defaultGradient.toHex,
        );
    _links = List<ProjectLink>.of(project?.links ?? <ProjectLink>[]);
    _accentHex = project?.accentHex ?? '4CC9F0';
    _order = TextEditingController(text: '${project?.order ?? 0}');
  }

  @override
  void dispose() {
    _titleEn.dispose();
    _titleAr.dispose();
    _categoryEn.dispose();
    _categoryAr.dispose();
    _descriptionEn.dispose();
    _descriptionAr.dispose();
    _featuresEn.dispose();
    _featuresAr.dispose();
    _skillsEn.dispose();
    _skillsAr.dispose();
    _technologies.dispose();
    _tools.dispose();

    _order.dispose();
    super.dispose();
  }

  void _submit() {
    final base = widget.project ?? PersonalProject(id: _id, title: '');
    final hex = _accentHex.trim().replaceFirst('#', '').toUpperCase();

    context.pop<PersonalProject>(
      base.copyWith(
        title: _titleEn.text.trim(),
        titleAr: _titleAr.text.trim(),
        category: _categoryEn.text.trim(),
        categoryAr: _categoryAr.text.trim(),
        description: _descriptionEn.text.trim(),
        descriptionAr: _descriptionAr.text.trim(),
        features: TextListConverter.toList(_featuresEn.text),
        featuresAr: TextListConverter.toList(_featuresAr.text),
        skills: TextListConverter.toList(_skillsEn.text),
        skillsAr: TextListConverter.toList(_skillsAr.text),
        technologies: TextListConverter.toList(_technologies.text),
        tools: TextListConverter.toList(_tools.text),
        cover: _cover,
        panels: _panels,
        videos: _videos,
        showcaseBackground: _background,
        links: _links,
        accentHex: hex.length == 6 ? hex : base.accentHex,
        order: int.tryParse(_order.text.trim()) ?? base.order,
      ),
    );
  }

  /// Opens the type-specific editor for an existing panel, keyed by id rather
  /// than a list index — the four media sections below each show a different
  /// filter over the one flat `_panels` list, so an index into one section's
  /// view means nothing against `_panels` itself. The panel's own classified
  /// layer picks which dialog opens, so a screenshot always reopens with its
  /// frame/scale/offset controls and a feature graphic never does.
  Future<void> _savePanel(Future<ShowcasePanel?> pending) async {
    final built = await pending;
    if (built == null) return;

    setState(() {
      final index = _panels.indexWhere((p) => p.id == built.id);
      if (index == -1) {
        _panels.add(built);
      } else {
        _panels[index] = built;
      }
      // Keep the list in the order the detail view will render it, so the
      // numbers in each section are the numbers the visitor sees.
      _panels.sort((a, b) => a.order.compareTo(b.order));
    });
  }

  void _deletePanel(String id) =>
      setState(() => _panels.removeWhere((p) => p.id == id));

  /// Same shape as [_savePanel], but for [_videos] — a video is never a
  /// [ShowcasePanel] (see [ProjectVideo]), so it gets its own parallel list
  /// and its own add/edit/delete rather than being filtered out of `_panels`.
  Future<void> _saveVideo(Future<ProjectVideo?> pending) async {
    final built = await pending;
    if (built == null) return;

    setState(() {
      final index = _videos.indexWhere((v) => v.id == built.id);
      if (index == -1) {
        _videos.add(built);
      } else {
        _videos[index] = built;
      }
      _videos.sort((a, b) => a.order.compareTo(b.order));
    });
  }

  void _deleteVideo(String id) =>
      setState(() => _videos.removeWhere((v) => v.id == id));

  Future<void> _editBackground() async {
    final built = await BackgroundFormSheet.open(
      context,
      background: _background,
    );
    if (built == null) return;
    setState(() => _background = built);
  }

  String _panelSubtitle(ShowcasePanel panel) {
    final shots = panel.shots.length;
    final caption = panel.captionEn.trim();
    if (caption.isNotEmpty) return caption;
    // The section a panel appears in follows `mediaLayer`, not `format` (a
    // GIF keeps `format: screenshot` for its aspect ratio) — so the count
    // label must read from `mediaLayer` too, or a GIF row would say
    // "screenshot".
    final kind = switch (panel.mediaLayer) {
      ProjectMediaLayer.featureGraphic => 'feature graphic',
      ProjectMediaLayer.screenshots => 'screenshot',
      ProjectMediaLayer.gif => 'gif',
    };
    return '$shots × $kind';
  }

  /// A video has no shots to count, so its fallback is its shape rather than
  /// the panel rows' "n × kind".
  String _videoSubtitle(ProjectVideo video) {
    final caption = video.captionEn.trim();
    if (caption.isNotEmpty) return caption;
    final kind = video.media.kind == MediaKind.videoEmbed ? 'youtube' : 'video';
    return '$kind · ${video.aspectRatio.toStringAsFixed(2)}';
  }

  List<ShowcasePanel> _panelsFor(ProjectMediaLayer layer) =>
      _panels.where((p) => p.mediaLayer == layer).toList();

  /// Four independent sections, each wired to its own dedicated screen —
  /// [FeatureGraphicFormScreen], [ScreenshotFormScreen], [VideoFormScreen],
  /// [GifFormScreen] — rather than one generic section dispatching on layer.
  /// The list-row plumbing ([AdminSubList], [_savePanel], [_deletePanel]) is
  /// mechanical and genuinely shared across every editable list in this
  /// screen already (panels, links); it is the *editor* for each media kind
  /// that stays separate, which is the part that actually differs between a
  /// feature graphic and a video.
  Widget _featureGraphicSection() {
    final inLayer = _panelsFor(ProjectMediaLayer.featureGraphic);
    return AdminSubList(
      label: context.translate(LangKeys.mediaLayerFeatureGraphic),
      addLabel: context.translate(LangKeys.adminAddFeatureGraphic),
      items: <AdminSubListItem>[
        for (var i = 0; i < inLayer.length; i++)
          AdminSubListItem(
            title: '${i + 1}. ${inLayer[i].id}',
            subtitle: _panelSubtitle(inLayer[i]),
            onEdit: () => _savePanel(
              FeatureGraphicFormScreen.open(context, panel: inLayer[i]),
            ),
            onDelete: () => _deletePanel(inLayer[i].id),
          ),
      ],
      onAdd: () => _savePanel(FeatureGraphicFormScreen.open(context)),
    );
  }

  Widget _screenshotsSection() {
    final inLayer = _panelsFor(ProjectMediaLayer.screenshots);
    return AdminSubList(
      label: context.translate(LangKeys.mediaLayerScreenshots),
      addLabel: context.translate(LangKeys.adminAddScreenshot),
      items: <AdminSubListItem>[
        for (var i = 0; i < inLayer.length; i++)
          AdminSubListItem(
            title: '${i + 1}. ${inLayer[i].id}',
            subtitle: _panelSubtitle(inLayer[i]),
            onEdit: () => _savePanel(
              ScreenshotFormScreen.open(
                context,
                panel: inLayer[i],
                siblingPanels: inLayer,
                background: _background,
              ),
            ),
            onDelete: () => _deletePanel(inLayer[i].id),
          ),
      ],
      onAdd: () => _savePanel(
        ScreenshotFormScreen.open(
          context,
          siblingPanels: inLayer,
          background: _background,
        ),
      ),
    );
  }

  /// Reads `_videos` directly rather than filtering `_panels`: a video is
  /// never a panel (see [ProjectVideo]), so there is nothing to filter.
  Widget _videoSection() {
    return AdminSubList(
      label: context.translate(LangKeys.mediaLayerVideo),
      addLabel: context.translate(LangKeys.adminAddVideo),
      items: <AdminSubListItem>[
        for (var i = 0; i < _videos.length; i++)
          AdminSubListItem(
            title: '${i + 1}. ${_videos[i].id}',
            subtitle: _videoSubtitle(_videos[i]),
            onEdit: () =>
                _saveVideo(VideoFormScreen.open(context, video: _videos[i])),
            onDelete: () => _deleteVideo(_videos[i].id),
          ),
      ],
      onAdd: () => _saveVideo(VideoFormScreen.open(context)),
    );
  }

  Widget _gifSection() {
    final inLayer = _panelsFor(ProjectMediaLayer.gif);
    return AdminSubList(
      label: context.translate(LangKeys.mediaLayerGif),
      addLabel: context.translate(LangKeys.adminAddGif),
      items: <AdminSubListItem>[
        for (var i = 0; i < inLayer.length; i++)
          AdminSubListItem(
            title: '${i + 1}. ${inLayer[i].id}',
            subtitle: _panelSubtitle(inLayer[i]),
            onEdit: () =>
                _savePanel(GifFormScreen.open(context, panel: inLayer[i])),
            onDelete: () => _deletePanel(inLayer[i].id),
          ),
      ],
      onAdd: () => _savePanel(GifFormScreen.open(context)),
    );
  }

  Future<void> _editLink(int? index) async {
    final built = await LinkFormSheet.open(
      context,
      link: index == null ? null : _links[index],
    );
    if (built == null) return;

    setState(() {
      if (index == null) {
        _links.add(built);
      } else {
        _links[index] = built;
      }
    });
  }

  String _linkTypeLabel(ProjectLinkType type) =>
      context.translate(switch (type) {
        ProjectLinkType.gitHub => LangKeys.projectLinkGithub,
        ProjectLinkType.playStore => LangKeys.projectLinkPlayStore,
        ProjectLinkType.appStore => LangKeys.projectLinkAppStore,
        ProjectLinkType.web => LangKeys.projectLinkWeb,
        ProjectLinkType.apk => LangKeys.projectLinkApk,
      });

  List<Widget> _fields(BuildContext context) {
    return <Widget>[
      UnderlineTextField(
        label: context.translate(LangKeys.fieldTitleEn),
        controller: _titleEn,
        validator: (value) => Validators.required(context, value),
        textInputAction: TextInputAction.next,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldTitleAr),
        controller: _titleAr,
        textInputAction: TextInputAction.next,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldCategoryEn),
        controller: _categoryEn,
        textInputAction: TextInputAction.next,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldCategoryAr),
        controller: _categoryAr,
        textInputAction: TextInputAction.next,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldDescriptionEn),
        controller: _descriptionEn,
        maxLines: 3,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldDescriptionAr),
        controller: _descriptionAr,
        maxLines: 3,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldFeaturesEn),
        controller: _featuresEn,
        maxLines: 6,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldFeaturesAr),
        controller: _featuresAr,
        maxLines: 6,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldSkillsEn),
        controller: _skillsEn,
        maxLines: 4,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldSkillsAr),
        controller: _skillsAr,
        maxLines: 4,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldTechnologies),
        controller: _technologies,
        maxLines: 4,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldTools),
        controller: _tools,
        maxLines: 4,
      ),
      MediaRefField(
        label: context.translate(LangKeys.fieldCoverImage),
        value: _cover,
        // No setState: MediaRefField draws its own preview, and nothing else
        // in this form reads the cover until save.
        onChanged: (next) => _cover = next,
      ),
      // Four sections rather than one flat panel list: each media kind gets
      // its own labelled section and its own "Add" already set to that kind,
      // instead of an admin opening a bare panel and hunting for the right
      // format inside it.
      _featureGraphicSection(),
      _screenshotsSection(),
      _videoSection(),
      _gifSection(),
      AdminSubList(
        label: context.translate(LangKeys.fieldProjectBackground),
        addLabel: context.translate(LangKeys.adminEdit),
        items: <AdminSubListItem>[
          AdminSubListItem(
            title: _background.style.name,
            subtitle: _background.isEmpty
                ? context.translate(LangKeys.backgroundNone)
                : '${_background.colorHex} → ${_background.colorHex2}',
            onEdit: _editBackground,
            onDelete: () =>
                setState(() => _background = const ShotBackground()),
          ),
        ],
        onAdd: _editBackground,
      ),
      AdminSubList(
        label: context.translate(LangKeys.fieldProjectLinks),
        addLabel: context.translate(LangKeys.adminAddLink),
        items: <AdminSubListItem>[
          for (var i = 0; i < _links.length; i++)
            AdminSubListItem(
              title: _linkTypeLabel(_links[i].type),
              subtitle: _links[i].isEmpty
                  ? context.translate(LangKeys.adminEmptyItem)
                  : _links[i].url,
              onEdit: () => _editLink(i),
              onDelete: () => setState(() => _links.removeAt(i)),
            ),
        ],
        onAdd: () => _editLink(null),
      ),
      AdminColorField(
        label: context.translate(LangKeys.fieldAccentColor),
        value: _accentHex,
        hint: '4CC9F0',
        onChanged: (hex) => _accentHex = hex,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldOrder),
        controller: _order,
        keyboardType: TextInputType.number,
        validator: (value) => Validators.number(context, value),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormScreen(
      title: context.translate(
        widget.project == null
            ? LangKeys.formAddProject
            : LangKeys.formEditProject,
      ),
      fieldsBuilder: _fields,
      onSave: _submit,
    );
  }
}
