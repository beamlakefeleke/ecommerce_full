import 'dart:async';
import 'dart:ui' as ui;
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animarker/widgets/animarker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/rider_bloc.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/rider_event.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/rider_state.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/features/taxi_booking/models/vehicle_model.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/rider_type.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/features/taxi_booking/select_map_location/widgets/rider_address_input_field.dart';
import 'widgets/available_service_info.dart';
import 'widgets/car_will_arrived_info.dart';

class SelectMapLocation extends StatefulWidget {
  final String? riderType;
  final AddressModel? address;
  final Vehicles? vehicle;
  const SelectMapLocation({
    super.key,
    required this.riderType,
    required this.address,
    this.vehicle,
  });

  @override
  State<SelectMapLocation> createState() => _SelectMapLocationState();
}

class _SelectMapLocationState extends State<SelectMapLocation> {
  GoogleMapController? _mapController;
  final Map<MarkerId, Marker> _markers = {};

  static const MarkerId _myMarkerId = MarkerId('my_marker');
  static const MarkerId _fromMarkerId = MarkerId('from_marker');
  static const MarkerId _toMarkerId = MarkerId('to_marker');

  @override
  void initState() {
    super.initState();
    final bloc = context.read<RiderBloc>();
    bloc.add(
      RiderDataInitialized(
        riderType: widget.riderType,
        address: widget.address,
      ),
    );
    _resolveInitialLocation(widget.address);
  }

  /// Resolves the camera position (current GPS when no address) and tells the
  /// bloc. The map controller + markers stay in the widget layer.
  Future<void> _resolveInitialLocation(AddressModel? address) async {
    LatLng position;
    try {
      if (address == null) {
        await Geolocator.requestPermission();
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        position = LatLng(pos.latitude, pos.longitude);
      } else {
        position = LatLng(
          double.parse(address.latitude!),
          double.parse(address.longitude!),
        );
      }
      if (!mounted) return;
      context.read<RiderBloc>().add(InitialPositionSet(position));
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 16));
      final icon = await _bitmap(Images.liveMarker, 70);
      setState(() {
        _markers[_myMarkerId] = Marker(
          markerId: _myMarkerId,
          position: position,
          icon: icon,
        );
      });
    } catch (_) {}
  }

  Future<BitmapDescriptor> _bitmap(String path, int width) async {
    final ByteData data = await rootBundle.load(path);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final bytes = (await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(bytes);
  }

  /// Rebuilds from/to markers and the camera bounds when the addresses change.
  Future<void> _syncMarkers(RiderState state) async {
    final from = state.fromLatLng;
    final to = state.toLatLng;
    if (from != null) {
      final fromIcon = await _bitmap(Images.liveMarker, 70);
      _markers[_fromMarkerId] = Marker(
        markerId: _fromMarkerId,
        position: from,
        icon: fromIcon,
      );
    }
    if (to != null) {
      final toIcon = await _bitmap(Images.toMarker, 70);
      _markers[_toMarkerId] = Marker(
        markerId: _toMarkerId,
        position: to,
        icon: toIcon,
      );
    }
    if (from != null && to != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(_boundsFor([from, to]), 100),
      );
    }
    if (mounted) setState(() {});
  }

  LatLngBounds _boundsFor(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (final LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context)
          ? null
          : CustomAppBar(title: 'location'.tr),
      body: BlocConsumer<RiderBloc, RiderState>(
        listenWhen: (previous, current) =>
            previous.fromAddress != current.fromAddress ||
            previous.toAddress != current.toAddress ||
            previous.actionStatus != current.actionStatus,
        listener: (context, state) {
          _syncMarkers(state);
          if (state.actionStatus == RiderActionStatus.failure &&
              state.actionMessage != null) {
            showCustomSnackBar(state.actionMessage!.tr);
          }
        },
        builder: (context, riderController) {
          final Completer<GoogleMapController> mapCompleter =
              Completer<GoogleMapController>();
          if (_mapController != null) {
            mapCompleter.complete(_mapController);
          }
          final Set<Polyline> polylines = riderController.routePoints.isEmpty
              ? <Polyline>{}
              : {
                  Polyline(
                    polylineId: const PolylineId('my_polyline'),
                    points: riderController.routePoints,
                    width: 5,
                    color: Theme.of(context).primaryColor,
                  ),
                };
          return ExpandableBottomSheet(
            background: Stack(
              children: [
                Animarker(
                  curve: Curves.easeIn,
                  rippleRadius: 0.2,
                  useRotation: true,
                  duration: const Duration(milliseconds: 2300),
                  mapId: mapCompleter.future.then<int>((value) => value.mapId),
                  markers: _markers.values.toSet(),
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: riderController.initialPosition,
                      zoom: 15,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      _resolveInitialLocation(widget.address);
                    },
                    polylines: polylines,
                  ),
                ),

                (riderController.rideStatus == RiderType.initial)
                    ? Positioned(
                        right: 10,
                        bottom: 120,
                        child: Column(
                          children: [
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
                                ),
                                color: Theme.of(context).cardColor,
                              ),
                              child: InkWell(
                                onTap: () => _mapController?.animateCamera(
                                  CameraUpdate.zoomIn(),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 20,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeDefault,
                            ),
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
                                ),
                                color: Theme.of(context).cardColor,
                              ),
                              child: InkWell(
                                onTap: () => _mapController?.animateCamera(
                                  CameraUpdate.zoomOut(),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 20,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeDefault,
                            ),
                            InkWell(
                              onTap: () => _resolveInitialLocation(null),
                              child: Container(
                                padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).cardColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(
                                        context,
                                      ).disabledColor.withOpacity(0.5),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.my_location,
                                  size: 28,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(),

                Positioned(
                  top: Dimensions.paddingSizeSmall,
                  left: Dimensions.paddingSizeLarge,
                  right: Dimensions.paddingSizeLarge,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      riderController.rideStatus == RiderType.initial
                          ? const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RiderAddressInputField(isFormAddress: true),
                                SizedBox(height: Dimensions.paddingSizeSmall),

                                RiderAddressInputField(isFormAddress: false),
                              ],
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
            persistentContentHeight: 310,
            expandableContent: riderController.rideStatus == null
                ? const SizedBox()
                : _expandableContent(
                    riderController.rideStatus!,
                    riderController,
                    widget.vehicle,
                  ),
          );
        },
      ),
    );
  }

  Widget _expandableContent(
    RiderType riderType,
    RiderState riderController,
    Vehicles? vehicle,
  ) {
    switch (riderType) {
      case RiderType.availableCar:
        return AvailableServiceInfo(vehicle: vehicle);
      case RiderType.willArrived:
        return const CarWillArrivedInfo();

      default:
        return BlocBuilder<RiderBloc, RiderState>(
          builder: (context, state) {
            final bool canConfirm = state.toAddress != null;
            return Container(
              height: 85,
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomButton(
                  onPressed: !canConfirm
                      ? null
                      : () => context.read<RiderBloc>().add(
                          const RideStatusSet(RiderType.availableCar),
                        ),
                  buttonText: 'confirm'.tr,
                ),
              ),
            );
          },
        );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
