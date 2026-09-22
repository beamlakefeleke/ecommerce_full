import '../entities/ride_request.dart';

class PaginatedRideModel extends PaginatedRide {
  PaginatedRideModel({
    super.totalSize,
    super.limit,
    super.offset,
    super.rides,
  });

  factory PaginatedRideModel.fromJson(Map<String, dynamic> json) {
    return PaginatedRideModel(
      totalSize: json['total_size'],
      limit: json['limit']?.toString(),
      offset: (json['offset'] != null && json['offset'].toString().trim().isNotEmpty) ? int.parse(json['offset'].toString()) : null,
      rides: json['data'] != null ? (json['data'] as List).map((v) => RideRequestModel.fromJson(v)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_size': totalSize,
      'limit': limit,
      'offset': offset,
      'data': rides?.map((v) => (v as RideRequestModel).toJson()).toList(),
    };
  }
}

class RideRequestModel extends RideRequestEntity {
  RideRequestModel({
    super.id,
    super.rideCategory,
    super.zone,
    super.rideStatus,
    super.pickupPoint,
    super.pickupAddress,
    super.pickupTime,
    super.dropoffPoint,
    super.dropoffAddress,
    super.dropoffTime,
    super.estimatedTime,
    super.estimatedFare,
    super.estimatedDistance,
    super.actualTime,
    super.actualFare,
    super.actualDistance,
    super.totalFare,
    super.tax,
    super.customerName,
    super.customerImage,
    super.otp,
    super.rider,
    super.createdAt,
    super.updatedAt,
  });

  factory RideRequestModel.fromJson(Map<String, dynamic> json) {
    return RideRequestModel(
      id: json['id'],
      rideCategory: json['ride_category'],
      zone: json['zone'],
      rideStatus: json['ride_status'],
      pickupPoint: json['pickup_point'] != null ? PickupPoint.fromJson(json['pickup_point']) : null,
      pickupAddress: json['pickup_address'],
      pickupTime: json['pickup_time'],
      dropoffPoint: json['dropoff_point'] != null ? PickupPoint.fromJson(json['dropoff_point']) : null,
      dropoffAddress: json['dropoff_address'],
      dropoffTime: json['dropoff_time'],
      estimatedTime: json['estimated_time']?.toDouble(),
      estimatedFare: json['estimated_fare']?.toDouble(),
      estimatedDistance: json['estimated_distance']?.toDouble(),
      actualTime: json['actual_time']?.toDouble(),
      actualFare: json['actual_fare']?.toDouble(),
      actualDistance: json['actual_distance']?.toDouble(),
      totalFare: json['total_fare']?.toDouble(),
      tax: json['tax']?.toDouble(),
      customerName: json['customer_name'],
      customerImage: json['customer_image'],
      otp: json['otp']?.toString(),
      rider: json['rider'] != null ? Rider.fromJson(json['rider']) : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['ride_category'] = rideCategory;
    data['zone'] = zone;
    data['ride_status'] = rideStatus;
    if (pickupPoint != null) {
      data['pickup_point'] = (pickupPoint as PickupPoint).toJson();
    }
    data['pickup_address'] = pickupAddress;
    data['pickup_time'] = pickupTime;
    if (dropoffPoint != null) {
      data['dropoff_point'] = (dropoffPoint as PickupPoint).toJson();
    }
    data['dropoff_address'] = dropoffAddress;
    data['dropoff_time'] = dropoffTime;
    data['estimated_time'] = estimatedTime;
    data['estimated_fare'] = estimatedFare;
    data['estimated_distance'] = estimatedDistance;
    data['actual_time'] = actualTime;
    data['actual_fare'] = actualFare;
    data['actual_distance'] = actualDistance;
    data['total_fare'] = totalFare;
    data['tax'] = tax;
    data['customer_name'] = customerName;
    data['customer_image'] = customerImage;
    data['otp'] = otp;
    if (rider != null) {
      data['rider'] = (rider as Rider).toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class PickupPoint extends PickupPointEntity {
  PickupPoint({
    super.type,
    super.coordinates,
  });

  factory PickupPoint.fromJson(Map<String, dynamic> json) {
    return PickupPoint(
      type: json['type'],
      coordinates: json['coordinates']?.cast<double>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}

class Rider extends RiderProfileEntity {
  Rider({
    super.id,
    super.fName,
    super.lName,
    super.phone,
    super.email,
    super.identityNumber,
    super.identityType,
    super.identityImage,
    super.image,
    super.fcmToken,
    super.zoneId,
    super.createdAt,
    super.updatedAt,
    super.status,
    super.active,
    super.earning,
    super.currentOrders,
    super.type,
    super.storeId,
    super.applicationStatus,
    super.orderCount,
    super.assignedOrderCount,
    super.delivery,
    super.rideSharing,
    super.vehicleRegNo,
    super.vehicleRc,
    super.vehicleOwnerNoc,
    super.rideZoneId,
    super.rideCategoryId,
    super.avgRating,
    super.ratingCount,
    super.lat,
    super.lng,
    super.location,
  });

  factory Rider.fromJson(Map<String, dynamic> json) {
    return Rider(
      id: json['id'],
      fName: json['f_name'],
      lName: json['l_name'],
      phone: json['phone'],
      email: json['email'],
      identityNumber: json['identity_number'],
      identityType: json['identity_type'],
      identityImage: json['identity_image'],
      image: json['image'],
      fcmToken: json['fcm_token'],
      zoneId: json['zone_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      status: json['status'],
      active: json['active'],
      earning: json['earning'],
      currentOrders: json['current_orders'],
      type: json['type'],
      storeId: json['store_id'],
      applicationStatus: json['application_status'],
      orderCount: json['order_count'],
      assignedOrderCount: json['assigned_order_count'],
      delivery: json['delivery'],
      rideSharing: json['ride_sharing'],
      vehicleRegNo: json['vehicle_reg_no'],
      vehicleRc: json['vehicle_rc'],
      vehicleOwnerNoc: json['vehicle_owner_noc'],
      rideZoneId: json['ride_zone_id'],
      rideCategoryId: json['ride_category_id'],
      avgRating: json['avg_rating']?.toDouble(),
      ratingCount: json['rating_count'],
      lat: json['lat'],
      lng: json['lng'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'f_name': fName,
      'l_name': lName,
      'phone': phone,
      'email': email,
      'identity_number': identityNumber,
      'identity_type': identityType,
      'identity_image': identityImage,
      'image': image,
      'fcm_token': fcmToken,
      'zone_id': zoneId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'status': status,
      'active': active,
      'earning': earning,
      'current_orders': currentOrders,
      'type': type,
      'store_id': storeId,
      'application_status': applicationStatus,
      'order_count': orderCount,
      'assigned_order_count': assignedOrderCount,
      'delivery': delivery,
      'ride_sharing': rideSharing,
      'vehicle_reg_no': vehicleRegNo,
      'vehicle_rc': vehicleRc,
      'vehicle_owner_noc': vehicleOwnerNoc,
      'ride_zone_id': rideZoneId,
      'ride_category_id': rideCategoryId,
      'avg_rating': avgRating,
      'rating_count': ratingCount,
      'lat': lat,
      'lng': lng,
      'location': location,
    };
  }
}