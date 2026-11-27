import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce/features/location/presentation/bloc/location_bloc.dart';
import 'package:ecommerce/features/location/presentation/bloc/location_event.dart';
import 'package:ecommerce/features/location/presentation/bloc/location_state.dart';
import 'package:ecommerce/features/location/presentation/helper/location_helper.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_event.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/helper/address_helper.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/features/location/presentation/widgets/serach_location_widget.dart';

class PickMapScreen extends StatefulWidget {
  final bool fromSignUp;
  final bool fromAddAddress;
  final bool canRoute;
  final String? route;
  final GoogleMapController? googleMapController;
  final Function(AddressModel address)? onPicked;
  final bool fromLandingPage;
  const PickMapScreen({
    super.key,
    required this.fromSignUp,
    required this.fromAddAddress,
    required this.canRoute,
    required this.route,
    this.googleMapController,
    this.onPicked,
    this.fromLandingPage = false,
  });

  @override
  State<PickMapScreen> createState() => _PickMapScreenState();
}

class _PickMapScreenState extends State<PickMapScreen> {
  GoogleMapController? _mapController;
  CameraPosition? _cameraPosition;
  late LatLng _initialPosition;

  LocationBloc get _bloc => getIt<LocationBloc>();

  @override
  void initState() {
    super.initState();

    if (widget.fromAddAddress) {
      _bloc.add(const PickDataSeeded());
    }
    final defaultLocation =
        getIt<SplashBloc>().state.configModel?.defaultLocation;
    _initialPosition = LatLng(
      double.parse(defaultLocation?.lat ?? '0'),
      double.parse(defaultLocation?.lng ?? '0'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResponsiveHelper.isDesktop(context)
          ? Colors.transparent
          : Theme.of(context).cardColor,
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: Center(
          child: Container(
            height: ResponsiveHelper.isDesktop(context) ? 600 : null,
            width: ResponsiveHelper.isDesktop(context)
                ? 700
                : Dimensions.webMaxWidth,
            decoration: context.width > 700
                ? BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  )
                : null,
            child: BlocBuilder<LocationBloc, LocationState>(
              bloc: _bloc,
              builder: (context, state) {
                return ResponsiveHelper.isDesktop(context)
                    ? _buildDesktop(context, state)
                    : _buildMobile(context, state);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context, LocationState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeSmall,
        horizontal: Dimensions.paddingSizeLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.clear),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text('type_your_address_here_to_pick_form_map'.tr, style: robotoBold),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          SearchLocationWidget(
            mapController: _mapController,
            pickedAddress: state.pickAddress,
            isEnabled: null,
            fromDialog: true,
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          SizedBox(
            height: 350,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: _buildMap(context, state),
                ),
                Center(
                  child: !state.loading
                      ? Image.asset(Images.pickMarker, height: 50, width: 50)
                      : const CircularProgressIndicator(),
                ),
                Positioned(
                  bottom: 30,
                  right: Dimensions.paddingSizeLarge,
                  child: _myLocationButton(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          CustomButton(
            isBold: false,
            radius: Dimensions.radiusSmall,
            buttonText: _buttonText(state),
            isLoading: state.isLoading,
            onPressed: _confirmEnabled(state)
                ? () => _onPickPressed(context, state)
                : (state.isLoading ? () {} : null),
          ),
        ],
      ),
    );
  }

  Widget _buildMobile(BuildContext context, LocationState state) {
    return Stack(
      children: [
        _buildMap(context, state),
        Center(
          child: !state.loading
              ? Image.asset(Images.pickMarker, height: 50, width: 50)
              : const CircularProgressIndicator(),
        ),
        Positioned(
          top: Dimensions.paddingSizeLarge,
          left: Dimensions.paddingSizeSmall,
          right: Dimensions.paddingSizeSmall,
          child: SearchLocationWidget(
            mapController: _mapController,
            pickedAddress: state.pickAddress,
            isEnabled: null,
          ),
        ),
        Positioned(
          bottom: 80,
          right: Dimensions.paddingSizeLarge,
          child: _myLocationButton(context),
        ),
        Positioned(
          bottom: Dimensions.paddingSizeLarge,
          left: Dimensions.paddingSizeLarge,
          right: Dimensions.paddingSizeLarge,
          child: CustomButton(
            buttonText: _buttonText(state),
            isLoading: state.isLoading,
            onPressed: _confirmEnabled(state)
                ? () => _onPickPressed(context, state)
                : (state.isLoading ? () {} : null),
          ),
        ),
      ],
    );
  }

  Widget _buildMap(BuildContext context, LocationState state) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.fromAddAddress
            ? LatLng(state.position.latitude, state.position.longitude)
            : _initialPosition,
        zoom: 16,
      ),
      minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
      myLocationButtonEnabled: false,
      onMapCreated: (GoogleMapController mapController) {
        _mapController = mapController;
        _bloc.setMapController(mapController);
        if (!widget.fromAddAddress) {
          _bloc.add(const CurrentLocationRequested(fromAddress: false));
        }
      },
      scrollGesturesEnabled: !Get.isDialogOpen!,
      zoomControlsEnabled: false,
      onCameraMove: (CameraPosition cameraPosition) {
        _cameraPosition = cameraPosition;
      },
      onCameraMoveStarted: () => _bloc.add(const ButtonDisabled()),
      onCameraIdle: () =>
          _bloc.add(CameraPositionUpdated(_cameraPosition, false)),
    );
  }

  Widget _myLocationButton(BuildContext context) {
    return FloatingActionButton(
      mini: true,
      backgroundColor: Theme.of(context).cardColor,
      onPressed: () => LocationHelper.checkPermission(() {
        _bloc.add(const CurrentLocationRequested(fromAddress: false));
      }),
      child: Icon(Icons.my_location, color: Theme.of(context).primaryColor),
    );
  }

  String _buttonText(LocationState state) => state.inZone
      ? widget.fromAddAddress
            ? 'pick_address'.tr
            : 'pick_location'.tr
      : 'service_not_available_in_this_area'.tr;

  bool _confirmEnabled(LocationState state) =>
      !state.isLoading && !state.buttonDisabled && !state.loading;

  void _onPickPressed(BuildContext context, LocationState state) {
    if (state.pickPosition.latitude == 0 ||
        (state.pickAddress?.isEmpty ?? true)) {
      showCustomSnackBar('pick_an_address'.tr);
      return;
    }

    if (widget.onPicked != null) {
      final saved = AddressHelper.getUserAddressFromSharedPref();
      final AddressModel address = AddressModel(
        latitude: state.pickPosition.latitude.toString(),
        longitude: state.pickPosition.longitude.toString(),
        addressType: 'others',
        address: state.pickAddress,
        contactPersonName: saved?.contactPersonName,
        contactPersonNumber: saved?.contactPersonNumber,
      );
      widget.onPicked!(address);
      Get.back();
      return;
    }

    if (widget.fromAddAddress) {
      if (widget.googleMapController != null) {
        widget.googleMapController!.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                state.pickPosition.latitude,
                state.pickPosition.longitude,
              ),
              zoom: 16,
            ),
          ),
        );
        _bloc.add(const AddAddressDataSet());
      }
      Get.back();
      return;
    }

    final AddressModel address = AddressModel(
      latitude: state.pickPosition.latitude.toString(),
      longitude: state.pickPosition.longitude.toString(),
      addressType: 'others',
      address: state.pickAddress,
    );

    if (widget.fromLandingPage &&
        !AuthHelper.isGuestLoggedIn() &&
        !AuthHelper.isLoggedIn()) {
      getIt<AuthRepository>().guestLogin().then((result) {
        result.fold((_) {}, (_) {
          getIt<ProfileBloc>().add(const ProfileCleared());
          Get.back();
          LocationHelper.saveAddressAndNavigate(
            address,
            widget.fromSignUp,
            widget.route,
            widget.canRoute,
            ResponsiveHelper.isDesktop(context),
          );
        });
      });
    } else {
      if (widget.fromLandingPage) {
        Get.back();
      }
      LocationHelper.saveAddressAndNavigate(
        address,
        widget.fromSignUp,
        widget.route,
        widget.canRoute,
        ResponsiveHelper.isDesktop(context),
      );
    }
  }
}
