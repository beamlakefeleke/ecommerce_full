import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce/features/auth/domain/usecases/guest_login_usecase.dart';
import 'package:ecommerce/features/auth/domain/usecases/login_usecase.dart';
import 'package:ecommerce/features/auth/domain/usecases/register_usecase.dart';
import 'package:ecommerce/features/auth/domain/usecases/social_login_usecase.dart';
import 'package:ecommerce/features/auth/domain/usecases/social_register_usecase.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GuestLoginUseCase guestLoginUseCase;
  final SocialLoginUseCase socialLoginUseCase;
  final SocialRegisterUseCase socialRegisterUseCase;
  final AuthRepository repository;

  /// Supplies the current `customerVerification` config flag. The config lives
  /// in the splash feature (still GetX); the UI injects it when constructing
  /// the bloc so the domain stays decoupled from SplashController.
  final bool Function() isCustomerVerificationOn;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.guestLoginUseCase,
    required this.socialLoginUseCase,
    required this.socialRegisterUseCase,
    required this.repository,
    required this.isCustomerVerificationOn,
  }) : super(AuthState(notification: repository.isNotificationActive())) {
    on<LoginRequested>(_onLogin);
    on<RegistrationRequested>(_onRegister);
    on<GuestLoginRequested>(_onGuestLogin);
    on<SocialLoginRequested>(_onSocialLogin);
    on<SocialRegistrationRequested>(_onSocialRegister);
    on<RememberMeToggled>(_onRememberMeToggled);
    on<TermsToggled>(_onTermsToggled);
    on<NotificationToggled>(_onNotificationToggled);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(
      state.copyWith(
        isLoading: true,
        actionStatus: AuthActionStatus.inProgress,
        actionType: AuthActionType.login,
      ),
    );
    final result = await loginUseCase(
      LoginParams(
        phone: event.phone,
        password: event.password,
        isCustomerVerificationOn: isCustomerVerificationOn(),
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          actionStatus: AuthActionStatus.failure,
          actionType: AuthActionType.login,
          message: failure.message,
        ),
      ),
      (auth) {
        final needsVerification =
            isCustomerVerificationOn() && !auth.isPhoneVerified;
        emit(
          state.copyWith(
            isLoading: false,
            actionStatus: AuthActionStatus.success,
            actionType: AuthActionType.login,
            isPhoneVerified: auth.isPhoneVerified,
            nextStep: needsVerification
                ? AuthNextStep.verification
                : AuthNextStep.location,
            pendingToken: auth.token,
            pendingPhone: event.phone,
          ),
        );
      },
    );
  }

  Future<void> _onRegister(
    RegistrationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        actionStatus: AuthActionStatus.inProgress,
        actionType: AuthActionType.register,
      ),
    );
    final result = await registerUseCase(
      RegisterParams(
        signUp: event.signUp,
        isCustomerVerificationOn: isCustomerVerificationOn(),
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          actionStatus: AuthActionStatus.failure,
          actionType: AuthActionType.register,
          message: failure.message,
        ),
      ),
      (auth) => emit(
        state.copyWith(
          isLoading: false,
          actionStatus: AuthActionStatus.success,
          actionType: AuthActionType.register,
          nextStep: isCustomerVerificationOn()
              ? AuthNextStep.verification
              : AuthNextStep.location,
          pendingToken: auth.token,
          pendingPhone: event.signUp.phone,
        ),
      ),
    );
  }

  Future<void> _onGuestLogin(
    GuestLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        guestLoading: true,
        actionStatus: AuthActionStatus.inProgress,
        actionType: AuthActionType.guestLogin,
      ),
    );
    final result = await guestLoginUseCase(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          guestLoading: false,
          actionStatus: AuthActionStatus.failure,
          actionType: AuthActionType.guestLogin,
          message: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          guestLoading: false,
          actionStatus: AuthActionStatus.success,
          actionType: AuthActionType.guestLogin,
        ),
      ),
    );
  }

  Future<void> _onSocialLogin(
    SocialLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        actionStatus: AuthActionStatus.inProgress,
        actionType: AuthActionType.socialLogin,
      ),
    );
    final result = await socialLoginUseCase(
      SocialLoginParams(
        social: event.social,
        isCustomerVerificationOn: isCustomerVerificationOn(),
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          actionStatus: AuthActionStatus.failure,
          actionType: AuthActionType.socialLogin,
          message: failure.message,
        ),
      ),
      (social) => emit(_fromSocial(social, AuthActionType.socialLogin)),
    );
  }

  Future<void> _onSocialRegister(
    SocialRegistrationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        actionStatus: AuthActionStatus.inProgress,
        actionType: AuthActionType.socialRegister,
      ),
    );
    final result = await socialRegisterUseCase(
      SocialRegisterParams(
        social: event.social,
        isCustomerVerificationOn: isCustomerVerificationOn(),
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          actionStatus: AuthActionStatus.failure,
          actionType: AuthActionType.socialRegister,
          message: failure.message,
        ),
      ),
      (social) => emit(_fromSocial(social, AuthActionType.socialRegister)),
    );
  }

  AuthState _fromSocial(SocialAuthResult social, AuthActionType type) {
    switch (social.outcome) {
      case SocialAuthOutcome.authenticated:
        return state.copyWith(
          isLoading: false,
          actionStatus: AuthActionStatus.success,
          actionType: type,
          nextStep: AuthNextStep.location,
        );
      case SocialAuthOutcome.needsVerification:
        return state.copyWith(
          isLoading: false,
          actionStatus: AuthActionStatus.success,
          actionType: type,
          nextStep: AuthNextStep.verification,
          pendingToken: social.token,
          pendingPhone: social.phone,
        );
      case SocialAuthOutcome.needsRegistration:
        return state.copyWith(
          isLoading: false,
          actionStatus: AuthActionStatus.success,
          actionType: type,
          nextStep: AuthNextStep.registration,
          pendingPhone: social.phone,
        );
      case SocialAuthOutcome.failed:
        return state.copyWith(
          isLoading: false,
          actionStatus: AuthActionStatus.failure,
          actionType: type,
          message: social.message,
        );
    }
  }

  void _onRememberMeToggled(RememberMeToggled event, Emitter<AuthState> emit) {
    emit(state.copyWith(rememberMe: !state.rememberMe));
  }

  void _onTermsToggled(TermsToggled event, Emitter<AuthState> emit) {
    emit(state.copyWith(acceptTerms: !state.acceptTerms));
  }

  void _onNotificationToggled(
    NotificationToggled event,
    Emitter<AuthState> emit,
  ) {
    repository.setNotificationActive(event.isActive);
    emit(state.copyWith(notification: event.isActive));
  }
}
