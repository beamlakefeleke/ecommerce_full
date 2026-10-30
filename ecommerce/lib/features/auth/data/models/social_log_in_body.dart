import 'package:ecommerce/features/auth/domain/entities/social_sign_in_params.dart';

class SocialLogInBody {
  String? email;
  String? token;
  String? uniqueId;
  String? medium;
  String? phone;

  SocialLogInBody({
    this.email,
    this.token,
    this.uniqueId,
    this.medium,
    this.phone,
  });

  SocialLogInBody.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    token = json['token'];
    uniqueId = json['unique_id'];
    medium = json['medium'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['token'] = token;
    data['unique_id'] = uniqueId;
    data['medium'] = medium;
    data['phone'] = phone;
    return data;
  }

  factory SocialLogInBody.fromEntity(SocialSignInParams p) => SocialLogInBody(
    email: p.email,
    token: p.token,
    uniqueId: p.uniqueId,
    medium: p.medium,
    phone: p.phone,
  );

  SocialSignInParams toEntity() => SocialSignInParams(
    email: email,
    token: token,
    uniqueId: uniqueId,
    medium: medium,
    phone: phone,
  );
}
