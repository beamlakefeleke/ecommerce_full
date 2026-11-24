import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/common/models/config_model.dart';
import 'package:ecommerce/common/models/module_model.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/splash/domain/repositories/splash_repository.dart';
import 'package:ecommerce/features/splash/domain/usecases/splash_usecases.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_event.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_state.dart';

/// App-wide bloc: [SplashState.configModel] and [SplashState.module] are read
/// across all features. Input is only via `add(Event)`; no navigation /
/// snackbars inside the bloc — the UI / main.dart reacts to state via
/// [BlocConsumer]/[BlocListener].
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetConfigDataUseCase getConfigData;
  final GetModulesUseCase getModules;
  final SubscribeEmailUseCase subscribeEmail;
  final SplashRepository repository;

  SplashBloc({
    required this.getConfigData,
    required this.getModules,
    required this.subscribeEmail,
    required this.repository,
  }) : super(const SplashState()) {
    on<SplashSharedDataInitialized>(_onSharedDataInitialized);
    on<SplashConfigRequested>(_onConfigRequested);
    on<SplashLandingPageRequested>(_onLandingPageRequested);
    on<SplashModuleSet>(_onModuleSet);
    on<SplashModulesRequested>(_onModulesRequested);
    on<SplashModuleIndexSelected>(_onModuleIndexSelected);
    on<SplashModuleSwitched>(_onModuleSwitched);
    on<SplashModuleRemoved>(_onModuleRemoved);
    on<SplashIntroDismissed>(_onIntroDismissed);
    on<SplashFirstConnectionCheckDone>(_onFirstConnectionCheckDone);
    on<SplashRefreshingSet>(_onRefreshingSet);
    on<SplashEmailSubscribed>(_onEmailSubscribed);
    on<SplashCookiesSaved>(_onCookiesSaved);
    on<SplashWebSuggestedLocationSaved>(_onWebSuggestedLocationSaved);
  }

  Future<void> _onSharedDataInitialized(
    SplashSharedDataInitialized event,
    Emitter<SplashState> emit,
  ) async {
    final module = await repository.initSharedData();
    final cacheModule = repository.getCacheModule();
    emit(state.copyWith(module: module, cacheModule: cacheModule));
    if (module != null) {
      await _applyModule(module, emit);
    }
  }

  Future<void> _onConfigRequested(
    SplashConfigRequested event,
    Emitter<SplashState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SplashConfigStatus.loading,
        hasConnection: true,
        moduleIndex: 0,
      ),
    );
    final result = await getConfigData(const NoParams());
    await result.fold(
      (failure) async {
        final noConnection =
            failure.message == ApiClient.noInternetMessage;
        emit(
          state.copyWith(
            status: SplashConfigStatus.error,
            hasConnection: !noConnection,
            errorMessage: failure.message,
          ),
        );
      },
      (configResult) async {
        ConfigModel config = configResult.configModel;
        // Resolve module config section.
        ModuleModel? resolvedModule = state.module;
        if (config.module != null) {
          resolvedModule = config.module;
        }
        if (resolvedModule != null) {
          config = _applyModuleConfig(config, configResult.rawData, resolvedModule);
        }
        emit(
          state.copyWith(
            status: SplashConfigStatus.loaded,
            configModel: config,
            rawData: configResult.rawData,
          ),
        );
        if (resolvedModule != null && resolvedModule != state.module) {
          add(SplashModuleSet(resolvedModule));
        }
        if (event.loadLandingData) {
          add(const SplashLandingPageRequested());
        }
      },
    );
  }

  Future<void> _onLandingPageRequested(
    SplashLandingPageRequested event,
    Emitter<SplashState> emit,
  ) async {
    final landing = await repository.getLandingPageData();
    if (landing != null) {
      emit(state.copyWith(landingModel: landing));
    }
  }

  Future<void> _onModuleSet(
    SplashModuleSet event,
    Emitter<SplashState> emit,
  ) async {
    final module = event.module;
    await repository.setModule(module);
    ConfigModel? updatedConfig = state.configModel;
    if (module != null && updatedConfig != null) {
      updatedConfig = _applyModuleConfig(updatedConfig, state.rawData, module);
    }
    await repository.setCacheModule(module);
    emit(
      state.copyWith(
        module: module,
        clearModule: module == null,
        configModel: updatedConfig,
      ),
    );
  }

  Future<void> _onModulesRequested(
    SplashModulesRequested event,
    Emitter<SplashState> emit,
  ) async {
    emit(state.copyWith(moduleIndex: 0));
    final result = await getModules(event.headers);
    result.fold(
      (_) {},
      (list) => emit(state.copyWith(moduleList: list)),
    );
  }

  void _onModuleIndexSelected(
    SplashModuleIndexSelected event,
    Emitter<SplashState> emit,
  ) {
    emit(state.copyWith(selectedModuleIndex: event.index));
  }

  Future<void> _onModuleSwitched(
    SplashModuleSwitched event,
    Emitter<SplashState> emit,
  ) async {
    final modules = state.moduleList;
    if (modules == null || event.moduleListIndex >= modules.length) return;
    final target = modules[event.moduleListIndex];
    if (state.module?.id == target.id) return;
    add(SplashModuleSet(target));
  }

  void _onModuleRemoved(
    SplashModuleRemoved event,
    Emitter<SplashState> emit,
  ) {
    add(const SplashModuleSet(null));
  }

  void _onIntroDismissed(
    SplashIntroDismissed event,
    Emitter<SplashState> emit,
  ) {
    repository.disableIntro();
  }

  void _onFirstConnectionCheckDone(
    SplashFirstConnectionCheckDone event,
    Emitter<SplashState> emit,
  ) {
    emit(state.copyWith(firstTimeConnectionCheck: false));
  }

  void _onRefreshingSet(
    SplashRefreshingSet event,
    Emitter<SplashState> emit,
  ) {
    emit(state.copyWith(isRefreshing: event.status));
  }

  Future<void> _onEmailSubscribed(
    SplashEmailSubscribed event,
    Emitter<SplashState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, actionStatus: SplashActionStatus.inProgress));
    final result = await subscribeEmail(event.email);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          actionStatus: SplashActionStatus.failure,
          actionMessage: failure.message,
        ),
      ),
      (response) => emit(
        state.copyWith(
          isLoading: false,
          actionStatus: response.isSuccess
              ? SplashActionStatus.success
              : SplashActionStatus.failure,
          actionMessage: response.message,
        ),
      ),
    );
  }

  void _onCookiesSaved(
    SplashCookiesSaved event,
    Emitter<SplashState> emit,
  ) {
    repository.saveCookiesData(event.data);
    emit(state.copyWith(savedCookiesData: true));
  }

  void _onWebSuggestedLocationSaved(
    SplashWebSuggestedLocationSaved event,
    Emitter<SplashState> emit,
  ) {
    repository.saveSuggestedLocationStatus(event.data);
    emit(state.copyWith(webSuggestedLocation: true));
  }

  // ---- Helpers ----

  /// Applies the module-type-specific module config section to [config].
  ConfigModel _applyModuleConfig(
    ConfigModel config,
    Map<String, dynamic> rawData,
    ModuleModel module,
  ) {
    try {
      if (rawData.containsKey('module_config') &&
          rawData['module_config'] != null) {
        final moduleConfigMap =
            rawData['module_config'] as Map<String, dynamic>;
        if (moduleConfigMap.containsKey(module.moduleType)) {
          config.moduleConfig?.module = Module.fromJson(
            moduleConfigMap[module.moduleType],
          );
        }
      }
    } catch (_) {}
    return config;
  }

  Future<void> _applyModule(
    ModuleModel module,
    Emitter<SplashState> emit,
  ) async {
    await repository.setModule(module);
    final config = state.configModel;
    if (config != null) {
      _applyModuleConfig(config, state.rawData, module);
      emit(state.copyWith(configModel: config, module: module));
    }
  }

  // ---- Public synchronous accessors (bridging legacy callers via getIt) ----

  /// Whether [showIntro] returns true (kept synchronous for the splash screen).
  bool? showIntro() => repository.showIntro();

  Module? getModuleConfig(String? moduleType) {
    if (moduleType == null || state.rawData.isEmpty) return null;
    try {
      final m = Module.fromJson(state.rawData['module_config'][moduleType]);
      if (moduleType == 'food') m.newVariation = true;
      return m;
    } catch (_) {
      return null;
    }
  }

  int getCacheModuleId() => repository.getCacheModule()?.id ?? 0;

  bool getSavedCookiesData() => repository.getSavedCookiesData();
  void cookiesStatusChange(String? data) =>
      repository.cookiesStatusChange(data);
  bool getAcceptCookiesStatus(String data) =>
      repository.getAcceptCookiesStatus(data);
  bool getSuggestedLocationStatus() => repository.getSuggestedLocationStatus();
}
