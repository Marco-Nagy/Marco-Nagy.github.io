import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/common/data_result.dart';
import '../../../portfolio_content/domain/entities/work_history_entry.dart';
import '../../../portfolio_content/domain/use_cases/work_history_use_case.dart';
import 'experience_actions.dart';
import 'experience_states.dart';

@injectable
class ExperienceViewModelCubit extends Cubit<ExperienceState> {
  ExperienceViewModelCubit(this._useCase) : super(const ExperienceInitial());

  final WorkHistoryUseCase _useCase;

  List<WorkHistoryEntry> entries = <WorkHistoryEntry>[];

  void doAction(ExperienceActions action) {
    switch (action) {
      case LoadWorkHistory():
        _load();
      case SaveWorkHistory():
        _save(action.entry);
      case DeleteWorkHistory():
        _delete(action.id);
      case ReorderWorkHistory():
        _reorder(action.entries);
    }
  }

  Future<void> _load() async {
    emit(const ExperienceLoading());
    _emitResult(await _useCase.getAll());
  }

  Future<void> _save(WorkHistoryEntry entry) async {
    _emitResult(await _useCase.upsert(entry));
  }

  Future<void> _delete(String id) async {
    _emitResult(await _useCase.delete(id));
  }

  Future<void> _reorder(List<WorkHistoryEntry> entries) async {
    _emitResult(await _useCase.saveAll(entries));
  }

  void _emitResult(DataResult<List<WorkHistoryEntry>> result) {
    switch (result) {
      case Success<List<WorkHistoryEntry>>():
        entries = result.data;
        emit(ExperienceSuccess(entries));
      case Fail<List<WorkHistoryEntry>>():
        emit(ExperienceError(result.message));
    }
  }
}
