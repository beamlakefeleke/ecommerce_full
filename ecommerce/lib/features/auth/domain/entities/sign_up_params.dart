import 'package:equatable/equatable.dart';

/// Pure registration input.
class SignUpParams extends Equatable {
  final String? fName;
  final String? lName;
  final String? phone;
  final String? email;
  final String? password;
  final String? refCode;

  const SignUpParams({
    this.fName,
    this.lName,
    this.phone,
    this.email = '',
    this.password,
    this.refCode = '',
  });

  @override
  List<Object?> get props => [fName, lName, phone, email, password, refCode];
}
