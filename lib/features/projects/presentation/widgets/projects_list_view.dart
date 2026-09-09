import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/styles/fonts/my_fonts.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/navigation_extensions.dart';
import '../../../../core/widgets/admin/admin_add_button.dart';
import '../../../../core/widgets/admin/admin_confirm_dialog.dart';
import '../../../../core/widgets/common/app_snack_bar.dart';
import '../../../../core/widgets/motion/motion_durations.dart';
import '../../../../core/widgets/motion/reveal_on_scroll.dart';
import '../../../portfolio_content/domain/entities/personal_project.dart';
import '../../../portfolio_content/presentation/view_data/list_row_data.dart';
import '../view_model/projects_actions.dart';
import '../view_model/projects_states.dart';
import '../view_model/projects_view_model.dart';
import 'project_form_screen.dart';
import 'project_list_row.dart';

/// The numbered project rows, shared by the Projects page and the Home page's
/// featured block so the row wiring — reveal stagger, admin actions, detail
/// navigation — exists once.
///
/// Expects an ancestor [BlocProvider] of [ProjectsViewModelCubit]; each screen
/// supplies its own.
class ProjectsListView extends StatelessWidget {
  const ProjectsListView({this.limit, super.key});

  /// Renders at most this many rows. Null shows every project.
  final int? limit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectsViewModelCubit, ProjectsState>(
      builder: (context, state) => switch (state) {
        ProjectsInitial() || ProjectsLoading() => const _ProjectsLoading(),
        ProjectsError() => _ProjectsMessage(text: state.message),
        ProjectsSuccess() => _ProjectsRows(
          projects: state.projects,
          limit: limit,
        ),
      },
    );
  }
}

class _ProjectsRows extends StatelessWidget {
  const _ProjectsRows({required this.projects, required this.limit});

  final List<PersonalProject> projects;
  final int? limit;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProjectsViewModelCubit>();

    if (projects.isEmpty) {
      return Column(
        children: <Widget>[
          _ProjectsMessage(text: context.translate(LangKeys.projectsEmpty)),
          _AddProjectButton(cubit: cubit),
        ],
      );
    }

    final shown = limit == null
        ? projects
        : projects.take(limit!).toList(growable: false);

    return Column(
      children: <Widget>[
        for (var i = 0; i < shown.length; i++)
          Builder(
            builder: (context) {
              // Resolved once here so the row and the detail route share
              // exactly the same language-resolved data.
              final data = ListRowData.fromProject(
                shown[i],
                i,
                context.isArabic,
              );
              return RevealOnScroll(
                delay: Motion.stagger * (i % 4),
                child: ProjectListRow(
                  key: ValueKey<String>(shown[i].id),
                  data: data,
                  onOpen: () => context.pushNamed<void>(
                    RouteNames.projectDetail,
                    arguments: data,
                  ),
                  onEdit: () => _editProject(context, cubit, shown[i]),
                  onDelete: () => _deleteProject(context, cubit, shown[i].id),
                ),
              );
            },
          ),
        SizedBox(height: 24.h),
        _AddProjectButton(cubit: cubit),
      ],
    );
  }
}

class _AddProjectButton extends StatelessWidget {
  const _AddProjectButton({required this.cubit});

  final ProjectsViewModelCubit cubit;

  @override
  Widget build(BuildContext context) {
    return AdminAddButton(
      label: context.translate(LangKeys.adminAdd),
      onPressed: () => _editProject(context, cubit, null),
    );
  }
}

/// Opens the form for [project] (or a blank one when null) and saves the result.
///
/// The cubit is passed in rather than read after the await: the row that owns
/// this context can be rebuilt away while the sheet is open.
Future<void> _editProject(
  BuildContext context,
  ProjectsViewModelCubit cubit,
  PersonalProject? project,
) async {
  final built = await ProjectFormScreen.open(context, project: project);
  if (built == null || !context.mounted) return;

  cubit.doAction(SaveProject(built));
  AppSnackBar.show(
    context,
    context.translate(LangKeys.adminSaved),
    kind: SnackKind.success,
  );
}

Future<void> _deleteProject(
  BuildContext context,
  ProjectsViewModelCubit cubit,
  String id,
) async {
  final confirmed = await AdminConfirmDialog.show(context);
  if (!confirmed || !context.mounted) return;

  cubit.doAction(DeleteProject(id));
  AppSnackBar.show(
    context,
    context.translate(LangKeys.adminDeleted),
    kind: SnackKind.success,
  );
}

class _ProjectsLoading extends StatelessWidget {
  const _ProjectsLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 64.h),
      child: Center(
        child: CircularProgressIndicator(color: context.colors.accent),
      ),
    );
  }
}

class _ProjectsMessage extends StatelessWidget {
  const _ProjectsMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 64.h),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: MyFonts.regular16.copyWith(color: context.colors.onNavyMuted),
        ),
      ),
    );
  }
}
