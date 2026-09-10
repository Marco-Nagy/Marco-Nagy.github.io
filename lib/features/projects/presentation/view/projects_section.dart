import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/extension/site_content_extensions.dart';
import '../../../portfolio_content/domain/entities/section_definition.dart';
import '../../../../core/widgets/common/content_container.dart';
import '../../../../core/widgets/section/section_divider_header.dart';
import '../../../../di/di.dart';
import '../view_model/projects_actions.dart';
import '../view_model/projects_view_model.dart';
import '../widgets/projects_list_view.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProjectsViewModelCubit>(
      create: (_) => getIt<ProjectsViewModelCubit>()..doAction(LoadProjects()),
      child: const _ProjectsBody(),
    );
  }
}

class _ProjectsBody extends StatelessWidget {
  const _ProjectsBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionDividerHeader(
          title: context.sectionTitle(BuiltInSectionIds.projects),
        ),
        const ContentContainer(child: ProjectsListView()),
        SizedBox(height: 96.h),
      ],
    );
  }
}
