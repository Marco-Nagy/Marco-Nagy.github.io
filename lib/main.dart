import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/services/shared_preference/shared_preference_helper.dart';
import 'di/di.dart';
import 'features/portfolio_content/domain/repositories/portfolio_repo.dart';
import 'firebase_options.dart';
import 'marco_portfolio_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preferences must be ready before DI, because the data source reads from
  // them synchronously the moment a cubit is created.
  await SharedPrefHelper().instantiatePreferences();

  // Firebase is the content source, but never a reason the site fails to
  // open. A visitor whose network or region blocks Firestore still gets the
  // cached bundle, so initialisation failure is logged and stepped over
  // rather than thrown — the read path already treats "no remote" as a
  // normal, expected state.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on Object catch (error, stack) {
    debugPrint('Firebase init failed, continuing from cache: $error');
    debugPrintStack(stackTrace: stack);
  }

  configureDependencies();

  // One Firestore read, before the first frame: compares the published
  // content version against the cached one and pulls the bundle only when it
  // differs. Awaited rather than fired off, so the app never paints stale
  // content and then jumps. It cannot throw a visitor-facing failure —
  // unreachable, unpublished and stale all resolve to "render what we have".
  await getIt<PortfolioRepo>().syncFromRemote();

  runApp(const MarcoPortfolioApp());
}
