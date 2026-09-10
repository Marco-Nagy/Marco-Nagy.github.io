import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/common/data_result.dart';
import '../../../portfolio_content/domain/entities/pricing_add_on.dart';
import '../../../portfolio_content/domain/entities/pricing_package.dart';
import '../../../portfolio_content/domain/entities/quote_selection.dart';
import '../../../portfolio_content/domain/use_cases/pricing_use_case.dart';
import 'pricing_actions.dart';
import 'pricing_states.dart';

@injectable
class PricingViewModelCubit extends Cubit<PricingState> {
  PricingViewModelCubit(this._useCase) : super(const PricingInitial());

  final PricingUseCase _useCase;

  List<PricingPackage> packages = <PricingPackage>[];
  List<PricingAddOn> addOns = <PricingAddOn>[];
  QuoteSelection selection = const QuoteSelection();

  void doAction(PricingActions action) {
    switch (action) {
      case LoadPricing():
        _load();
      case SelectPackage():
        _update(selection.copyWith(package: action.package));
      case ToggleAddOn():
        _toggleAddOn(action.addOnId);
      case ChangeAddOnQuantity():
        _setQuantity(action.addOnId, action.quantity);
      case ResetQuote():
        _update(const QuoteSelection());
      case SavePackage():
        _savePackage(action.package);
      case DeletePackage():
        _deletePackage(action.id);
      case SaveAddOn():
        _saveAddOn(action.addOn);
      case DeleteAddOn():
        _deleteAddOn(action.id);
      case ReorderPackages():
        _reorderPackages(action.packages);
      case ReorderAddOns():
        _reorderAddOns(action.addOns);
    }
  }

  Future<void> _load() async {
    emit(const PricingLoading());

    final packagesResult = await _useCase.getPackages();
    if (packagesResult case Fail<List<PricingPackage>>(:final message)) {
      emit(PricingError(message));
      return;
    }
    final addOnsResult = await _useCase.getAddOns();
    if (addOnsResult case Fail<List<PricingAddOn>>(:final message)) {
      emit(PricingError(message));
      return;
    }

    packages = (packagesResult as Success<List<PricingPackage>>).data;
    addOns = (addOnsResult as Success<List<PricingAddOn>>).data;

    // Preselect the first package so the total is never a meaningless zero.
    selection = QuoteSelection(
      package: packages.isEmpty ? null : packages.first,
    );
    _emitReady();
  }

  void _toggleAddOn(String addOnId) {
    final next = Map<String, int>.of(selection.quantities);
    if (selection.isSelected(addOnId)) {
      next.remove(addOnId);
    } else {
      next[addOnId] = 1;
    }
    _update(selection.copyWith(quantities: next));
  }

  void _setQuantity(String addOnId, int quantity) {
    final next = Map<String, int>.of(selection.quantities);
    if (quantity <= 0) {
      next.remove(addOnId);
    } else {
      next[addOnId] = quantity;
    }
    _update(selection.copyWith(quantities: next));
  }

  void _update(QuoteSelection next) {
    selection = next;
    _emitReady();
  }

  Future<void> _savePackage(PricingPackage package) async {
    switch (await _useCase.upsertPackage(package)) {
      case Success<List<PricingPackage>>(:final data):
        packages = data;
        _emitReady();
      case Fail<List<PricingPackage>>(:final message):
        emit(PricingError(message));
    }
  }

  Future<void> _deletePackage(String id) async {
    switch (await _useCase.deletePackage(id)) {
      case Success<List<PricingPackage>>(:final data):
        packages = data;
        // Drop the selection if the selected package just disappeared.
        if (selection.package != null &&
            !data.any((p) => p.id == selection.package!.id)) {
          selection = selection.copyWith(clearPackage: true);
        }
        _emitReady();
      case Fail<List<PricingPackage>>(:final message):
        emit(PricingError(message));
    }
  }

  Future<void> _saveAddOn(PricingAddOn addOn) async {
    switch (await _useCase.upsertAddOn(addOn)) {
      case Success<List<PricingAddOn>>(:final data):
        addOns = data;
        _emitReady();
      case Fail<List<PricingAddOn>>(:final message):
        emit(PricingError(message));
    }
  }

  Future<void> _deleteAddOn(String id) async {
    switch (await _useCase.deleteAddOn(id)) {
      case Success<List<PricingAddOn>>(:final data):
        addOns = data;
        // Clear any quantity held against the removed add-on.
        final next = Map<String, int>.of(selection.quantities)..remove(id);
        selection = selection.copyWith(quantities: next);
        _emitReady();
      case Fail<List<PricingAddOn>>(:final message):
        emit(PricingError(message));
    }
  }

  Future<void> _reorderPackages(List<PricingPackage> packages) async {
    switch (await _useCase.saveAllPackages(packages)) {
      case Success<List<PricingPackage>>(:final data):
        this.packages = data;
        _emitReady();
      case Fail<List<PricingPackage>>(:final message):
        emit(PricingError(message));
    }
  }

  Future<void> _reorderAddOns(List<PricingAddOn> addOns) async {
    switch (await _useCase.saveAllAddOns(addOns)) {
      case Success<List<PricingAddOn>>(:final data):
        this.addOns = data;
        _emitReady();
      case Fail<List<PricingAddOn>>(:final message):
        emit(PricingError(message));
    }
  }

  void _emitReady() {
    emit(
      PricingReady(packages: packages, addOns: addOns, selection: selection),
    );
  }
}
