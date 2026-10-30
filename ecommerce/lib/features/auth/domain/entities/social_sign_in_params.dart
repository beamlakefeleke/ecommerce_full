import 'package:equatable/equatable.dart';

/// Pure social sign-in / sign-up input.
class SocialSignInParams extends Equatable {
  final String? email;
  final String? token;
  final String? uniqueId;
  final String? medium;
  final String? phone;

  const SocialSignInParams({
    this.email,
    this.token,
    this.uniqueId,
    this.medium,
    this.phone,
  });

  @override
  List<Object?> get props => [email, token, uniqueId, medium, phone];
}
