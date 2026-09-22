import 'package:ecommerce/features/chat/domain/models/conversation_model.dart';

class UserInfo {
  final int? id;
  final String? fName;
  final String? lName;
  final String? email;
  final String? image;
  final String? phone;
  final String? createdAt;
  final String? password;
  final int? orderCount;
  final int? memberSinceDays;
  final double? walletBalance;
  final int? loyaltyPoint;
  final String? refCode;
  final String? socialId;
  final User? userInfo;

  const UserInfo({
    this.id,
    this.fName,
    this.lName,
    this.email,
    this.image,
    this.phone,
    this.createdAt,
    this.password,
    this.orderCount,
    this.memberSinceDays,
    this.walletBalance,
    this.loyaltyPoint,
    this.refCode,
    this.socialId,
    this.userInfo,
  });

  UserInfo copyWith({
    int? id,
    String? fName,
    String? lName,
    String? email,
    String? image,
    String? phone,
    String? createdAt,
    String? password,
    int? orderCount,
    int? memberSinceDays,
    double? walletBalance,
    int? loyaltyPoint,
    String? refCode,
    String? socialId,
    User? userInfo,
  }) {
    return UserInfo(
      id: id ?? this.id,
      fName: fName ?? this.fName,
      lName: lName ?? this.lName,
      email: email ?? this.email,
      image: image ?? this.image,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      password: password ?? this.password,
      orderCount: orderCount ?? this.orderCount,
      memberSinceDays: memberSinceDays ?? this.memberSinceDays,
      walletBalance: walletBalance ?? this.walletBalance,
      loyaltyPoint: loyaltyPoint ?? this.loyaltyPoint,
      refCode: refCode ?? this.refCode,
      socialId: socialId ?? this.socialId,
      userInfo: userInfo ?? this.userInfo,
    );
  }
}
