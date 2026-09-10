import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/common/data_result.dart';
import '../../../portfolio_content/domain/entities/personal_project.dart';
import '../../../portfolio_content/domain/use_cases/projects_use_case.dart';
import 'projects_actions.dart';
import 'projects_states.dart';

@injectable
class ProjectsViewModelCubit extends Cubit<ProjectsState> {
  ProjectsViewModelCubit(this._useCase) : super(const ProjectsInitial());

  final ProjectsUseCase _useCase;

  List<PersonalProject> projects = <PersonalProject>[];

  void doAction(ProjectsActions action) {
    switch (action) {
      case LoadProjects():
        _load();
      case SaveProject():
        _save(action.project);
      case DeleteProject():
        _delete(action.id);
      case ReorderProjects():
        _reorder(action.projects);
    }
  }

  Future<void> _load() async {
    emit(const ProjectsLoading());
    _emitResult(await _useCase.getAll());
  }

  Future<void> _save(PersonalProject project) async {
    _emitResult(await _useCase.upsert(project));
  }

  Future<void> _delete(String id) async {
    _emitResult(await _useCase.delete(id));
  }

  Future<void> _reorder(List<PersonalProject> projects) async {
    _emitResult(await _useCase.saveAll(projects));
  }

  void _emitResult(DataResult<List<PersonalProject>> result) {
    switch (result) {
      case Success<List<PersonalProject>>():
        projects = result.data;
        emit(ProjectsSuccess(projects));
      case Fail<List<PersonalProject>>():
        emit(ProjectsError(result.message));
    }
  }
}
