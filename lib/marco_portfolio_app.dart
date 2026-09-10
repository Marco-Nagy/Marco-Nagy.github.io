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
import 'features/experience/presentation/view_model/experience_actions.dart';
import 'features/experience/presentation/view_model/experience_view_model.dart';
import 'features/portfolio_content/presentation/view_model/sections_actions.dart';
import 'features/portfolio_content/presentation/view_model/sections_view_model.dart';
import 'features/portfolio_content/presentation/view_model/site_content_actions.dart';
import 'features/portfolio_content/presentation/view_model/site_content_view_model.dart';
import 'features/portfolio_content/presentation/view_model/skills_actions.dart';
import 'features/portfolio_content/presentation/view_model/skills_view_model.dart';

class MarcoPortfolioApp extends StatelessWidget {
  const MarcoPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // All five live above MaterialApp. Language, because the nav toggle on
      // every page reads it; the content cubits, because the nav bar, drawer
      // and footer live in PortfolioScaffold — below every screen's own
      // provider, and therefore out of reach of a per-screen one. Experience
      // joined this set so About's computed years-of-experience stat can
      // read work history without the Experience section having loaded yet.
      //
      // Each load is dispatched at creation rather than from a screen's
      // initState, so the read is already in flight before the first frame.
      // main() awaits syncFromRemote() before runApp, so these reads hit a
      // warm cache and resolve in a microtask — chrome paints its defaults for
      // at most one frame.
      providers: <BlocProvider<dynamic>>[
        BlocProvider<AppCubit>(
          create: (_) => getIt<AppCubit>()..doAction(LoadSavedLanguage()),
        ),
        BlocProvider<SiteContentCubit>(
          create: (_) => getIt<SiteContentCubit>()..doAction(LoadSiteContent()),
        ),
        BlocProvider<SectionsCubit>(
          create: (_) => getIt<SectionsCubit>()..doAction(LoadSections()),
        ),
        BlocProvider<SkillsCubit>(
          create: (_) => getIt<SkillsCubit>()..doAction(LoadSkills()),
        ),
        BlocProvider<ExperienceViewModelCubit>(
          create: (_) =>
              getIt<ExperienceViewModelCubit>()..doAction(LoadWorkHistory()),
        ),
      ],
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          final locale = context.read<AppCubit>().locale;

          // The design size is chosen from the real window width before
          // ScreenUtil initialises. A fixed phone design size would scale
          // everything ~4.9x on a 1920px window and overflow every row.
          //
          // Read from the view's MediaQuery — the one `View` installs above
          // this widget — and deliberately NOT from a LayoutBuilder. A
          // LayoutBuilder here would build MaterialApp, and with it the
          // Navigator and its Overlay, from inside a layout callback: every
          // resize would then reparent overlay entries (each Tooltip is one)
          // during layout, and `Overlay._addDeferredChild` would mark a
          // render object outside the current layout scope as needing layout.
          // That is the "_RenderLayoutBuilder was mutated in
          // _RenderLayoutBuilder.performLayout" assertion. MediaQuery gives
          // the same width one phase earlier, during build, where rebuilding
          // the app subtree is legal.
          final designSize = AppBreakpoints.designSizeOf(
            MediaQuery.sizeOf(context).width,
          );

          return ScreenUtilInit(
            designSize: designSize,
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
      ),
    );
  }
}
