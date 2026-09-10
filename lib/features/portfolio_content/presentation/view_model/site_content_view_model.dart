import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/common/data_result.dart';
import '../../domain/entities/site_content.dart';
import '../../domain/use_cases/site_content_use_case.dart';
import 'site_content_actions.dart';
import 'site_content_states.dart';

/// Owns the site-wide singleton copy: identity, hero, about, contact, footer.
///
/// Provided above `MaterialApp` rather than per screen, because the nav bar and
/// the footer live in `PortfolioScaffold` — below every screen's own provider
/// and therefore out of reach of one.
@injectable
class SiteContentCubit extends Cubit<SiteContentState> {
  SiteContentCubit(this._useCase) : super(const SiteContentInitial());

  final SiteContentUseCase _useCase;

  /// Never null, and only ever moves forward: a failed read leaves the last
  /// good value in place. Starts at the entity's own defaults, which is what
  /// the first frame paints if it beats the cache read — a frame of `MN` with
  /// blank copy, never a spinner and never an error.
  SiteContent content = const SiteContent();

  void doAction(SiteContentActions action) {
    switch (action) {
      case LoadSiteContent():
        _load();
      case SaveSiteContent():
        _save(action.content);
    }
  }

  Future<void> _load() async => _emitResult(await _useCase.get());

  Future<void> _save(SiteContent content) async =>
      _emitResult(await _useCase.save(content));

  void _emitResult(DataResult<SiteContent> result) {
    switch (result) {
      case Success<SiteContent>():
        content = result.data;
        emit(SiteContentReady(content));
      case Fail<SiteContent>():
        emit(SiteContentFailure(result.message));
    }
  }
}
