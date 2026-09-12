/// Every asset path in one place — no raw asset strings in widgets.
///
/// Only two entries left, and deliberately so: project media now lives on
/// Cloudinary with its URL stored in Firestore, so there is nothing for a
/// hardcoded `assets/projects/...` list to point at. The three that used to
/// sit here (`floweryStoreShots`, `floweryDeliveryShots`, `fitnessAppShots`)
/// named nine files that were never in the repo at all — they logged a 404
/// each on every web run and had no call sites.
class AppImages {
  const AppImages._();

  static const String profile = 'assets/images/profile.png';
  static const String cvPdf = 'assets/cv/marco_nagy_cv.pdf';
}
