import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:ecommerce/features/auth/domain/usecases/guest_login_usecase.dart';
import 'package:ecommerce/features/auth/domain/usecases/login_usecase.dart';
import 'package:ecommerce/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ecommerce/features/auth/domain/usecases/manage_saved_credentials_usecase.dart';
import 'package:ecommerce/features/auth/domain/usecases/register_usecase.dart';
import 'package:ecommerce/features/auth/domain/usecases/social_login_usecase.dart';
import 'package:ecommerce/features/auth/domain/usecases/social_register_usecase.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_state.dart';

/// BLoC for the auth feature — replaces the legacy GetX [AuthController].
///
/// One Bloc per feature-page concern. Calls domain usecases, emits
/// immutable states. **No navigation calls** — the UI layer uses
/// `BlocListener` to handle navigation based on state transitions.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final GuestLoginUseCase _guestLoginUseCase;
  final SocialLoginUseCase _socialLoginUseCase;
  final SocialRegisterUseCase _socialRegisterUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final ManageSavedCredentialsUseCase _credentialsUseCase;
  final AuthRepository _authRepository;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required GuestLoginUseCase guestLoginUseCase,
    required SocialLoginUseCase socialLoginUseCase,
    required SocialRegisterUseCase socialRegisterUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
    required ManageSavedCredentialsUseCase credentialsUseCase,
    required AuthRepository authRepository,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _guestLoginUseCase = guestLoginUseCase,
        _socialLoginUseCase = socialLoginUseCase,
        _socialRegisterUseCase = socialRegisterUseCase,
        _logoutUseCase = logoutUseCase,
        _checkAuthStatusUseCase = checkAuthStatusUseCase,
        _credentialsUseCase = credentialsUseCase,
        _authRepository = authRepository,
        super(AuthInitial(
          savedNumber: credentialsUseCase.getNumber(),
          savedPassword: credentialsUseCase.getPassword(),
          savedCountryCode: credentialsUseCase.getCountryCode(),
          isNotificationActive: authRepository.isNotificationActive(),
        )) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<GuestLoginRequested>(_onGuestLoginRequested);
    on<SocialLoginRequested>(_onSocialLoginRequested);
    on<SocialRegisterRequested>(_onSocialRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RememberMeToggled>(_onRememberMeToggled);
    on<TermsToggled>(_onTermsToggled);
    on<TokenPersistenceRequested>(_onTokenPersistenceRequested);
  }

  // ─── Convenience accessors (for compatibility shim) ────────────────

  bool get isLoggedIn => _checkAuthStatusUseCase.isLoggedIn();
  bool get isGuestLoggedIn => _checkAuthStatusUseCase.isGuestLoggedIn();
  String get guestId => _checkAuthStatusUseCase.getGuestId();
  String get userToken => _checkAuthStatusUseCase.getUserToken();

  String get savedNumber => _credentialsUseCase.getNumber();
  String get savedCountryCode => _credentialsUseCase.getCountryCode();
  String get savedPassword => _credentialsUseCase.getPassword();

  String get guestContactNumber => _authRepository.getGuestContactNumber();

  bool get isNotificationActive => _authRepository.isNotificationActive();

  // ─── Event handlers ────────────────────────────────────────────────

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _loginUseCase(
      phone: event.phone,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (response) => emit(AuthSuccess(response: response)),
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _registerUseCase(event.body);

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (response) => emit(AuthSuccess(response: response)),
    );
  }

  Future<void> _onGuestLoginRequested(
    GuestLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthGuestLoading());

    final result = await _guestLoginUseCase();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (guestId) => emit(AuthGuestSuccess(guestId: guestId)),
    );
  }

  Future<void> _onSocialLoginRequested(
    SocialLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _socialLoginUseCase(event.body);

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (response) {
        if (response.token.isNotEmpty) {
          if (!response.isPhoneVerified) {
            // User exists but phone not verified → verification screen
            emit(AuthSocialNeedsVerification(
              phone: response.phone ?? event.body.email ?? '',
              token: response.token,
            ));
          } else {
            // Fully authenticated
            emit(AuthSuccess(response: response));
          }
        } else {
          // No token → user needs to complete social registration
          emit(AuthSocialNeedsRegistration(body: event.body));
        }
      },
    );
  }

  Future<void> _onSocialRegisterRequested(
    SocialRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _socialRegisterUseCase(event.body);

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (response) {
        if (!response.isPhoneVerified && response.token.isNotEmpty) {
          emit(AuthSocialNeedsVerification(
            phone: event.body.phone ?? '',
            token: response.token,
          ));
        } else {
          emit(AuthSuccess(response: response));
        }
      },
    );
  }

  void _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) {
    _logoutUseCase();
    emit(const AuthLoggedOut());
  }

  void _onRememberMeToggled(
    RememberMeToggled event,
    Emitter<AuthState> emit,
  ) {
    final current = state;
    if (current is AuthInitial) {
      emit(current.copyWith(
        isRememberMeActive: !current.isRememberMeActive,
      ));
    }
  }

  void _onTermsToggled(
    TermsToggled event,
    Emitter<AuthState> emit,
  ) {
    final current = state;
    if (current is AuthInitial) {
      emit(current.copyWith(acceptTerms: !current.acceptTerms));
    }
  }

  Future<void> _onTokenPersistenceRequested(
    TokenPersistenceRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.saveUserToken(event.token);
    await _authRepository.updateToken();
    await _authRepository.clearGuestId();
  }

  // ─── Public methods for compatibility layer ────────────────────────

  Future<void> saveCredentials({
    required String number,
    required String password,
    required String countryCode,
  }) async {
    await _credentialsUseCase.save(
      number: number,
      password: password,
      countryCode: countryCode,
    );
  }

  Future<bool> clearCredentials() => _credentialsUseCase.clear();

  Future<void> saveGuestNumber(String number) =>
      _authRepository.saveGuestContactNumber(number);

  bool clearSharedData() => _authRepository.clearSharedData();

  Future<bool> clearSharedAddress() => _authRepository.clearSharedAddress();

  Future<void> updateToken() => _authRepository.updateToken();

  Future<void> updateZone() => _authRepository.updateZone();

  void setNotificationActive(bool isActive) =>
      _authRepository.setNotificationActive(isActive);
}
