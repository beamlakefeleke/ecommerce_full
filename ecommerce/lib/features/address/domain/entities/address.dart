import 'package:equatable/equatable.dart';

/// Pure business entity for a saved user address.
///
/// No JSON, no Flutter, no data-layer imports (rule 1). The data layer's
/// [AddressModel] extends this and adds (de)serialization plus the
/// transport-only `zoneData` field.
class Address extends Equatable {
  final int? id;
  final String? addressType;
  final String? contactPersonNumber;
  final String? address;
  final String? additionalAddress;
  final String? latitude;
  final String? longitude;
  final int? zoneId;
  final List<int>? zoneIds;
  final String? method;
  final String? contactPersonName;
  final String? streetNumber;
  final String? house;
  final String? floor;
  final List<int>? areaIds;
  final String? email;

  const Address({
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
    this.areaIds,
    this.email,
  });

  @override
  List<Object?> get props => [
    id,
    addressType,
    contactPersonNumber,
    address,
    additionalAddress,
    latitude,
    longitude,
    zoneId,
    zoneIds,
    method,
    contactPersonName,
    streetNumber,
    house,
    floor,
    areaIds,
    email,
  ];
}
