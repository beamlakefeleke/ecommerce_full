import 'package:ecommerce/features/address/domain/entities/address.dart';
import 'package:ecommerce/features/location/domain/models/zone_response_model.dart';

/// Data-layer model: the single serializable representation of an address.
///
/// Owns `fromJson`/`toJson`/`toEntity` (rule 2). Fields are mutable because
/// not-yet-migrated GetX code (location, parcel, taxi) mutates zone/contact
/// fields in place. Convert to the pure [Address] entity via [toEntity] before
/// handing it to the domain/presentation layers.
class AddressModel {
  int? id;
  String? addressType;
  String? contactPersonNumber;
  String? address;
  String? additionalAddress;
  String? latitude;
  String? longitude;
  int? zoneId;
  List<int>? zoneIds;
  String? method;
  String? contactPersonName;
  String? streetNumber;
  String? house;
  String? floor;
  List<ZoneData>? zoneData;
  List<int>? areaIds;
  String? email;

  AddressModel({
    this.id,
    this.addressType,
    this.contactPersonNumber,
    this.address,
    this.additionalAddress,
    this.latitude,
    this.longitude,
    this.zoneId,
    this.zoneIds,
    this.method,
    this.contactPersonName,
    this.streetNumber,
    this.house,
    this.floor,
    this.zoneData,
    this.areaIds,
    this.email,
  });

  AddressModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    addressType = json['address_type'];
    contactPersonNumber = json['contact_person_number']?.toString();
    address = json['address'];
    additionalAddress = json['additional_address'];
    latitude = json['latitude']?.toString();
    longitude = json['longitude']?.toString();
    zoneId = (json['zone_id'] != null && json['zone_id'] != 'null')
        ? int.parse(json['zone_id'].toString())
        : null;
    zoneIds = json['zone_ids']?.cast<int>();
    method = json['_method'];
    contactPersonName = json['contact_person_name'];
    streetNumber = json['road'];
    house = json['house'];
    floor = json['floor'];
    if (json['zone_data'] != null) {
      zoneData = [];
      json['zone_data'].forEach((v) {
        zoneData!.add(ZoneData.fromJson(v));
      });
    }
    areaIds = json['area_ids']?.cast<int>();
    if (json['contact_person_email'] != null) {
      email = json['contact_person_email'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['address_type'] = addressType;
    data['contact_person_number'] = contactPersonNumber;
    data['address'] = address;
    data['additional_address'] = additionalAddress;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['zone_id'] = zoneId;
    data['zone_ids'] = zoneIds;
    data['_method'] = method;
    data['contact_person_name'] = contactPersonName;
    data['road'] = streetNumber;
    data['house'] = house;
    data['floor'] = floor;
    if (zoneData != null) {
      data['zone_data'] = zoneData!.map((v) => v.toJson()).toList();
    }
    data['area_ids'] = areaIds;
    if (email != null) {
      data['contact_person_email'] = email;
    }
    return data;
  }

  /// Build a model from a domain entity (used when a usecase hands us an
  /// [Address] to persist).
  factory AddressModel.fromEntity(Address a) => AddressModel(
    id: a.id,
    addressType: a.addressType,
    contactPersonNumber: a.contactPersonNumber,
    address: a.address,
    additionalAddress: a.additionalAddress,
    latitude: a.latitude,
    longitude: a.longitude,
    zoneId: a.zoneId,
    zoneIds: a.zoneIds,
    method: a.method,
    contactPersonName: a.contactPersonName,
    streetNumber: a.streetNumber,
    house: a.house,
    floor: a.floor,
    areaIds: a.areaIds,
    email: a.email,
  );

  Address toEntity() => Address(
    id: id,
    addressType: addressType,
    contactPersonNumber: contactPersonNumber,
    address: address,
    additionalAddress: additionalAddress,
    latitude: latitude,
    longitude: longitude,
    zoneId: zoneId,
    zoneIds: zoneIds,
    method: method,
    contactPersonName: contactPersonName,
    streetNumber: streetNumber,
    house: house,
    floor: floor,
    areaIds: areaIds,
    email: email,
  );
}
