import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/styles/fonts/my_fonts.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/navigation_extensions.dart';
import '../../../../core/utils/hex_color.dart';
import '../../../../core/utils/responsive/app_breakpoints.dart';
import '../../../../core/widgets/admin/admin_gate.dart';
import '../../../../core/widgets/chrome/portfolio_scaffold.dart';
import '../../../../core/widgets/common/app_snack_bar.dart';
import '../../../../core/widgets/common/content_container.dart';
import '../../../../core/widgets/common/pill_button.dart';
import '../../../../core/widgets/showcase/project_links_row.dart';
import '../../../../core/widgets/showcase/project_skills_chips.dart';
import '../../../../core/widgets/showcase/project_media_sections.dart';
import '../../../../di/di.dart';
import '../../../portfolio_content/domain/entities/personal_project.dart';
import '../../../portfolio_content/domain/entities/section_definition.dart';
import '../../../portfolio_content/presentation/view_data/list_row_data.dart';
import '../view_model/projects_actions.dart';
import '../view_model/projects_states.dart';
import '../view_model/projects_view_model.dart';
import '../widgets/project_form_screen.dart';

/// Internal detail view for one project — one column, full width: identity
/// and links, then feature graphic / screenshots / video / GIF as their own
/// sections, then the write-up. Marco's projects are real apps, so this stays
/// in-app rather than linking out.
class ProjectDetailView extends StatefulWidget {
  const ProjectDetailView({required this.data, super.key});

  final ListRowData data;

  @override
  State<ProjectDetailView> createState() => _ProjectDetailViewState();
}

class _ProjectDetailViewState extends State<ProjectDetailView> {
  /// Starts as the row data the route carried, then follows the project after
  /// an edit — the argument that opened this page is a snapshot, and saving
  /// would otherwise leave the page showing what it used to say.
  late ListRowData _data = widget.data;

  Future<void> _edit(
    BuildContext context,
    ProjectsViewModelCubit cubit,
    List<PersonalProject> projects,
  ) async {
    final index = projects.indexWhere((project) => project.id == _data.id);
    if (index == -1) return;

    final isArabic = context.isArabic;
    final built = await ProjectFormScreen.open(
      context,
      project: projects[index],
    );
    if (built == null || !mounted) return;

    cubit.doAction(SaveProject(built));
    setState(() => _data = ListRowData.fromProject(built, index, isArabic));

    // `this.context` rather than the Builder's: the State's own context is what
    // `mounted` actually vouches for.
    if (!mounted) return;
    AppSnackBar.show(
      this.context,
      this.context.translate(LangKeys.adminSaved),
      kind: SnackKind.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProjectsViewModelCubit>(
      // Its own provider: this route is pushed on its own, outside whichever
      // list the visitor came from.
      create: (_) => getIt<ProjectsViewModelCubit>()..doAction(LoadProjects()),
      child: Builder(builder: _buildBody),
    );
  }

  Widget _buildBody(BuildContext context) {
    final data = _data;
    final accent = HexColor.parse(data.accentHex, context.colors.accent);

    return PortfolioScaffold(
      activeSectionId: BuiltInSectionIds.projects,
      children: <Widget>[
        SizedBox(height: 32.h),
        ContentContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  PillButton(
                    label: context.translate(LangKeys.projectsBack),
                    variant: PillButtonVariant.outlined,
                    showArrow: false,
                    dense: true,
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => context.pop<void>(),
                  ),
                  const Spacer(),
                  AdminGate(
                    child: BlocBuilder<ProjectsViewModelCubit, ProjectsState>(
                      builder: (context, state) {
                        // Disabled until the load lands: without the project
                        // list there is nothing to hand the form.
                        final projects = state is ProjectsSuccess
                            ? state.projects
                            : const <PersonalProject>[];
                        return PillButton(
                          label: context.translate(LangKeys.adminEdit),
                          variant: PillButtonVariant.outlined,
                          showArrow: false,
                          dense: true,
                          icon: Icons.edit_outlined,
                          onPressed: projects.isEmpty
                              ? null
                              : () => _edit(
                                  context,
                                  context.read<ProjectsViewModelCubit>(),
                                  projects,
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              _DetailBody(data: data, accent: accent),
              SizedBox(height: 64.h),
            ],
          ),
        ),
      ],
    );
  }
}

/// The whole write-up, one column, full page width — replacing the old
/// two-column split where media sat in a side rail never wider than roughly
/// half the page. A feature graphic is a wide banner by definition; fighting
/// it into a narrow column was the "not comfortable" the layout was renamed
/// over. Order follows the site's project-details rules: identity and proof
/// (title, links) first, media second — visitors judge the screenshots before
/// they read a word — then the write-up.
class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.data, required this.accent});

  final ListRowData data;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (data.category.trim().isNotEmpty)
          Text(
            data.category.toUpperCase(),
            style: MyFonts.caps10.copyWith(color: accent),
          ),
        SizedBox(height: 10.h),
        Text(
          data.title,
          style: (context.isMobile ? MyFonts.display36 : MyFonts.display48)
              .copyWith(color: colors.onNavy),
        ),
        // Overview and Key Features share one width cap — the ~70-character
        // measure the content rules ask for. Left uncapped, a full-width
        // single column would stretch a sentence edge to edge on desktop.
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 680.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                context.translate(LangKeys.projectsOverview).toUpperCase(),
                style: MyFonts.caps10.copyWith(color: colors.onNavyFaint),
              ),
              SizedBox(height: 10.h),
              Text(
                data.description,
                style: MyFonts.regular16.copyWith(color: colors.onNavyMuted),
              ),
              if (data.features.isNotEmpty) ...<Widget>[
                SizedBox(height: 32.h),
                Text(
                  context.translate(LangKeys.projectsKeyFeatures).toUpperCase(),
                  style: MyFonts.caps10.copyWith(color: colors.onNavyFaint),
                ),
                SizedBox(height: 14.h),
                for (final feature in data.features)
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 5.h),
                          child: Transform.scale(
                            scaleX: context.isRtl ? -1 : 1,
                            child: Icon(
                              Icons.play_arrow_rounded,
                              size: 14.r,
                              color: accent,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            feature,
                            style: MyFonts.regular16.copyWith(
                              color: colors.onNavyMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
        if (data.links.isNotEmpty) ...<Widget>[
          SizedBox(height: 20.h),
          ProjectLinksRow(links: data.links),
        ],
        if (data.panels.isNotEmpty || data.videos.isNotEmpty) ...<Widget>[
          SizedBox(height: 40.h),
          // Full page width now, not a side-column width — a LayoutBuilder
          // rather than a fixed constant because that width differs by
          // breakpoint (ContentContainer's own padding already accounts for
          // desktop vs tablet vs mobile) and this is the one place that needs
          // to know it precisely, to size a feature-graphic banner correctly.
          LayoutBuilder(
            builder: (context, constraints) => ProjectMediaSections(
              panels: data.panels,
              videos: data.videos,
              background: data.background,
              stripWidth: constraints.maxWidth,
            ),
          ),
        ],
        SizedBox(height: 40.h),

        if (data.skills.isNotEmpty ||
            data.technologies.isNotEmpty ||
            data.tools.isNotEmpty) ...<Widget>[
          SizedBox(height: 32.h),
          ProjectSkillsChips(
            skills: data.skills,
            technologies: data.technologies,
            tools: data.tools,
          ),
        ],
      ],
    );
  }
}
