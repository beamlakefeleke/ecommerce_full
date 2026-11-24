import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/common/models/module_model.dart';
import 'package:ecommerce/common/models/config_model.dart';

class ModuleHelper {
  static ModuleModel? getModule() {
    return getIt<SplashBloc>().state.module;
  }

  static ModuleModel? getCacheModule() {
    return getIt<SplashBloc>().state.cacheModule;
  }

  static Module? getModuleConfig(String? moduleType) {
    return getIt<SplashBloc>().getModuleConfig(moduleType);
  }
}
