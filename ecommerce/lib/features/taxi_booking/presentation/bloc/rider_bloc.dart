import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/features/address/domain/models/address_model.dart';
import 'package:ecommerce/features/location/domain/models/zone_response_model.dart';
import 'package:ecommerce/features/taxi_booking/domain/usecases/get_top_rated_vehicles_list_usecase.dart';
import 'package:ecommerce/features/taxi_booking/domain/usecases/get_running_trip_list_usecase.dart';
import 'package:ecommerce/features/taxi_booking/domain/usecases/get_place_details_usecase.dart';
import 'package:ecommerce/features/taxi_booking/domain/usecases/get_route_between_coordinates_usecase.dart';
import 'package:ecommerce/features/location/domain/services/location_service_interface.dart';
import 'package:ecommerce/features/checkout/domain/services/checkout_service_interface.dart';
import 'package:ecommerce/features/splash/domain/services/splash_service_interface.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/checkout/domain/services/checkout_service_interface.dart';
import 'package:ecommerce/features/checkout/domain/models/distance_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ecommerce/helper/address_helper.dart';
import 'package:ecommerce/helper/date_converter.dart';
import 'package:ecommerce/helper/rider_type.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:get/get.dart';
import 'rider_event.dart';
import 'rider_state.dart';

class RiderBloc extends Bloc<RiderEvent, RiderState> {
  final GetTopRatedVehiclesListUseCase getTopRatedVehiclesListUseCase;
  final GetRunningTripListUseCase getRunningTripListUseCase;
  final GetPlaceDetailsUseCase getPlaceDetailsUseCase;
  final GetRouteBetweenCoordinatesUseCase getRouteBetweenCoordinatesUseCase;
  final LocationServiceInterface locationServiceInterface;
  final CheckoutServiceInterface checkoutServiceInterface;
  final SplashServiceInterface splashServiceInterface;

  final MarkerId _myMarkerId = const MarkerId('my_marker');
  final MarkerId _fromMarkerId = const MarkerId('from_marker');
  final MarkerId _toMarkerId = const MarkerId('to_marker');

  RiderBloc({
    required this.getTopRatedVehiclesListUseCase,
    required this.getRunningTripListUseCase,
    required this.getPlaceDetailsUseCase,
    required this.getRouteBetweenCoordinatesUseCase,
    required this.locationServiceInterface,
    required this.checkoutServiceInterface,
    required this.splashServiceInterface,
  }) : super(RiderInitial(
    initialPosition: LatLng(
      double.parse(Get.find<SplashController>().configModel?.defaultLocation?.lat ?? '0'),
      double.parse(Get.find<SplashController>().configModel?.defaultLocation?.lng ?? '0'),
    ),
  )) {
    on<ClearAddressEvent>(_onClearAddress);
    on<InitSetupEvent>(_onInitSetup);
    on<SetCarTypeEvent>(_onSetCarType);
    on<SetDateEvent>(_onSetDate);
    on<SetTimeEvent>(_onSetTime);
    on<ChangeBannerEvent>(_onChangeBanner);
    on<InitializeDataEvent>(_onInitializeData);
    on<GetRunningTripListEvent>(_onGetRunningTripList);
    on<GetTopRatedVehiclesListEvent>(_onGetTopRatedVehiclesList);
    on<GetInitialLocationEvent>(_onGetInitialLocation);
    on<ClearRideDataEvent>(_onClearRideData);
    on<SetRideStatusEvent>(_onSetRideStatus);
    on<ToggleIsReturnSameLocationEvent>(_onToggleIsReturnSameLocation);
    on<SetLocationFromPlaceEvent>(_onSetLocationFromPlace);
    on<SetFromAddressEvent>(_onSetFromAddress);
    on<SetToAddressEvent>(_onSetToAddress);
  }

  void _onClearAddress(ClearAddressEvent event, Emitter<RiderState> emit) {
    emit(_copyState(
      fromAddress: event.isFrom ? null : state.fromAddress,
      toAddress: event.isFrom ? state.toAddress : null,
    ));
  }

  void _onInitSetup(InitSetupEvent event, Emitter<RiderState> emit) {
    emit(_copyState(
      tripDate: DateConverter.dateToReadableDate(DateTime.now()),
      tripTime: DateConverter.convertTimeToTimeDate(DateTime.now()),
    ));
  }

  void _onSetCarType(SetCarTypeEvent event, Emitter<RiderState> emit) {
    emit(_copyState(carType: event.index));
  }

  Future<void> _onSetDate(SetDateEvent event, Emitter<RiderState> emit) async {
    DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      emit(_copyState(tripDate: DateConverter.dateToReadableDate(pickedDate)));
    } else {
      debugPrint("Date is not selected");
    }
  }

  Future<void> _onSetTime(SetTimeEvent event, Emitter<RiderState> emit) async {
    TimeOfDay? time = await showTimePicker(
      context: event.context,
      initialTime: TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: Get.find<SplashController>().configModel?.timeformat == '24',
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      emit(_copyState(
        tripTime: DateConverter.convertTimeToTimeDate(DateTime(DateTime.now().year, 1, 1, time.hour, time.minute)),
      ));
    }
  }

  void _onChangeBanner(ChangeBannerEvent event, Emitter<RiderState> emit) {
    emit(_copyState(activeBanner: event.index));
  }

  void _onInitializeData(InitializeDataEvent event, Emitter<RiderState> emit) {
    if (kDebugMode) {
      print("riderType_initializeData:${event.riderType}");
    }
    final address = event.address ?? AddressHelper.getUserAddressFromSharedPref();
    emit(_copyState(
      fromAddress: address,
      toAddress: null,
      markers: {},
      polyLines: {},
      rideStatus: RiderType.values.firstWhere((element) => element.name == event.riderType),
      assignedRider: null,
      carDistance: -1,
      carTime: -1,
      isLoading: false,
      riderRating: 0,
    ));
  }

  Future<void> _onGetRunningTripList(GetRunningTripListEvent event, Emitter<RiderState> emit) async {
    if (event.offset == 1) {
      emit(_copyState(runningTrip: null));
    }
    final result = await getRunningTripListUseCase(event.offset);
    result.fold(
      (failure) => emit(RiderError(message: failure.message, initialPosition: state.initialPosition, markers: state.markers, polyLines: state.polyLines, isLoading: state.isLoading, carDistance: state.carDistance, carTime: state.carTime, riderRating: state.riderRating, isReturnSameLocation: state.isReturnSameLocation, carType: state.carType, distance: state.distance, duration: state.duration, activeBanner: state.activeBanner)),
      (tripModel) => emit(_copyState(runningTrip: tripModel)),
    );
  }

  Future<void> _onGetTopRatedVehiclesList(GetTopRatedVehiclesListEvent event, Emitter<RiderState> emit) async {
    if (event.offset == 1) {
      emit(_copyState(topRatedVehicleModel: null));
    }
    final result = await getTopRatedVehiclesListUseCase(event.offset);
    result.fold(
      (failure) => emit(RiderError(message: failure.message, initialPosition: state.initialPosition, markers: state.markers, polyLines: state.polyLines, isLoading: state.isLoading, carDistance: state.carDistance, carTime: state.carTime, riderRating: state.riderRating, isReturnSameLocation: state.isReturnSameLocation, carType: state.carType, distance: state.distance, duration: state.duration, activeBanner: state.activeBanner)),
      (vehicleModel) => emit(_copyState(topRatedVehicleModel: vehicleModel as dynamic)),
    );
  }

  Future<void> _onGetInitialLocation(GetInitialLocationEvent event, Emitter<RiderState> emit) async {
    LatLng newInitialPosition = state.initialPosition;
    try {
      if (event.address == null) {
        await Geolocator.requestPermission();
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        newInitialPosition = LatLng(position.latitude, position.longitude);
      } else {
        newInitialPosition = LatLng(double.parse(event.address!.latitude!), double.parse(event.address!.longitude!));
      }
      
      final Uint8List liveMarkerIcon = await getBytesFromAsset(Images.liveMarker, 70);
      Marker marker = Marker(
        markerId: _myMarkerId,
        position: newInitialPosition,
        icon: BitmapDescriptor.fromBytes(liveMarkerIcon),
      );
      
      final Map<MarkerId, Marker> updatedMarkers = Map.from(state.markers);
      updatedMarkers[_myMarkerId] = marker;
      
      emit(_copyState(
        initialPosition: newInitialPosition,
        markers: updatedMarkers,
      ));
    } catch (_) {}
  }

  void _onClearRideData(ClearRideDataEvent event, Emitter<RiderState> emit) {
    emit(_copyState(markers: {}, polyLines: {}));
  }

  void _onSetRideStatus(SetRideStatusEvent event, Emitter<RiderState> emit) {
    emit(_copyState(rideStatus: event.rideStatus));
  }

  void _onToggleIsReturnSameLocation(ToggleIsReturnSameLocationEvent event, Emitter<RiderState> emit) {
    emit(_copyState(isReturnSameLocation: event.value));
  }

  Future<void> _onSetLocationFromPlace(SetLocationFromPlaceEvent event, Emitter<RiderState> emit) async {
    final result = await getPlaceDetailsUseCase(event.placeID);
    result.fold(
      (failure) {}, // Handle error if needed
      (placeDetails) async {
        if (placeDetails.status == 'OK') {
          AddressModel address0 = AddressModel(
            address: event.address,
            addressType: 'others',
            latitude: placeDetails.result!.geometry!.location!.lat.toString(),
            longitude: placeDetails.result!.geometry!.location!.lng.toString(),
            contactPersonName: AddressHelper.getUserAddressFromSharedPref()!.contactPersonName,
            contactPersonNumber: AddressHelper.getUserAddressFromSharedPref()!.contactPersonNumber,
          );
          
          ZoneResponseModel response0 = await locationServiceInterface.getZone(address0.latitude, address0.longitude, handleError: false);
          if (response0.isSuccess) {
            if (AddressHelper.getUserAddressFromSharedPref()!.zoneIds!.contains(response0.zoneIds[0])) {
              address0.zoneId = response0.zoneIds[0];
              address0.zoneIds = [];
              address0.zoneIds!.addAll(response0.zoneIds);
              address0.zoneData = [];
              address0.zoneData!.addAll(response0.zoneData);
              if (event.isFrom) {
                add(SetFromAddressEvent(addressModel: address0));
              } else {
                add(SetToAddressEvent(addressModel: address0));
              }
            } else {
              showCustomSnackBar('your_selected_location_is_from_different_zone_store'.tr);
            }
          } else {
            showCustomSnackBar(response0.message);
          }
        }
      }
    );
  }

  Future<void> _onSetFromAddress(SetFromAddressEvent event, Emitter<RiderState> emit) async {
    final addressModel = event.addressModel;
    LatLng from = LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!));
    
    final Map<MarkerId, Marker> updatedMarkers = Map.from(state.markers);
    updatedMarkers[_myMarkerId] = Marker(markerId: _myMarkerId, visible: false, position: from);

    final Uint8List fromMarkerIcon = await getBytesFromAsset(Images.liveMarker, 70);
    Marker fromMarker = Marker(
      markerId: _fromMarkerId,
      position: from,
      visible: true,
      icon: BitmapDescriptor.fromBytes(fromMarkerIcon),
    );
    updatedMarkers[_fromMarkerId] = fromMarker;
    
    emit(_copyState(
      fromAddress: addressModel,
      markers: updatedMarkers,
    ));
  }

  Future<void> _onSetToAddress(SetToAddressEvent event, Emitter<RiderState> emit) async {
    final addressModel = event.addressModel;
    
    emit(_copyState(toAddress: addressModel));
    
    if (state.fromAddress != null) {
      LatLng from = LatLng(double.parse(state.fromAddress!.latitude!), double.parse(state.fromAddress!.longitude!));
      LatLng to = LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!));
      
      final Map<MarkerId, Marker> updatedMarkers = Map.from(state.markers);
      updatedMarkers[_myMarkerId] = Marker(markerId: _myMarkerId, visible: false, position: from);
      
      final Uint8List fromMarkerIcon = await getBytesFromAsset(Images.liveMarker, 70);
      final Uint8List toMarkerIcon = await getBytesFromAsset(Images.toMarker, 70);

      Marker fromMarker = Marker(
        markerId: _fromMarkerId,
        position: from,
        visible: true,
        icon: BitmapDescriptor.fromBytes(fromMarkerIcon),
      );
      updatedMarkers[_fromMarkerId] = fromMarker;
      
      Marker toMarker = Marker(
        markerId: _toMarkerId,
        position: to,
        icon: BitmapDescriptor.fromBytes(toMarkerIcon),
      );
      updatedMarkers[_toMarkerId] = toMarker;
      
      List<LatLng> polylineCoordinates = [];
      final result = await getRouteBetweenCoordinatesUseCase(origin: from, destination: to);
      result.fold(
        (failure) {
          showCustomSnackBar('route_not_found'.tr);
        },
        (routesData) {
          if (routesData["status"]?.toLowerCase() == 'ok' && routesData["routes"] != null && routesData["routes"].isNotEmpty) {
            polylineCoordinates.addAll(decodeEncodedPolyline(routesData["routes"][0]["overview_polyline"]["points"]));
          }
        }
      );
      
      final Map<PolylineId, Polyline> updatedPolyLines = Map.from(state.polyLines);
      PolylineId polyId = const PolylineId('my_polyline');
      Polyline polyline = Polyline(
        polylineId: polyId,
        points: polylineCoordinates,
        width: 5,
        color: Theme.of(Get.context!).primaryColor,
      );
      updatedPolyLines[polyId] = polyline;
      
      double distance = 0;
      double duration = 0;
      try {
        final response = await Get.find<CheckoutServiceInterface>().getDistanceInMeter(from, to);
        if (response.statusCode == 200 && response.body['status'] == 'OK') {
          distance = DistanceModel.fromJson(response.body).rows![0].elements![0].distance!.value! / 1000;
          duration = DistanceModel.fromJson(response.body).rows![0].elements![0].duration!.value! / 3600;
        } else {
          distance = Geolocator.distanceBetween(from.latitude, from.longitude, to.latitude, to.longitude) / 1000;
        }
      } catch (e) {
        distance = Geolocator.distanceBetween(from.latitude, from.longitude, to.latitude, to.longitude) / 1000;
      }
      
      emit(_copyState(
        markers: updatedMarkers,
        polyLines: updatedPolyLines,
        distance: distance,
        duration: duration,
      ));
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  List<LatLng> decodeEncodedPolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }

  RiderState _copyState({
    LatLng? initialPosition,
    Map<MarkerId, Marker>? markers,
    Map<PolylineId, Polyline>? polyLines,
    RiderType? rideStatus,
    AddressModel? fromAddress,
    AddressModel? toAddress,
    bool? isLoading,
    double? carDistance,
    dynamic assignedRider,
    double? carTime,
    int? riderRating,
    bool? isReturnSameLocation,
    String? tripDate,
    String? tripTime,
    int? carType,
    double? distance,
    double? duration,
    int? activeBanner,
    dynamic topRatedVehicleModel,
    dynamic runningTrip,
  }) {
    return RiderUpdated(
      initialPosition: initialPosition ?? state.initialPosition,
      markers: markers ?? state.markers,
      polyLines: polyLines ?? state.polyLines,
      rideStatus: rideStatus ?? state.rideStatus,
      fromAddress: fromAddress ?? state.fromAddress,
      toAddress: toAddress ?? state.toAddress,
      isLoading: isLoading ?? state.isLoading,
      carDistance: carDistance ?? state.carDistance,
      assignedRider: assignedRider ?? state.assignedRider,
      carTime: carTime ?? state.carTime,
      riderRating: riderRating ?? state.riderRating,
      isReturnSameLocation: isReturnSameLocation ?? state.isReturnSameLocation,
      tripDate: tripDate ?? state.tripDate,
      tripTime: tripTime ?? state.tripTime,
      carType: carType ?? state.carType,
      distance: distance ?? state.distance,
      duration: duration ?? state.duration,
      activeBanner: activeBanner ?? state.activeBanner,
      topRatedVehicleModel: topRatedVehicleModel ?? state.topRatedVehicleModel,
      runningTrip: runningTrip ?? state.runningTrip,
    );
  }
}
