import 'package:ecommerce/features/auth/domain/entities/social_login_body.dart';

/// Data-layer model that adds JSON serialization to [SocialLoginBody].
class SocialLoginBodyModel extends SocialLoginBody {
  const SocialLoginBodyModel({
    super.email,
    super.token,
    super.uniqueId,
    super.medium,
    super.phone,
  });

  factory SocialLoginBodyModel.fromEntity(SocialLoginBody entity) {
    return SocialLoginBodyModel(
      email: entity.email,
      token: entity.token,
      uniqueId: entity.uniqueId,
      medium: entity.medium,
      phone: entity.phone,
    );
  }

  factory SocialLoginBodyModel.fromJson(Map<String, dynamic> json) {
    return SocialLoginBodyModel(
      email: json['email'],
      token: json['token'],
      uniqueId: json['unique_id'],
      medium: json['medium'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'token': token,
      'unique_id': uniqueId,
      'medium': medium,
      'phone': phone,
    };
  }
}
