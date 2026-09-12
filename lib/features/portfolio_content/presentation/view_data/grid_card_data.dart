import '../../domain/entities/certificate.dart';
import '../../domain/entities/custom_section_item.dart';
import '../../domain/entities/image_ref.dart';
import 'localized_pick.dart';

/// One card in a two-column image grid — a certificate scan, or a generated
/// certificate-styled card when no scan exists.
class GridCardData {
  const GridCardData({
    required this.id,
    required this.title,
    this.provider = '',
    this.year = '',
    this.location = '',
    this.image = const ImageRef(),
  });

  final String id;
  final String title;
  final String provider;
  final String year;
  final String location;
  final ImageRef image;

  bool get hasImage => !image.isEmpty;

  factory GridCardData.fromCertificate(Certificate certificate, bool isArabic) {
    return GridCardData(
      id: certificate.id,
      title: pickText(isArabic, certificate.title, certificate.titleAr),
      provider: pickText(
        isArabic,
        certificate.provider,
        certificate.providerAr,
      ),
      year: certificate.year,
      location: pickText(
        isArabic,
        certificate.location,
        certificate.locationAr,
      ),
      image: ImageRef.fromSource(certificate.imageAsset),
    );
  }

  factory GridCardData.fromCustomItem(CustomSectionItem item, bool isArabic) {
    return GridCardData(
      id: item.id,
      title: pickText(isArabic, item.titleEn, item.titleAr),
      provider: pickText(isArabic, item.subtitleEn, item.subtitleAr),
      year: item.year,
      location: pickText(isArabic, item.tagEn, item.tagAr),
      image: item.images.isEmpty ? const ImageRef() : item.images.first,
    );
  }
}
