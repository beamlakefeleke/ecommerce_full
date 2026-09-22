/// Pure Dart entity representing an authentication response.
///
/// No JSON, no Flutter imports. Data-layer models convert API responses
/// into this entity via `toEntity()`.
class AuthResponse {
  final String token;
  final bool isPhoneVerified;
  final String? phone;

  const AuthResponse({
    required this.token,
    required this.isPhoneVerified,
    this.phone,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthResponse &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          isPhoneVerified == other.isPhoneVerified &&
          phone == other.phone;

  @override
  int get hashCode => Object.hash(token, isPhoneVerified, phone);

  @override
  String toString() =>
      'AuthResponse(token: ${token.isNotEmpty ? "***" : ""}, isPhoneVerified: $isPhoneVerified, phone: $phone)';
}
