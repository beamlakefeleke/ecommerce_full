import 'package:ecommerce/features/auth/domain/entities/auth_response.dart';

/// Data-layer model that parses API login/register responses
/// into the domain [AuthResponse] entity.
class AuthResponseModel extends AuthResponse {
  const AuthResponseModel({
    required super.token,
    required super.isPhoneVerified,
    super.phone,
  });

  /// Parses the API response body for login / social login / register.
  ///
  /// Expected JSON shape:
  /// ```json
  /// {
  ///   "token": "...",
  ///   "is_phone_verified": 1,  // 1 = verified, 0 = not
  ///   "phone": "+1234567890"   // optional
  /// }
  /// ```
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] ?? '',
      isPhoneVerified: json['is_phone_verified'] == 1,
      phone: json['phone'],
    );
  }

  AuthResponse toEntity() {
    return AuthResponse(
      token: token,
      isPhoneVerified: isPhoneVerified,
      phone: phone,
    );
  }
}
