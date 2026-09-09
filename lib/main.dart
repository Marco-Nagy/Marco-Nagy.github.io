import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/services/shared_preference/shared_preference_helper.dart';
import 'di/di.dart';
import 'features/portfolio_content/data/data_sources/portfolio_local_data_source.dart';
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

  // Seeds on first launch only; later launches respect whatever is stored,
  // including content deleted in debug.
  await getIt<PortfolioLocalDataSource>().seedIfEmpty();

  runApp(const MarcoPortfolioApp());
}
