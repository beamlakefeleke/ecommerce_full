/// Pure Dart entity representing a social login request body.
///
/// No JSON serialization — that lives in `data/models/social_login_body_model.dart`.
class SocialLoginBody {
  final String? email;
  final String? token;
  final String? uniqueId;
  final String? medium;
  final String? phone;

  const SocialLoginBody({
    this.email,
    this.token,
    this.uniqueId,
    this.medium,
    this.phone,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialLoginBody &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          token == other.token &&
          uniqueId == other.uniqueId &&
          medium == other.medium &&
          phone == other.phone;

  @override
  int get hashCode => Object.hash(email, token, uniqueId, medium, phone);
}
