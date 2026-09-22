class TripResponse {
  final int? totalSize;
  final String? limit;
  final String? offset;
  final TripOrdersEntity? orders;

  TripResponse({
    this.totalSize,
    this.limit,
    this.offset,
    this.orders,
  });
}

class TripOrdersEntity {
  final int? currentPage;
  final List<TripDataEntity>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final String? nextPageUrl;
  final String? path;
  final String? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  TripOrdersEntity({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });
}

class TripDataEntity {
  final int? id;
  final int? userId;
  final double? orderAmount;
  final double? couponDiscountAmount;
  final String? couponDiscountTitle;
  final String? paymentStatus;
  final String? orderStatus;
  final double? totalTaxAmount;
  final String? paymentMethod;
  final String? transactionReference;
  final int? deliveryAddressId;
  final int? deliveryManId;
  final String? couponCode;
  final String? orderNote;
  final String? orderType;
  final int? checked;
  final int? storeId;
  final String? createdAt;
  final String? updatedAt;
  final int? deliveryCharge;
  final String? scheduleAt;
  final String? callback;
  final String? otp;
  final String? pending;
  final String? accepted;
  final String? confirmed;
  final String? processing;
  final String? handover;
  final String? pickedUp;
  final String? delivered;
  final String? canceled;
  final String? refundRequested;
  final String? refunded;
  final String? deliveryAddress;
  final int? scheduled;
  final int? storeDiscountAmount;
  final int? originalDeliveryCharge;
  final String? failed;
  final String? adjusment;
  final int? edited;
  final String? deliveryTime;
  final String? zoneId;
  final int? moduleId;
  final String? orderAttachment;
  final double? distance;
  final int? parcelCategoryId;
  final String? receiverDetails;
  final String? chargePayer;
  final int? dmTips;
  final String? freeDeliveryBy;
  final String? refundRequestCanceled;
  final bool? prescriptionOrder;
  final String? taxStatus;
  final int? tripOrder;
  final int? operationAreaId;
  final int? providerId;
  final String? moduleType;
  final TripProviderEntity? provider;
  final TripDetailsEntity? trip;
  final TripCustomerEntity? customer;
  final TripModuleEntity? module;

  TripDataEntity({
    this.id,
    this.userId,
    this.orderAmount,
    this.couponDiscountAmount,
    this.couponDiscountTitle,
    this.paymentStatus,
    this.orderStatus,
    this.totalTaxAmount,
    this.paymentMethod,
    this.transactionReference,
    this.deliveryAddressId,
    this.deliveryManId,
    this.couponCode,
    this.orderNote,
    this.orderType,
    this.checked,
    this.storeId,
    this.createdAt,
    this.updatedAt,
    this.deliveryCharge,
    this.scheduleAt,
    this.callback,
    this.otp,
    this.pending,
    this.accepted,
    this.confirmed,
    this.processing,
    this.handover,
    this.pickedUp,
    this.delivered,
    this.canceled,
    this.refundRequested,
    this.refunded,
    this.deliveryAddress,
    this.scheduled,
    this.storeDiscountAmount,
    this.originalDeliveryCharge,
    this.failed,
    this.adjusment,
    this.edited,
    this.deliveryTime,
    this.zoneId,
    this.moduleId,
    this.orderAttachment,
    this.distance,
    this.parcelCategoryId,
    this.receiverDetails,
    this.chargePayer,
    this.dmTips,
    this.freeDeliveryBy,
    this.refundRequestCanceled,
    this.prescriptionOrder,
    this.taxStatus,
    this.tripOrder,
    this.operationAreaId,
    this.providerId,
    this.moduleType,
    this.provider,
    this.trip,
    this.customer,
    this.module,
  });
}

class TripProviderEntity {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? logo;
  final String? coverPhoto;
  final String? latitude;
  final String? longitude;
  final String? address;
  final String? footerText;
  final int? tax;
  final int? comission;
  final String? currency;
  final bool? status;
  final int? totalVehicle;
  final int? totalDriver;
  final int? totalTrip;
  final int? completedTrip;
  final int? ongoingTrip;
  final int? canceledTrip;
  final int? vendorId;
  final int? moduleId;
  final int? operationAreaId;
  final String? createdAt;
  final String? updatedAt;

  TripProviderEntity({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.logo,
    this.coverPhoto,
    this.latitude,
    this.longitude,
    this.address,
    this.footerText,
    this.tax,
    this.comission,
    this.currency,
    this.status,
    this.totalVehicle,
    this.totalDriver,
    this.totalTrip,
    this.completedTrip,
    this.ongoingTrip,
    this.canceledTrip,
    this.vendorId,
    this.moduleId,
    this.operationAreaId,
    this.createdAt,
    this.updatedAt,
  });
}

class TripDetailsEntity {
  final int? id;
  final int? orderId;
  final int? userId;
  final int? vehicleId;
  final int? driverId;
  final int? providerId;
  final int? moduleId;
  final int? operationAreaId;
  final String? vehicleCategory;
  final double? tripAmount;
  final double? couponDiscountAmount;
  final String? couponDiscountTitle;
  final String? paymentStatus;
  final String? tripStatus;
  final double? totalTaxAmount;
  final String? paymentMethod;
  final String? transactionReference;
  final String? couponCode;
  final String? additionalNote;
  final bool? checked;
  final int? additionalCharge;
  final int? cancelationFare;
  final double? estimatedFare;
  final double? estimatedTime;
  final double? estimatedDistance;
  final double? actualFare;
  final double? actualTime;
  final double? actualDistance;
  final String? scheduleAt;
  final bool? scheduled;
  final String? otp;
  final String? pending;
  final String? accepted;
  final String? confirmed;
  final String? outForPickup;
  final String? arrived;
  final String? onTheWay;
  final String? dropped;
  final String? canceled;
  final String? rejected;
  final String? failed;
  final double? providerDiscountAmount;
  final String? createdAt;
  final String? updatedAt;

  TripDetailsEntity({
    this.id,
    this.orderId,
    this.userId,
    this.vehicleId,
    this.driverId,
    this.providerId,
    this.moduleId,
    this.operationAreaId,
    this.vehicleCategory,
    this.tripAmount,
    this.couponDiscountAmount,
    this.couponDiscountTitle,
    this.paymentStatus,
    this.tripStatus,
    this.totalTaxAmount,
    this.paymentMethod,
    this.transactionReference,
    this.couponCode,
    this.additionalNote,
    this.checked,
    this.additionalCharge,
    this.cancelationFare,
    this.estimatedFare,
    this.estimatedTime,
    this.estimatedDistance,
    this.actualFare,
    this.actualTime,
    this.actualDistance,
    this.scheduleAt,
    this.scheduled,
    this.otp,
    this.pending,
    this.accepted,
    this.confirmed,
    this.outForPickup,
    this.arrived,
    this.onTheWay,
    this.dropped,
    this.canceled,
    this.rejected,
    this.failed,
    this.providerDiscountAmount,
    this.createdAt,
    this.updatedAt,
  });
}

class TripCustomerEntity {
  final int? id;
  final String? fName;
  final String? lName;
  final String? phone;
  final String? email;
  final String? image;
  final int? isPhoneVerified;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? cmFirebaseToken;
  final int? status;
  final int? orderCount;
  final String? loginMedium;
  final int? socialId;
  final int? zoneId;
  final double? walletBalance;
  final int? loyaltyPoint;
  final String? refCode;
  final String? currentLanguageKey;

  TripCustomerEntity({
    this.id,
    this.fName,
    this.lName,
    this.phone,
    this.email,
    this.image,
    this.isPhoneVerified,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.cmFirebaseToken,
    this.status,
    this.orderCount,
    this.loginMedium,
    this.socialId,
    this.zoneId,
    this.walletBalance,
    this.loyaltyPoint,
    this.refCode,
    this.currentLanguageKey,
  });
}

class TripModuleEntity {
  final int? id;
  final String? moduleName;
  final String? moduleType;
  final String? thumbnail;
  final String? status;
  final int? storesCount;
  final String? createdAt;
  final String? updatedAt;
  final String? icon;
  final int? themeId;
  final String? description;
  final int? allZoneService;

  TripModuleEntity({
    this.id,
    this.moduleName,
    this.moduleType,
    this.thumbnail,
    this.status,
    this.storesCount,
    this.createdAt,
    this.updatedAt,
    this.icon,
    this.themeId,
    this.description,
    this.allZoneService,
  });
}
