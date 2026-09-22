import 'package:ecommerce/features/wallet/domain/entities/wallet_filter_body.dart';

class WalletFilterBodyModel extends WalletFilterBody {
  WalletFilterBodyModel({required super.title, required super.value});

  factory WalletFilterBodyModel.fromJson(Map<String, dynamic> json) {
    return WalletFilterBodyModel(
      title: json['title'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['value'] = value;
    return data;
  }
}