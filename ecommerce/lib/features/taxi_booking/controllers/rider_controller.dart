import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ecommerce/features/address/domain/models/address_model.dart';
import 'package:ecommerce/helper/rider_type.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/rider_bloc.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/rider_event.dart';
import 'package:ecommerce/features/taxi_booking/domain/models/vehicle_model.dart';
import 'package:ecommerce/features/taxi_booking/domain/models/trip_model.dart';
import 'package:ecommerce/features/taxi_booking/domain/models/rider_model.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/core/di/injection.dart';

class RiderController extends GetxController implements GetxService {
  late final RiderBloc riderBloc;
  
  RiderController() {
    riderBloc = getIt<RiderBloc>();
    riderBloc.stream.listen((state) {
      update();
    });
  }

  GoogleMapController? _mapController;
  final TextEditingController _formTextEditingController = TextEditingController();
  final TextEditingController _toTextEditingController = TextEditingController();

  List<String> banners = [Images.banner1, Images.banner2];

  LatLng get initialPosition => riderBloc.state.initialPosition;
  GoogleMapController? get mapController => _mapController;
  Map<MarkerId, Marker> get markers => riderBloc.state.markers;
  Map<PolylineId, Polyline> get polyLines => riderBloc.state.polyLines;
  RiderType? get rideStatus => riderBloc.state.rideStatus;
  AddressModel? get fromAddress => riderBloc.state.fromAddress;
  AddressModel? get toAddress => riderBloc.state.toAddress;
  bool get isLoading => riderBloc.state.isLoading;
  double? get carDistance => riderBloc.state.carDistance;
  RiderModel? get assignedRider => riderBloc.state.assignedRider;
  double? get carTime => riderBloc.state.carTime;
  int get riderRating => riderBloc.state.riderRating;
  bool get isReturnSameLocation => riderBloc.state.isReturnSameLocation;
  int get activeBanner => riderBloc.state.activeBanner;
  String? get tripDate => riderBloc.state.tripDate;
  String? get tripTime => riderBloc.state.tripTime;
  int get carType => riderBloc.state.carType;
  double? get distance => riderBloc.state.distance;
  double? get duration => riderBloc.state.duration;
  VehicleModel? get topRatedVehicleModel => riderBloc.state.topRatedVehicleModel;
  TripModel? get runningTrip => riderBloc.state.runningTrip;
  TextEditingController get formTextEditingController => _formTextEditingController;
  TextEditingController get toTextEditingController => _toTextEditingController;

  void clearAddress(bool isFrom){
    if(isFrom){
      _formTextEditingController.text = '';
    }else{
      _toTextEditingController.text = '';
    }
    riderBloc.add(ClearAddressEvent(isFrom: isFrom));
  }

  void initSetup(){
    riderBloc.add(InitSetupEvent());
  }

  void setCarType(int index) {
    riderBloc.add(SetCarTypeEvent(index: index));
  }

  Future<void> setDate() async {
    riderBloc.add(SetDateEvent());
  }

  Future<void> setTime(BuildContext context) async {
    riderBloc.add(SetTimeEvent(context: context));
  }

  void changeBanner(int index){
    riderBloc.add(ChangeBannerEvent(index: index));
  }

  void initializeData(String? riderType, AddressModel? address) {
    _formTextEditingController.text = address?.address ?? '';
    _toTextEditingController.text = '';
    riderBloc.add(InitializeDataEvent(riderType: riderType, address: address));
  }

  void setMapController(GoogleMapController mapController) {
    _mapController = mapController;
  }

  Future<void> getRunningTripList(int offset, {bool isUpdate = false}) async{
    riderBloc.add(GetRunningTripListEvent(offset: offset, isUpdate: isUpdate));
  }

  Future<void> getTopRatedVehiclesList(int offset, {bool isUpdate = false}) async{
    riderBloc.add(GetTopRatedVehiclesListEvent(offset: offset, isUpdate: isUpdate));
  }

  Future<Position?> getInitialLocation(AddressModel? address) async {
    riderBloc.add(GetInitialLocationEvent(address: address));
    if (address == null) {
       return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    }
    return null;
  }

  void clearRideData() {
    riderBloc.add(ClearRideDataEvent());
  }

  void setRideStatus(RiderType rideStatus,{bool shouldUpdate = true}) {
    riderBloc.add(SetRideStatusEvent(rideStatus: rideStatus, shouldUpdate: shouldUpdate));
  }

  void toggleIsReturnSameLocation(bool value){
    riderBloc.add(ToggleIsReturnSameLocationEvent(value: value));
  }

  void setLocationFromPlace(String? placeID, String? address, bool isFrom) async {
    riderBloc.add(SetLocationFromPlaceEvent(placeID: placeID, address: address, isFrom: isFrom));
    // Notice: TextEditingController updates need to be listened to state changes. 
    // In GetX thin adapter, we will rely on UI rebuilding and taking AddressModel string, 
    // but we can manually sync it if needed. For now the BLoC will handle the logic and we rely on GetBuilder to rebuild.
  }

  Future<void> setFromAddress(AddressModel addressModel) async {
    _formTextEditingController.text = addressModel.address!;
    riderBloc.add(SetFromAddressEvent(addressModel: addressModel));
  }

  Future<void> setToAddress(AddressModel addressModel) async {
    _toTextEditingController.text = addressModel.address!;
    riderBloc.add(SetToAddressEvent(addressModel: addressModel));
  }

  void setFromToMarker({required LatLng from, required LatLng to}) async {
    // The BLoC already calculates markers and polylines when setToAddress is called.
    // This is just to update the map bounds in the UI.
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(boundsFromLatLngList([from, to]), 100));
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > (x1 ?? 0)) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > (y1 ?? 0)) y1 = latLng.longitude;
        if (latLng.longitude < (y0 ?? 0)) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }
}