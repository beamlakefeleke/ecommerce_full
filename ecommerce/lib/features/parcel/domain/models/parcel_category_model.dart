import 'package:ecommerce/features/flash_sale/domain/models/flash_sale_model.dart';
import 'package:ecommerce/features/parcel/domain/entities/parcel_category.dart';

class ParcelCategoryModel extends ParcelCategory {
  List<Translations>? translations;

  ParcelCategoryModel({
    super.id,
    super.image,
    super.name,
    super.description,
    super.createdAt,
    super.updatedAt,
    super.parcelMinimumShippingCharge,
    super.parcelPerKmShippingCharge,
    this.translations,
  });

  factory ParcelCategoryModel.fromJson(Map<String, dynamic> json) {
    List<Translations>? translations;
    if (json['translations'] != null) {
      translations = <Translations>[];
      json['translations'].forEach((v) {
        translations!.add(Translations.fromJson(v));
      });
    }

    return ParcelCategoryModel(
      id: json['id'],
      image: json['image'],
      name: json['name'],
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      parcelMinimumShippingCharge:
          json['parcel_minimum_shipping_charge'] != null
          ? double.tryParse(json['parcel_minimum_shipping_charge'].toString())
          : null,
      parcelPerKmShippingCharge: json['parcel_per_km_shipping_charge'] != null
          ? double.tryParse(json['parcel_per_km_shipping_charge'].toString())
          : null,
      translations: translations,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['name'] = name;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['parcel_per_km_shipping_charge'] = parcelPerKmShippingCharge;
    data['parcel_minimum_shipping_charge'] = parcelMinimumShippingCharge;
    return data;
  }
}
