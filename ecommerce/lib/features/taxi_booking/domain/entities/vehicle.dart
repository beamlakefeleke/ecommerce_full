import 'trip.dart';

class VehicleResponse {
  final int? totalSize;
  final int? limit;
  final int? offset;
  final List<VehicleEntity>? vehicles;

  VehicleResponse({
    this.totalSize,
    this.limit,
    this.offset,
    this.vehicles,
  });
}

class VehicleEntity {
  final int? id;
  final int? vehicleBrandId;
  final int? vehicleCategoryId;
  final int? vehicleModelId;
  final String? name;
  final String? engineCapacity;
  final String? airCondition;
  final String? transmissionType;
  final String? fuelType;
  final int? vinNumber;
  final int? licensePlateNumber;
  final String? mileageType;
  final int? hatchbagCapacity;
  final int? seatingCapacity;
  final String? licenseExpDate;
  final List<String>? carImages;
  final List<String>? documents;
  final int? moduleId;
  final int? providerId;
  final bool? status;
  final int? avgRating;
  final int? ratingCount;
  final String? createdAt;
  final String? updatedAt;
  final String? minFare;
  final String? brandName;
  final String? modelName;
  final String? categoryName;
  final double? insidePerHourCharge;
  final double? insidePerKmCharge;
  final double? outsidePerHourCharge;
  final double? outsidePerKmCharge;
  final TripProviderEntity? provider;

  VehicleEntity({
    this.id,
    this.vehicleBrandId,
    this.vehicleCategoryId,
    this.vehicleModelId,
    this.name,
    this.engineCapacity,
    this.airCondition,
    this.transmissionType,
    this.fuelType,
    this.vinNumber,
    this.licensePlateNumber,
    this.mileageType,
    this.hatchbagCapacity,
    this.seatingCapacity,
    this.licenseExpDate,
    this.carImages,
    this.documents,
    this.moduleId,
    this.providerId,
    this.status,
    this.avgRating,
    this.ratingCount,
    this.createdAt,
    this.updatedAt,
    this.minFare,
    this.brandName,
    this.modelName,
    this.categoryName,
    this.insidePerHourCharge,
    this.insidePerKmCharge,
    this.outsidePerHourCharge,
    this.outsidePerKmCharge,
    this.provider,
  });
}
