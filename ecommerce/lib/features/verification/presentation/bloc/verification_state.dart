import 'package:equatable/equatable.dart';

enum VerificationStatus { initial, loading, success, error }

enum VerificationActionType { none, forgetPassword, resetPassword, verifyPhone, verifyToken }

class VerificationState extends Equatable {
  final String verificationCode;
  final VerificationStatus status;
  final VerificationActionType actionType;
  final String? message;
  final String? phone;

  const VerificationState({
    this.verificationCode = '',
    this.status = VerificationStatus.initial,
    this.actionType = VerificationActionType.none,
    this.message,
    this.phone,
  });

  bool get isLoading => status == VerificationStatus.loading;
  bool get isSuccess => status == VerificationStatus.success;

  VerificationState copyWith({
    String? verificationCode,
    VerificationStatus? status,
    VerificationActionType? actionType,
    String? message,
    String? phone,
    bool clearMessage = false,
  }) {
    return VerificationState(
      verificationCode: verificationCode ?? this.verificationCode,
      status: status ?? this.status,
      actionType: actionType ?? this.actionType,
      message: clearMessage ? null : (message ?? this.message),
      phone: phone ?? this.phone,
    );
  }

  @override
  List<Object?> get props =>
      [verificationCode, status, actionType, message, phone];
}
