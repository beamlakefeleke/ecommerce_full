import '../entities/rider.dart';

class RiderModel extends Rider {
  RiderModel({
    super.latLng,
    super.phone,
    super.id,
    super.ratings,
    super.updatedTime,
    super.isAvailable,
    super.heading,
    super.name,
    super.image,
  });

  factory RiderModel.fromJson(Map<Object, Object> j) {
    Map<String, dynamic> json = Map.from(j);
    return RiderModel(
      latLng: json['latLng'] != null ? RiderLatLng.fromJson(json['latLng']) : null,
      phone: json['phone'],
      id: json['id'],
      ratings: json['ratings']?.toDouble(),
      updatedTime: json['updated_time'],
      isAvailable: json['isAvailable'],
      heading: json['heading']?.toDouble(),
      name: json['name'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (latLng != null) {
      data['latLng'] = (latLng as RiderLatLng).toJson();
    }
    data['phone'] = phone;
    data['id'] = id;
    data['ratings'] = ratings;
    data['updated_time'] = updatedTime;
    data['isAvailable'] = isAvailable;
    data['heading'] = heading;
    data['name'] = name;
    data['image'] = image;
    return data;
  }
}

class RiderLatLng extends RiderLatLngEntity {
  RiderLatLng({
    super.lat,
    super.lng,
  });

  factory RiderLatLng.fromJson(List<Object> json) {
    return RiderLatLng(
      lat: json[0] as double,
      lng: json[1] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '0': lat,
      '1': lng,
    };
  }
}
