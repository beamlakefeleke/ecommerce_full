import 'package:equatable/equatable.dart';
import 'package:ecommerce/common/models/module_model.dart';

sealed class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

/// Initialise SharedPreferences defaults and restore the cached module.
/// Called once on app start before [SplashConfigRequested].
class SplashSharedDataInitialized extends SplashEvent {
  const SplashSharedDataInitialized();
}

/// Fetch the remote config (and optionally landing-page data).
class SplashConfigRequested extends SplashEvent {
  final bool loadLandingData;
  const SplashConfigRequested({this.loadLandingData = false});

  @override
  List<Object?> get props => [loadLandingData];
}

/// Fetch the landing-page data separately (web).
class SplashLandingPageRequested extends SplashEvent {
  const SplashLandingPageRequested();
}

/// Set the active module (persist to SharedPrefs + update ApiClient header).
class SplashModuleSet extends SplashEvent {
  final ModuleModel? module;
  const SplashModuleSet(this.module);

  @override
  List<Object?> get props => [module];
}

/// Fetch the full module list from the server.
class SplashModulesRequested extends SplashEvent {
  final Map<String, String>? headers;
  const SplashModulesRequested({this.headers});

  @override
  List<Object?> get props => [headers];
}

/// User selected a module index in the module picker.
class SplashModuleIndexSelected extends SplashEvent {
  final int index;
  const SplashModuleIndexSelected(this.index);

  @override
  List<Object?> get props => [index];
}

/// Switch the active module to [moduleListIndex] and reload home data.
class SplashModuleSwitched extends SplashEvent {
  final int moduleListIndex;
  const SplashModuleSwitched(this.moduleListIndex);

  @override
  List<Object?> get props => [moduleListIndex];
}

/// Remove the current module (go back to the module picker).
class SplashModuleRemoved extends SplashEvent {
  const SplashModuleRemoved();
}

class SplashIntroDismissed extends SplashEvent {
  const SplashIntroDismissed();
}

class SplashFirstConnectionCheckDone extends SplashEvent {
  const SplashFirstConnectionCheckDone();
}

class SplashRefreshingSet extends SplashEvent {
  final bool status;
  const SplashRefreshingSet(this.status);

  @override
  List<Object?> get props => [status];
}

class SplashEmailSubscribed extends SplashEvent {
  final String email;
  const SplashEmailSubscribed(this.email);

  @override
  List<Object?> get props => [email];
}

class SplashCookiesSaved extends SplashEvent {
  final bool data;
  const SplashCookiesSaved(this.data);

  @override
  List<Object?> get props => [data];
}

class SplashWebSuggestedLocationSaved extends SplashEvent {
  final bool data;
  const SplashWebSuggestedLocationSaved(this.data);

  @override
  List<Object?> get props => [data];
}
