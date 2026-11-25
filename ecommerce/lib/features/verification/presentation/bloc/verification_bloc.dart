import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_event.dart';
import 'package:ecommerce/features/verification/domain/usecases/verification_usecases.dart';
import 'package:ecommerce/features/verification/presentation/bloc/verification_event.dart';
import 'package:ecommerce/features/verification/presentation/bloc/verification_state.dart';

export 'verification_event.dart';
export 'verification_state.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final ForgetPasswordUseCase forgetPassword;
  final ResetPasswordUseCase resetPassword;
  final VerifyPhoneUseCase verifyPhone;
  final VerifyTokenUseCase verifyToken;
  final AuthRepository authRepository;

  VerificationBloc({
    required this.forgetPassword,
    required this.resetPassword,
    required this.verifyPhone,
    required this.verifyToken,
    required this.authRepository,
  }) : super(const VerificationState()) {
    on<VerificationCodeUpdated>(_onCodeUpdated);
    on<ForgetPasswordRequested>(_onForgetPassword);
    on<ResetPasswordRequested>(_onResetPassword);
    on<VerifyPhoneRequested>(_onVerifyPhone);
    on<VerifyTokenRequested>(_onVerifyToken);
  }

  void _onCodeUpdated(
    VerificationCodeUpdated event,
    Emitter<VerificationState> emit,
  ) {
    emit(state.copyWith(verificationCode: event.code));
  }

  Future<void> _onForgetPassword(
    ForgetPasswordRequested event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(
      status: VerificationStatus.loading,
      actionType: VerificationActionType.forgetPassword,
      phone: event.phone,
    ));
    final result = await forgetPassword(ForgetPasswordParams(event.phone));
    result.fold(
      (failure) => emit(state.copyWith(
        status: VerificationStatus.error,
        message: failure.message,
      )),
      (message) => emit(state.copyWith(
        status: VerificationStatus.success,
        message: message,
      )),
    );
  }

  Future<void> _onResetPassword(
    ResetPasswordRequested event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(
      status: VerificationStatus.loading,
      actionType: VerificationActionType.resetPassword,
    ));
    final result = await resetPassword(event.params);
    result.fold(
      (failure) => emit(state.copyWith(
        status: VerificationStatus.error,
        message: failure.message,
      )),
      (message) => emit(state.copyWith(
        status: VerificationStatus.success,
        message: message,
      )),
    );
  }

  Future<void> _onVerifyPhone(
    VerifyPhoneRequested event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(
      status: VerificationStatus.loading,
      actionType: VerificationActionType.verifyPhone,
      phone: event.phone,
    ));
    final result = await verifyPhone(
      VerifyPhoneParams(phone: event.phone, token: event.token),
    );
    await result.fold(
      (failure) async {
        emit(state.copyWith(
          status: VerificationStatus.error,
          message: failure.message,
        ));
      },
      (message) async {
        // On successful phone verification, save the token and refresh
        // the auth session — same side effects as the legacy
        // VerificationService.verifyPhone.
        if (event.token != null && event.token!.isNotEmpty) {
          await authRepository.saveUserToken(event.token!);
          await authRepository.updateToken();
          await authRepository.clearGuestId();
        }
        // Refresh the profile so downstream screens read the verified user.
        getIt<ProfileBloc>().add(const ProfileInfoRequested());
        emit(state.copyWith(
          status: VerificationStatus.success,
          message: message,
        ));
      },
    );
  }

  Future<void> _onVerifyToken(
    VerifyTokenRequested event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(
      status: VerificationStatus.loading,
      actionType: VerificationActionType.verifyToken,
      phone: event.phone,
    ));
    final result = await verifyToken(
      VerifyTokenParams(phone: event.phone, token: state.verificationCode),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: VerificationStatus.error,
        message: failure.message,
      )),
      (message) => emit(state.copyWith(
        status: VerificationStatus.success,
        message: message,
      )),
    );
  }
}
