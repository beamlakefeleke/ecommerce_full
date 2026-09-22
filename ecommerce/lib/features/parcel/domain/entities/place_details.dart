class PlaceDetails {
  final String? status;
  final PlaceResult? result;

  PlaceDetails({this.status, this.result});
}

class PlaceResult {
  final String? name;
  final PlaceGeometry? geometry;

  PlaceResult({this.name, this.geometry});
}

class PlaceGeometry {
  final PlaceLocation? location;

  PlaceGeometry({this.location});
}

class PlaceLocation {
  final double? lat;
  final double? lng;

  PlaceLocation({this.lat, this.lng});
}
