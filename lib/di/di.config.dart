// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:image_picker/image_picker.dart' as _i183;
import 'package:injectable/injectable.dart' as _i526;

import '../core/app_cubit/app_cubit.dart' as _i693;
import '../core/services/media/image_picker_service.dart' as _i809;
import '../core/services/shared_preference/shared_preference_helper.dart'
    as _i668;
import '../features/certificates/presentation/view_model/certificates_view_model.dart'
    as _i337;
import '../features/experience/presentation/view_model/experience_view_model.dart'
    as _i866;
import '../features/portfolio_content/data/data_sources/portfolio_local_data_source.dart'
    as _i275;
import '../features/portfolio_content/data/data_sources/portfolio_local_data_source_impl.dart'
    as _i420;
import '../features/portfolio_content/data/repositories/portfolio_repo_impl.dart'
    as _i432;
import '../features/portfolio_content/domain/repositories/portfolio_repo.dart'
    as _i1023;
import '../features/portfolio_content/domain/use_cases/certificates_use_case.dart'
    as _i478;
import '../features/portfolio_content/domain/use_cases/custom_section_use_case.dart'
    as _i104;
import '../features/portfolio_content/domain/use_cases/pricing_use_case.dart'
    as _i249;
import '../features/portfolio_content/domain/use_cases/projects_use_case.dart'
    as _i137;
import '../features/portfolio_content/domain/use_cases/sections_use_case.dart'
    as _i635;
import '../features/portfolio_content/domain/use_cases/site_content_use_case.dart'
    as _i520;
import '../features/portfolio_content/domain/use_cases/skills_use_case.dart'
    as _i1046;
import '../features/portfolio_content/domain/use_cases/work_history_use_case.dart'
    as _i1028;
import '../features/pricing/presentation/view_model/pricing_view_model.dart'
    as _i53;
import '../features/projects/presentation/view_model/projects_view_model.dart'
    as _i560;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i668.SharedPrefHelper>(
      () => registerModule.sharedPrefHelper,
    );
    gh.lazySingleton<_i183.ImagePicker>(() => registerModule.imagePicker);
    gh.factory<_i693.AppCubit>(
      () => _i693.AppCubit(gh<_i668.SharedPrefHelper>()),
    );
    gh.lazySingleton<_i275.PortfolioLocalDataSource>(
      () => _i420.PortfolioLocalDataSourceImpl(gh<_i668.SharedPrefHelper>()),
    );
    gh.lazySingleton<_i809.ImagePickerService>(
      () => _i809.ImagePickerService(gh<_i183.ImagePicker>()),
    );
    gh.lazySingleton<_i1023.PortfolioRepo>(
      () => _i432.PortfolioRepoImpl(gh<_i275.PortfolioLocalDataSource>()),
    );
    gh.factory<_i478.CertificatesUseCase>(
      () => _i478.CertificatesUseCase(gh<_i1023.PortfolioRepo>()),
    );
    gh.factory<_i104.CustomSectionUseCase>(
      () => _i104.CustomSectionUseCase(gh<_i1023.PortfolioRepo>()),
    );
    gh.factory<_i249.PricingUseCase>(
      () => _i249.PricingUseCase(gh<_i1023.PortfolioRepo>()),
    );
    gh.factory<_i137.ProjectsUseCase>(
      () => _i137.ProjectsUseCase(gh<_i1023.PortfolioRepo>()),
    );
    gh.factory<_i635.SectionsUseCase>(
      () => _i635.SectionsUseCase(gh<_i1023.PortfolioRepo>()),
    );
    gh.factory<_i520.SiteContentUseCase>(
      () => _i520.SiteContentUseCase(gh<_i1023.PortfolioRepo>()),
    );
    gh.factory<_i1046.SkillsUseCase>(
      () => _i1046.SkillsUseCase(gh<_i1023.PortfolioRepo>()),
    );
    gh.factory<_i1028.WorkHistoryUseCase>(
      () => _i1028.WorkHistoryUseCase(gh<_i1023.PortfolioRepo>()),
    );
    gh.factory<_i560.ProjectsViewModelCubit>(
      () => _i560.ProjectsViewModelCubit(gh<_i137.ProjectsUseCase>()),
    );
    gh.factory<_i53.PricingViewModelCubit>(
      () => _i53.PricingViewModelCubit(gh<_i249.PricingUseCase>()),
    );
    gh.factory<_i866.ExperienceViewModelCubit>(
      () => _i866.ExperienceViewModelCubit(gh<_i1028.WorkHistoryUseCase>()),
    );
    gh.factory<_i337.CertificatesViewModelCubit>(
      () => _i337.CertificatesViewModelCubit(gh<_i478.CertificatesUseCase>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
