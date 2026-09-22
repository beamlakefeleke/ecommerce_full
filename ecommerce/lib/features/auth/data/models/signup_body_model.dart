import 'package:ecommerce/features/auth/domain/entities/signup_body.dart';

/// Data-layer model that adds JSON serialization to [SignupBody].
class SignupBodyModel extends SignupBody {
  const SignupBodyModel({
    required super.firstName,
    required super.lastName,
    required super.phone,
    super.email = '',
    required super.password,
    super.refCode = '',
  });

  factory SignupBodyModel.fromEntity(SignupBody entity) {
    return SignupBodyModel(
      firstName: entity.firstName,
      lastName: entity.lastName,
      phone: entity.phone,
      email: entity.email,
      password: entity.password,
      refCode: entity.refCode,
    );
  }

  factory SignupBodyModel.fromJson(Map<String, dynamic> json) {
    return SignupBodyModel(
      firstName: json['f_name'] ?? '',
      lastName: json['l_name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      refCode: json['ref_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'f_name': firstName,
      'l_name': lastName,
      'phone': phone,
      'email': email,
      'password': password,
      'ref_code': refCode,
    };
  }
}
