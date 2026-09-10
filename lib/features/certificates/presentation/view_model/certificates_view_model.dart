import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/common/data_result.dart';
import '../../../portfolio_content/domain/entities/certificate.dart';
import '../../../portfolio_content/domain/use_cases/certificates_use_case.dart';
import 'certificates_actions.dart';
import 'certificates_states.dart';

@injectable
class CertificatesViewModelCubit extends Cubit<CertificatesState> {
  CertificatesViewModelCubit(this._useCase)
    : super(const CertificatesInitial());

  final CertificatesUseCase _useCase;

  List<Certificate> certificates = <Certificate>[];

  void doAction(CertificatesActions action) {
    switch (action) {
      case LoadCertificates():
        _load();
      case SaveCertificate():
        _save(action.certificate);
      case DeleteCertificate():
        _delete(action.id);
      case ReorderCertificates():
        _reorder(action.certificates);
    }
  }

  Future<void> _load() async {
    emit(const CertificatesLoading());
    _emitResult(await _useCase.getAll());
  }

  Future<void> _save(Certificate certificate) async {
    _emitResult(await _useCase.upsert(certificate));
  }

  Future<void> _delete(String id) async {
    _emitResult(await _useCase.delete(id));
  }

  Future<void> _reorder(List<Certificate> certificates) async {
    _emitResult(await _useCase.saveAll(certificates));
  }

  void _emitResult(DataResult<List<Certificate>> result) {
    switch (result) {
      case Success<List<Certificate>>():
        certificates = result.data;
        emit(CertificatesSuccess(certificates));
      case Fail<List<Certificate>>():
        emit(CertificatesError(result.message));
    }
  }
}
