import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/common/data_result.dart';
import '../../domain/entities/skill_group_entity.dart';
import '../../domain/entities/tech_badge_entity.dart';
import '../../domain/use_cases/skills_use_case.dart';
import 'skills_actions.dart';
import 'skills_states.dart';

/// Owns both skill collections: the grouped chips in About and the badges
/// orbiting the hero photo.
///
/// App-wide beside the other two content cubits. Those two are app-wide because
/// chrome needs them; this one is app-wide because its two consumers sit on
/// different screens, and a per-screen provider would refetch on every nav.
@injectable
class SkillsCubit extends Cubit<SkillsState> {
  SkillsCubit(this._useCase) : super(const SkillsInitial());

  final SkillsUseCase _useCase;

  List<SkillGroupEntity> groups = <SkillGroupEntity>[];
  List<TechBadgeEntity> badges = <TechBadgeEntity>[];

  /// Both getters sort by `order` rather than trusting insertion order, for
  /// the same reason `SectionsCubit.visible` does.
  List<SkillGroupEntity> get orderedGroups {
    final result = groups.toList()..sort((a, b) => a.order.compareTo(b.order));
    return List<SkillGroupEntity>.unmodifiable(result);
  }

  List<TechBadgeEntity> get orderedBadges {
    final result = badges.toList()..sort((a, b) => a.order.compareTo(b.order));
    return List<TechBadgeEntity>.unmodifiable(result);
  }

  void doAction(SkillsActions action) {
    switch (action) {
      case LoadSkills():
        _load();
      case SaveSkillGroup():
        _runGroups(_useCase.upsertGroup(action.group));
      case DeleteSkillGroup():
        _runGroups(_useCase.deleteGroup(action.id));
      case SaveTechBadge():
        _runBadges(_useCase.upsertBadge(action.badge));
      case DeleteTechBadge():
        _runBadges(_useCase.deleteBadge(action.id));
    }
  }

  Future<void> _load() async {
    final groupsResult = await _useCase.getGroups();
    final badgesResult = await _useCase.getBadges();

    // One failure must not blank the collection that did load, so each side is
    // applied independently and only the failure is reported.
    final failure =
        _apply(groupsResult, _setGroups) ?? _apply(badgesResult, _setBadges);
    if (failure != null) {
      emit(SkillsFailure(failure));
      return;
    }
    _emitReady();
  }

  Future<void> _runGroups(
    Future<DataResult<List<SkillGroupEntity>>> operation,
  ) async {
    final failure = _apply(await operation, _setGroups);
    failure == null ? _emitReady() : emit(SkillsFailure(failure));
  }

  Future<void> _runBadges(
    Future<DataResult<List<TechBadgeEntity>>> operation,
  ) async {
    final failure = _apply(await operation, _setBadges);
    failure == null ? _emitReady() : emit(SkillsFailure(failure));
  }

  /// Writes [result] through [assign] and returns the failure message, or null
  /// when it succeeded.
  String? _apply<T>(DataResult<T> result, void Function(T) assign) {
    switch (result) {
      case Success<T>():
        assign(result.data);
        return null;
      case Fail<T>():
        return result.message;
    }
  }

  void _setGroups(List<SkillGroupEntity> value) => groups = value;
  void _setBadges(List<TechBadgeEntity> value) => badges = value;

  void _emitReady() => emit(SkillsReady(groups: groups, badges: badges));
}
