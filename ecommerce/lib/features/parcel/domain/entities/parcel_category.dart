class ParcelCategory {
  final int? id;
  final String? image;
  final String? name;
  final String? description;
  final String? createdAt;
  final String? updatedAt;
  final double? parcelMinimumShippingCharge;
  final double? parcelPerKmShippingCharge;

  ParcelCategory({
    this.id,
    this.image,
    this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.parcelMinimumShippingCharge,
    this.parcelPerKmShippingCharge,
  });
}
