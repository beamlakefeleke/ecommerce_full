import 'package:equatable/equatable.dart';

/// One-shot status of the last auth action (login / register / social / guest).
/// The UI reacts via BlocListener and dispatches navigation/snackbars.
enum AuthActionStatus { none, inProgress, success, failure }

/// Which action produced the current [AuthActionStatus] — lets the UI route
/// the result correctly (e.g. login success -> location, register success with
/// verification on -> verification screen).
enum AuthActionType {
  none,
  login,
  register,
  guestLogin,
  socialLogin,
  socialRegister,
}

/// What the UI should do next after a (social) auth attempt.
enum AuthNextStep { none, location, verification, registration }

class AuthState extends Equatable {
  final bool isLoading;
  final bool guestLoading;
  final bool acceptTerms;
  final bool rememberMe;
  final bool notification;

  final AuthActionStatus actionStatus;
  final AuthActionType actionType;
  final AuthNextStep nextStep;
  final String? message;

  /// For login/register success: whether the phone is verified (drives whether
  /// the UI goes to the verification screen).
  final bool isPhoneVerified;

  /// Carried from a social attempt that needs verification.
  final String? pendingToken;
  final String? pendingPhone;

  const AuthState({
    this.isLoading = false,
    this.guestLoading = false,
    this.acceptTerms = true,
    this.rememberMe = false,
    this.notification = true,
    this.actionStatus = AuthActionStatus.none,
    this.actionType = AuthActionType.none,
    this.nextStep = AuthNextStep.none,
    this.message,
    this.isPhoneVerified = false,
    this.pendingToken,
    this.pendingPhone,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? guestLoading,
    bool? acceptTerms,
    bool? rememberMe,
    bool? notification,
    AuthActionStatus? actionStatus,
    AuthActionType? actionType,
    AuthNextStep? nextStep,
    String? message,
    bool? isPhoneVerified,
    String? pendingToken,
    String? pendingPhone,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      guestLoading: guestLoading ?? this.guestLoading,
      acceptTerms: acceptTerms ?? this.acceptTerms,
      rememberMe: rememberMe ?? this.rememberMe,
      notification: notification ?? this.notification,
      actionStatus: actionStatus ?? this.actionStatus,
      actionType: actionType ?? this.actionType,
      nextStep: nextStep ?? this.nextStep,
      message: message,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      pendingToken: pendingToken ?? this.pendingToken,
      pendingPhone: pendingPhone ?? this.pendingPhone,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    guestLoading,
    acceptTerms,
    rememberMe,
    notification,
    actionStatus,
    actionType,
    nextStep,
    message,
    isPhoneVerified,
    pendingToken,
    pendingPhone,
  ];
}
