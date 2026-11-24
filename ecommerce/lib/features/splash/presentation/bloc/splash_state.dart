import 'package:equatable/equatable.dart';
import 'package:ecommerce/common/models/config_model.dart';
import 'package:ecommerce/common/models/module_model.dart';
import 'package:ecommerce/features/splash/domain/models/landing_model.dart';

enum SplashConfigStatus { initial, loading, loaded, error }

/// One-shot action outcome (subscribe email).
enum SplashActionStatus { none, inProgress, success, failure }

/// Single immutable state. All app-wide config data coexists here (rule 6).
class SplashState extends Equatable {
  final SplashConfigStatus status;

  /// The parsed app config. Available once [status] == [SplashConfigStatus.loaded].
  final ConfigModel? configModel;

  /// The raw response body, needed for `moduleConfig` per-type lookups.
  final Map<String, dynamic> rawData;

  final ModuleModel? module;
  final ModuleModel? cacheModule;
  final List<ModuleModel>? moduleList;
  final int moduleIndex;
  final int selectedModuleIndex;
  final LandingModel? landingModel;

  final bool hasConnection;
  final bool firstTimeConnectionCheck;
  final bool isLoading;
  final bool isRefreshing;
  final bool savedCookiesData;
  final bool webSuggestedLocation;

  final SplashActionStatus actionStatus;
  final String? actionMessage;
  final String? errorMessage;

  const SplashState({
    this.status = SplashConfigStatus.initial,
    this.configModel,
    this.rawData = const {},
    this.module,
    this.cacheModule,
    this.moduleList,
    this.moduleIndex = 0,
    this.selectedModuleIndex = 0,
    this.landingModel,
    this.hasConnection = true,
    this.firstTimeConnectionCheck = true,
    this.isLoading = false,
    this.isRefreshing = false,
    this.savedCookiesData = false,
    this.webSuggestedLocation = false,
    this.actionStatus = SplashActionStatus.none,
    this.actionMessage,
    this.errorMessage,
  });

  SplashState copyWith({
    SplashConfigStatus? status,
    ConfigModel? configModel,
    Map<String, dynamic>? rawData,
    ModuleModel? module,
    bool clearModule = false,
    ModuleModel? cacheModule,
    List<ModuleModel>? moduleList,
    int? moduleIndex,
    int? selectedModuleIndex,
    LandingModel? landingModel,
    bool? hasConnection,
    bool? firstTimeConnectionCheck,
    bool? isLoading,
    bool? isRefreshing,
    bool? savedCookiesData,
    bool? webSuggestedLocation,
    SplashActionStatus? actionStatus,
    String? actionMessage,
    String? errorMessage,
  }) {
    return SplashState(
      status: status ?? this.status,
      configModel: configModel ?? this.configModel,
      rawData: rawData ?? this.rawData,
      module: clearModule ? null : (module ?? this.module),
      cacheModule: cacheModule ?? this.cacheModule,
      moduleList: moduleList ?? this.moduleList,
      moduleIndex: moduleIndex ?? this.moduleIndex,
      selectedModuleIndex: selectedModuleIndex ?? this.selectedModuleIndex,
      landingModel: landingModel ?? this.landingModel,
      hasConnection: hasConnection ?? this.hasConnection,
      firstTimeConnectionCheck:
          firstTimeConnectionCheck ?? this.firstTimeConnectionCheck,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      savedCookiesData: savedCookiesData ?? this.savedCookiesData,
      webSuggestedLocation: webSuggestedLocation ?? this.webSuggestedLocation,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status, configModel, rawData, module, cacheModule,
    moduleList, moduleIndex, selectedModuleIndex, landingModel,
    hasConnection, firstTimeConnectionCheck, isLoading, isRefreshing,
    savedCookiesData, webSuggestedLocation,
    actionStatus, actionMessage, errorMessage,
  ];
}
