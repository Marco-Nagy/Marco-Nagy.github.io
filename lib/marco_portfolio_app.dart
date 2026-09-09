import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/app_cubit/app_actions.dart';
import 'core/app_cubit/app_cubit.dart';
import 'core/app_cubit/app_state.dart';
import 'core/localization/app_localizations_setup.dart';
import 'core/localization/lang_keys.dart';
import 'core/routes/app_route_observer.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/route_names.dart';
import 'core/styles/theme/app_theme.dart';
import 'core/utils/extension/context_extensions.dart';
import 'core/utils/responsive/app_breakpoints.dart';
import 'di/di.dart';

class MarcoPortfolioApp extends StatelessWidget {
  const MarcoPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppCubit>(
      // Language lives above MaterialApp: the nav toggle on every page reads it.
      create: (_) => getIt<AppCubit>()..doAction(LoadSavedLanguage()),
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          final locale = context.read<AppCubit>().locale;

          // The design size is chosen from the real window width before
          // ScreenUtil initialises. A fixed phone design size would scale
          // everything ~4.9x on a 1920px window and overflow every row.
          return LayoutBuilder(
            builder: (context, constraints) {
              return ScreenUtilInit(
                designSize: AppBreakpoints.designSizeOf(constraints.maxWidth),
                minTextAdapt: true,
                splitScreenMode: true,
                builder: (context, child) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    // Runs with a localized context, so the browser tab title
                    // follows the selected language.
                    onGenerateTitle: (context) =>
                        context.translate(LangKeys.appTitle),
                    theme: AppTheme.navy(),
                    locale: locale,
                    supportedLocales: AppLocalizationsSetup.supportedLocales,
                    localizationsDelegates:
                        AppLocalizationsSetup.localizationsDelegates,
                    localeResolutionCallback:
                        AppLocalizationsSetup.localeResolutionCallback,
                    initialRoute: RouteNames.splash,
                    onGenerateRoute: AppRoutes.onGenerateRoute,
                    navigatorObservers: <NavigatorObserver>[appRouteObserver],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
