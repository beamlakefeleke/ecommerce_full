import 'package:equatable/equatable.dart';

/// Pure result of a successful authentication (login / register / social).
class AuthResponse extends Equatable {
  final String token;
  final bool isPhoneVerified;

  const AuthResponse({required this.token, this.isPhoneVerified = false});

  @override
  List<Object?> get props => [token, isPhoneVerified];
}
