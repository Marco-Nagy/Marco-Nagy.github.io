import '../../../portfolio_content/domain/entities/certificate.dart';

sealed class CertificatesActions {}

class LoadCertificates extends CertificatesActions {}

/// Debug-only: create or update a certificate.
class SaveCertificate extends CertificatesActions {
  SaveCertificate(this.certificate);
  final Certificate certificate;
}

/// Debug-only: remove a certificate.
class DeleteCertificate extends CertificatesActions {
  DeleteCertificate(this.id);
  final String id;
}

/// Debug-only: persist a whole reordered list in one write.
class ReorderCertificates extends CertificatesActions {
  ReorderCertificates(this.certificates);
  final List<Certificate> certificates;
}
