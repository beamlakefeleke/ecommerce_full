class Rider {
  final RiderLatLngEntity? latLng;
  final String? phone;
  final int? id;
  final double? ratings;
  final String? updatedTime;
  final bool? isAvailable;
  final double? heading;
  final String? name;
  final String? image;

  Rider({
    this.latLng,
    this.phone,
    this.id,
    this.ratings,
    this.updatedTime,
    this.isAvailable,
    this.heading,
    this.name,
    this.image,
  });
}

class RiderLatLngEntity {
  final double? lat;
  final double? lng;

  RiderLatLngEntity({this.lat, this.lng});
}
