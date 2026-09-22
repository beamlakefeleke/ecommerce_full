class PaginatedRide {
  final int? totalSize;
  final String? limit;
  final int? offset;
  final List<RideRequestEntity>? rides;

  PaginatedRide({
    this.totalSize,
    this.limit,
    this.offset,
    this.rides,
  });
}

class RideRequestEntity {
  final int? id;
  final String? rideCategory;
  final String? zone;
  final String? rideStatus;
  final PickupPointEntity? pickupPoint;
  final String? pickupAddress;
  final String? pickupTime;
  final PickupPointEntity? dropoffPoint;
  final String? dropoffAddress;
  final String? dropoffTime;
  final double? estimatedTime;
  final double? estimatedFare;
  final double? estimatedDistance;
  final double? actualTime;
  final double? actualFare;
  final double? actualDistance;
  final double? totalFare;
  final double? tax;
  final String? customerName;
  final String? customerImage;
  final String? otp;
  final RiderProfileEntity? rider;
  final String? createdAt;
  final String? updatedAt;

  RideRequestEntity({
    this.id,
    this.rideCategory,
    this.zone,
    this.rideStatus,
    this.pickupPoint,
    this.pickupAddress,
    this.pickupTime,
    this.dropoffPoint,
    this.dropoffAddress,
    this.dropoffTime,
    this.estimatedTime,
    this.estimatedFare,
    this.estimatedDistance,
    this.actualTime,
    this.actualFare,
    this.actualDistance,
    this.totalFare,
    this.tax,
    this.customerName,
    this.customerImage,
    this.otp,
    this.rider,
    this.createdAt,
    this.updatedAt,
  });
}

class PickupPointEntity {
  final String? type;
  final List<double>? coordinates;

  PickupPointEntity({
    this.type,
    this.coordinates,
  });
}

class RiderProfileEntity {
  final int? id;
  final String? fName;
  final String? lName;
  final String? phone;
  final String? email;
  final String? identityNumber;
  final String? identityType;
  final String? identityImage;
  final String? image;
  final String? fcmToken;
  final int? zoneId;
  final String? createdAt;
  final String? updatedAt;
  final bool? status;
  final int? active;
  final int? earning;
  final int? currentOrders;
  final String? type;
  final int? storeId;
  final String? applicationStatus;
  final int? orderCount;
  final int? assignedOrderCount;
  final int? delivery;
  final int? rideSharing;
  final String? vehicleRegNo;
  final String? vehicleRc;
  final String? vehicleOwnerNoc;
  final int? rideZoneId;
  final int? rideCategoryId;
  final double? avgRating;
  final int? ratingCount;
  final String? lat;
  final String? lng;
  final String? location;

  RiderProfileEntity({
    this.id,
    this.fName,
    this.lName,
    this.phone,
    this.email,
    this.identityNumber,
    this.identityType,
    this.identityImage,
    this.image,
    this.fcmToken,
    this.zoneId,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.active,
    this.earning,
    this.currentOrders,
    this.type,
    this.storeId,
    this.applicationStatus,
    this.orderCount,
    this.assignedOrderCount,
    this.delivery,
    this.rideSharing,
    this.vehicleRegNo,
    this.vehicleRc,
    this.vehicleOwnerNoc,
    this.rideZoneId,
    this.rideCategoryId,
    this.avgRating,
    this.ratingCount,
    this.lat,
    this.lng,
    this.location,
  });
}
