import 'package:ecommerce/features/parcel/domain/entities/parcel_category.dart';

/// Single serializable representation of a parcel category.
/// Owns `fromJson`/`toJson`/`toEntity`/`fromEntity`.
class ParcelCategoryModel extends ParcelCategory {
  const ParcelCategoryModel({
    super.id,
    super.image,
    super.name,
    super.description,
    super.createdAt,
    super.updatedAt,
    super.parcelPerKmShippingCharge,
    super.parcelMinimumShippingCharge,
  });

  factory ParcelCategoryModel.fromJson(Map<String, dynamic> json) {
    return ParcelCategoryModel(
      id: json['id'],
      image: json['image'],
      name: json['name'],
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      parcelPerKmShippingCharge: json['parcel_per_km_shipping_charge'] != null
          ? json['parcel_per_km_shipping_charge'].toDouble()
          : 0,
      parcelMinimumShippingCharge:
          json['parcel_minimum_shipping_charge'] != null
          ? json['parcel_minimum_shipping_charge'].toDouble()
          : 0,
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

  ParcelCategory toEntity() => ParcelCategory(
    id: id,
    image: image,
    name: name,
    description: description,
    createdAt: createdAt,
    updatedAt: updatedAt,
    parcelPerKmShippingCharge: parcelPerKmShippingCharge,
    parcelMinimumShippingCharge: parcelMinimumShippingCharge,
  );

  factory ParcelCategoryModel.fromEntity(ParcelCategory e) =>
      ParcelCategoryModel(
        id: e.id,
        image: e.image,
        name: e.name,
        description: e.description,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
        parcelPerKmShippingCharge: e.parcelPerKmShippingCharge,
        parcelMinimumShippingCharge: e.parcelMinimumShippingCharge,
      );
}
