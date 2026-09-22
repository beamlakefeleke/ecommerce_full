import 'package:ecommerce/features/parcel/domain/entities/place_details.dart';

class PlaceDetailsModel extends PlaceDetails {
  PlaceDetailsModel({super.status, super.result});

  factory PlaceDetailsModel.fromJson(Map<String, dynamic> json) {
    return PlaceDetailsModel(
      status: json['status'],
      result: json['result'] != null ? Result.fromJson(json['result']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (result != null) {
      data['result'] = (result as Result).toJson();
    }
    return data;
  }
}

class Result extends PlaceResult {
  Result({super.name, super.geometry});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      name: json['name'],
      geometry: json['geometry'] != null ? Geometry.fromJson(json['geometry']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (geometry != null) {
      data['geometry'] = (geometry as Geometry).toJson();
    }
    return data;
  }
}

class Geometry extends PlaceGeometry {
  Geometry({super.location});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (location != null) {
      data['location'] = (location as Location).toJson();
    }
    return data;
  }
}

class Location extends PlaceLocation {
  Location({super.lat, super.lng});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lng'] = lng;
    return data;
  }
}
