import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/common/data_result.dart';
import '../../domain/entities/section_definition.dart';
import '../../domain/use_cases/sections_use_case.dart';
import 'sections_actions.dart';
import 'sections_states.dart';

/// Owns the nav: which sections exist, what they are called, and in what order.
///
/// App-wide for the same reason as `SiteContentCubit` — the top nav and the
/// mobile drawer sit in `PortfolioScaffold`, under every screen's provider.
@injectable
class SectionsCubit extends Cubit<SectionsState> {
  SectionsCubit(this._useCase) : super(const SectionsInitial());

  final SectionsUseCase _useCase;

  /// Empty until the first read lands, which means the nav renders no links
  /// for at most one frame rather than a placeholder row that would then
  /// shuffle. A hardcoded default list is deliberately not used: that is the
  /// seed constant Phase 1 deleted.
  List<SectionDefinition> sections = <SectionDefinition>[];

  /// What the nav actually renders: hidden sections dropped, `order` applied.
  ///
  /// Sorted here rather than trusting the stored order, because a section
  /// saved through the admin can carry any integer and two can collide.
  List<SectionDefinition> get visible {
    final result = sections.where((s) => s.visible).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return List<SectionDefinition>.unmodifiable(result);
  }

  /// The section with [id], or null when it has been deleted or hidden.
  SectionDefinition? byId(String id) {
    for (final section in sections) {
      if (section.id == id) return section;
    }
    return null;
  }

  void doAction(SectionsActions action) {
    switch (action) {
      case LoadSections():
        _run(_useCase.getAll());
      case SaveSection():
        _run(_useCase.upsert(action.section));
      case SaveAllSections():
        _run(_useCase.saveAll(action.sections));
      case DeleteCustomSection():
        _run(_useCase.deleteCustom(action.id));
    }
  }

  Future<void> _run(
    Future<DataResult<List<SectionDefinition>>> operation,
  ) async {
    final result = await operation;
    switch (result) {
      case Success<List<SectionDefinition>>():
        sections = result.data;
        emit(SectionsReady(sections));
      case Fail<List<SectionDefinition>>():
        emit(SectionsFailure(result.message));
    }
  }
}
