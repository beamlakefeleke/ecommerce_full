import '../entities/vehicle.dart';
import 'trip_model.dart'; // To use the Provider class alias

class VehicleModel extends VehicleResponse {
  VehicleModel({
    super.totalSize,
    super.limit,
    super.offset,
    super.vehicles,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      totalSize: json['total_size'],
      limit: json['limit'] != null ? int.parse(json['limit'].toString()) : null,
      offset: json['offset'] != null ? int.parse(json['offset'].toString()) : null,
      vehicles: json['vehicles'] != null
          ? (json['vehicles'] as List).map((v) => Vehicles.fromJson(v)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_size': totalSize,
      'limit': limit,
      'offset': offset,
      'vehicles': vehicles?.map((v) => (v as Vehicles).toJson()).toList(),
    };
  }
}

class Vehicles extends VehicleEntity {
  Vehicles({
    super.id,
    super.vehicleBrandId,
    super.vehicleCategoryId,
    super.vehicleModelId,
    super.name,
    super.engineCapacity,
    super.airCondition,
    super.transmissionType,
    super.fuelType,
    super.vinNumber,
    super.licensePlateNumber,
    super.mileageType,
    super.hatchbagCapacity,
    super.seatingCapacity,
    super.licenseExpDate,
    super.carImages,
    super.documents,
    super.moduleId,
    super.providerId,
    super.status,
    super.avgRating,
    super.ratingCount,
    super.createdAt,
    super.updatedAt,
    super.minFare,
    super.brandName,
    super.modelName,
    super.categoryName,
    super.insidePerHourCharge,
    super.insidePerKmCharge,
    super.outsidePerHourCharge,
    super.outsidePerKmCharge,
    super.provider,
  });

  factory Vehicles.fromJson(Map<String, dynamic> json) {
    return Vehicles(
      id: json['id'],
      vehicleBrandId: json['vehicle_brand_id'],
      vehicleCategoryId: json['vehicle_category_id'],
      vehicleModelId: json['vehicle_model_id'],
      name: json['name'],
      engineCapacity: json['engine_capacity']?.toString(),
      airCondition: json['air_condition'],
      transmissionType: json['transmission_type'],
      fuelType: json['fuel_type'],
      vinNumber: json['vin_number'] != null ? int.tryParse(json['vin_number'].toString()) : null,
      licensePlateNumber: json['license_plate_number'] != null ? int.tryParse(json['license_plate_number'].toString()) : null,
      mileageType: json['mileage_type'],
      hatchbagCapacity: json['hatchbag_capacity'] != null ? int.tryParse(json['hatchbag_capacity'].toString()) : null,
      seatingCapacity: json['seating_capacity'] != null ? int.tryParse(json['seating_capacity'].toString()) : null,
      licenseExpDate: json['license_exp_date'],
      carImages: json['car_images']?.cast<String>(),
      documents: json['documents']?.cast<String>(),
      moduleId: json['module_id'] != null ? int.tryParse(json['module_id'].toString()) : null,
      providerId: json['provider_id'] != null ? int.tryParse(json['provider_id'].toString()) : null,
      status: json['status'],
      avgRating: json['avg_rating'] != null ? int.tryParse(json['avg_rating'].toString()) : null,
      ratingCount: json['rating_count'] != null ? int.tryParse(json['rating_count'].toString()) : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      minFare: json['min_fare']?.toString(),
      brandName: json['brand_name'],
      modelName: json['model_name'],
      categoryName: json['category_name'],
      insidePerHourCharge: json['inside_per_hr_charge']?.toDouble(),
      insidePerKmCharge: json['inside_per_km_charge']?.toDouble(),
      outsidePerHourCharge: json['outside_per_hr_charge']?.toDouble(),
      outsidePerKmCharge: json['outside_per_km_charge']?.toDouble(),
      provider: json['provider'] != null ? Provider.fromJson(json['provider']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_brand_id': vehicleBrandId,
      'vehicle_category_id': vehicleCategoryId,
      'vehicle_model_id': vehicleModelId,
      'name': name,
      'engine_capacity': engineCapacity,
      'air_condition': airCondition,
      'transmissionType': transmissionType,
      'fuel_type': fuelType,
      'vin_number': vinNumber,
      'license_plate_number': licensePlateNumber,
      'mileage_type': mileageType,
      'hatchbag_capacity': hatchbagCapacity,
      'seating_capacity': seatingCapacity,
      'license_exp_date': licenseExpDate,
      'car_images': carImages,
      'documents': documents,
      'module_id': moduleId,
      'provider_id': providerId,
      'status': status,
      'avg_rating': avgRating,
      'rating_count': ratingCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'min_fare': minFare,
      'brand_name': brandName,
      'model_name': modelName,
      'category_name': categoryName,
      'inside_per_hr_charge': insidePerHourCharge,
      'inside_per_km_charge': insidePerKmCharge,
      'outside_per_hr_charge': outsidePerHourCharge,
      'outside_per_km_charge': outsidePerKmCharge,
      'provider': provider != null ? (provider as Provider).toJson() : null,
    };
  }
}