import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/verification/domain/usecases/verification_usecases.dart';

sealed class VerificationEvent extends Equatable {
  const VerificationEvent();

  @override
  List<Object?> get props => [];
}

class VerificationCodeUpdated extends VerificationEvent {
  final String code;
  const VerificationCodeUpdated(this.code);

  @override
  List<Object?> get props => [code];
}

class ForgetPasswordRequested extends VerificationEvent {
  final String? phone;
  const ForgetPasswordRequested(this.phone);

  @override
  List<Object?> get props => [phone];
}

class ResetPasswordRequested extends VerificationEvent {
  final ResetPasswordParams params;
  const ResetPasswordRequested(this.params);

  @override
  List<Object?> get props => [params];
}

class VerifyPhoneRequested extends VerificationEvent {
  final String? phone;
  final String? token;
  const VerifyPhoneRequested({this.phone, this.token});

  @override
  List<Object?> get props => [phone, token];
}

class VerifyTokenRequested extends VerificationEvent {
  final String? phone;
  const VerifyTokenRequested(this.phone);

  @override
  List<Object?> get props => [phone];
}
