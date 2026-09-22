import 'package:ecommerce/features/chat/domain/models/conversation_model.dart';
import 'package:ecommerce/features/profile/domain/entities/user_info.dart';

class UserInfoModel extends UserInfo {
  UserInfoModel({
    super.id,
    super.fName,
    super.lName,
    super.email,
    super.image,
    super.phone,
    super.createdAt,
    super.password,
    super.orderCount,
    super.memberSinceDays,
    super.walletBalance,
    super.loyaltyPoint,
    super.refCode,
    super.socialId,
    super.userInfo,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      id: json['id'],
      fName: json['f_name'],
      lName: json['l_name'],
      email: json['email'],
      image: json['image'],
      phone: json['phone'],
      createdAt: json['created_at'],
      password: json['password'],
      orderCount: json['order_count'],
      memberSinceDays: json['member_since_days'],
      walletBalance: json['wallet_balance']?.toDouble(),
      loyaltyPoint: json['loyalty_point'],
      refCode: json['ref_code'],
      socialId: json['social_id'],
      userInfo: json['userinfo'] != null ? User.fromJson(json['userinfo']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['email'] = email;
    data['image'] = image;
    data['phone'] = phone;
    data['created_at'] = createdAt;
    data['password'] = password;
    data['order_count'] = orderCount;
    data['member_since_days'] = memberSinceDays;
    data['wallet_balance'] = walletBalance;
    data['loyalty_point'] = loyaltyPoint;
    data['ref_code'] = refCode;
    data['social_id'] = socialId;
    if (userInfo != null) {
      data['userinfo'] = userInfo!.toJson();
    }
    return data;
  }
}
