import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/auth/domain/entities/sign_up_params.dart';
import 'package:ecommerce/features/auth/domain/entities/social_sign_in_params.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String? phone;
  final String password;

  const LoginRequested({required this.phone, required this.password});

  @override
  List<Object?> get props => [phone, password];
}

class RegistrationRequested extends AuthEvent {
  final SignUpParams signUp;

  const RegistrationRequested(this.signUp);

  @override
  List<Object?> get props => [signUp];
}

class GuestLoginRequested extends AuthEvent {
  const GuestLoginRequested();
}

class SocialLoginRequested extends AuthEvent {
  final SocialSignInParams social;

  const SocialLoginRequested(this.social);

  @override
  List<Object?> get props => [social];
}

class SocialRegistrationRequested extends AuthEvent {
  final SocialSignInParams social;

  const SocialRegistrationRequested(this.social);

  @override
  List<Object?> get props => [social];
}

class RememberMeToggled extends AuthEvent {
  const RememberMeToggled();
}

class TermsToggled extends AuthEvent {
  const TermsToggled();
}

class NotificationToggled extends AuthEvent {
  final bool isActive;

  const NotificationToggled(this.isActive);

  @override
  List<Object?> get props => [isActive];
}
