import 'package:equatable/equatable.dart';

/// Pure business object for a parcel category. Transport/JSON concerns live in
/// `data/models/parcel_category_model.dart`.
class ParcelCategory extends Equatable {
  final int? id;
  final String? image;
  final String? name;
  final String? description;
  final String? createdAt;
  final String? updatedAt;
  final double? parcelPerKmShippingCharge;
  final double? parcelMinimumShippingCharge;

  const ParcelCategory({
    this.id,
    this.image,
    this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.parcelPerKmShippingCharge,
    this.parcelMinimumShippingCharge,
  });

  @override
  List<Object?> get props => [
    id,
    image,
    name,
    description,
    createdAt,
    updatedAt,
    parcelPerKmShippingCharge,
    parcelMinimumShippingCharge,
  ];
}
