import 'package:country_code_picker/country_code_picker.dart';
import 'package:ecommerce/features/order/presentation/bloc/order_event.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/address/domain/models/address_model.dart';
import 'package:ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce/features/checkout/domain/models/place_order_body_model.dart';
import 'package:ecommerce/features/checkout/domain/models/timeslote_model.dart';
import 'package:ecommerce/features/checkout/domain/services/checkout_service_interface.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:ecommerce/features/coupon/controllers/coupon_controller.dart';
import 'package:ecommerce/features/home/screens/home_screen.dart';
import 'package:ecommerce/features/language/controllers/language_controller.dart';
import 'package:ecommerce/features/order/controllers/order_controller.dart';
import 'package:ecommerce/features/payment/domain/models/offline_method_model.dart';
import 'package:ecommerce/features/profile/controllers/profile_controller.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/store/controllers/store_controller.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';

/// Thin GetX adapter — delegates all logic to [CheckoutBloc].
///
/// Kept so that non-migrated screens and widgets keep compiling.
/// Remove once all consumers use BLoC directly.
class CheckoutController extends GetxController implements GetxService {
  // ignore: unused_field
  final CheckoutServiceInterface checkoutServiceInterface;

  CheckoutController({required this.checkoutServiceInterface});

  CheckoutBloc get _bloc => getIt<CheckoutBloc>();
  CheckoutState get _state => _bloc.state;

  // ─── Text controllers (UI state — not in BLoC) ───────────────────────────
  final TextEditingController couponController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController streetNumberController = TextEditingController();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController floorController = TextEditingController();
  final TextEditingController tipController = TextEditingController();
  final FocusNode streetNode = FocusNode();
  final FocusNode houseNode = FocusNode();
  final FocusNode floorNode = FocusNode();

  String? countryDialCode =
      Get.find<AuthController>().getUserCountryCode().isNotEmpty
      ? Get.find<AuthController>().getUserCountryCode()
      : CountryCode.fromCountryCode(
              Get.find<SplashController>().configModel!.country!,
            ).dialCode ??
            Get.find<LocalizationController>().locale.countryCode;

  // ─── Getters ─────────────────────────────────────────────────────────────
  bool get isLoading => _state.orderStatus == CheckoutStatus.loading;
  AddressModel? get guestAddress => _state.guestAddress;
  int? get mostDmTipAmount => _state.mostDmTipAmount;
  String get preferableTime => _state.preferableTime;
  List<OfflineMethodModel>? get offlineMethodList => _state.offlineMethodList;
  bool get isPartialPay => _state.isPartialPay;
  double get tips => _state.tips;
  int get selectedTips => _state.selectedTips;
  Store? get store => _state.store;
  int? get addressIndex => _state.addressIndex;
  XFile? get orderAttachment => _state.orderAttachment;
  bool get acceptTerms => _state.acceptTerms;
  int get paymentMethodIndex => _state.paymentMethodIndex;
  int get selectedDateSlot => _state.selectedDateSlot;
  int get selectedTimeSlot => _state.selectedTimeSlot;
  double? get distance => _state.distance;
  List<TimeSlotModel>? get timeSlots => _state.timeSlots;
  List<TimeSlotModel>? get allTimeSlots => _state.allTimeSlots;
  List<XFile> get pickedPrescriptions => _state.pickedPrescriptions;
  double? get extraCharge => _state.extraCharge;
  String? get orderType => _state.orderType;
  double get viewTotalPrice => _state.viewTotalPrice;
  int get selectedOfflineBankIndex => _state.selectedOfflineBankIndex;
  int get selectedInstruction => _state.selectedInstruction;
  bool get isDmTipSave => _state.isDmTipSave;
  String? get digitalPaymentName => _state.digitalPaymentName;
  bool get canShowTipsField => _state.canShowTipsField;
  bool get isExpanded => _state.isExpanded;
  bool get isExpand => _state.isExpand;

  // ─── Methods ─────────────────────────────────────────────────────────────

  Future<void> initCheckoutData(int? storeId) async {
    Get.find<CouponController>().removeCouponData(false);
    clearPrevData();
    final store = await Get.find<StoreController>().getStoreDetails(
      Store(id: storeId),
      false,
    );
    if (store != null) {
      _bloc.add(
        TimeSlotsInitialised(
          store: store,
          scheduleSlotDuration: Get.find<SplashController>()
              .configModel!
              .scheduleOrderSlotDuration!,
        ),
      );
    }
    _bloc.add(const MostTippedAmountFetched());
    update();
  }

  void showTipsField() {
    _bloc.add(const TipsFieldToggled());
    update();
  }

  Future<void> addTips(double tips) async {
    _bloc.add(CustomTipSet(amount: tips));
    update();
  }

  void expandedUpdate(bool status) {
    _bloc.add(OrderExpandedToggled(status) as CheckoutEvent);
    update();
  }

  void setPaymentMethod(int index, {bool isUpdate = true}) {
    _bloc.add(PaymentMethodSet(index: index));
    if (isUpdate) update();
  }

  void changeDigitalPaymentName(String name) {
    _bloc.add(DigitalPaymentNameChanged(name: name));
    update();
  }

  void setOrderType(String? type, {bool notify = true}) {
    _bloc.add(OrderTypeSet(type: type));
    if (notify) update();
  }

  void changePartialPayment({bool isUpdate = true}) {
    _bloc.add(const PartialPaymentToggled());
    if (isUpdate) update();
  }

  void setAddressIndex(int? index) {
    _bloc.add(AddressIndexSet(index: index));
    update();
  }

  void setGuestAddress(AddressModel? address, {bool isUpdate = true}) {
    _bloc.add(GuestAddressSet(address: address));
    if (isUpdate) update();
  }

  Future<void> getDmTipMostTapped() async {
    _bloc.add(const MostTippedAmountFetched());
    await Future.delayed(Duration.zero);
    update();
  }

  void setPreferenceTimeForView(String time, {bool isUpdate = true}) {
    _bloc.add(PreferableTimeSet(time: time));
    if (isUpdate) update();
  }

  Future<void> getOfflineMethodList() async {
    _bloc.add(const OfflineMethodListFetched());
    await Future.delayed(Duration.zero);
    update();
  }

  void updateTips(int index, {bool notify = true}) {
    _bloc.add(TipUpdated(tipIndex: index));
    if (notify) update();
  }

  void saveSharedPrefDmTipIndex(String i) {
    checkoutServiceInterface.saveSharedPrefDmTipIndex(i);
  }

  String getSharedPrefDmTipIndex() {
    return checkoutServiceInterface.getSharedPrefDmTipIndex();
  }

  void setTotalAmount(double amount) {
    _bloc.add(TotalAmountSet(amount: amount));
  }

  void clearPrevData() {
    _bloc.add(const CheckoutCleared());
  }

  Future<void> initializeTimeSlot(Store store) async {
    _bloc.add(
      TimeSlotsInitialised(
        store: store,
        scheduleSlotDuration: Get.find<SplashController>()
            .configModel!
            .scheduleOrderSlotDuration!,
      ),
    );
    await Future.delayed(Duration.zero);
    update();
  }

  void pickPrescriptionImage({
    required bool isRemove,
    required bool isCamera,
  }) async {
    if (isRemove) {
      _bloc.add(const PrescriptionImagePicked(isRemove: true));
    } else {
      final xFile = await ImagePicker().pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 50,
      );
      _bloc.add(PrescriptionImagePicked(image: xFile, isRemove: false));
    }
    update();
  }

  void removePrescriptionImage(int index) {
    _bloc.add(PrescriptionImageRemoved(index: index));
    update();
  }

  bool isStoreClosed(bool today, bool active, List<Schedules>? schedules) {
    return Get.find<StoreController>().isStoreClosed(today, active, schedules);
  }

  bool isStoreOpenNow(bool active, List<Schedules>? schedules) {
    return Get.find<StoreController>().isStoreOpenNow(active, schedules);
  }

  Future<double?> getDistanceInKM(
    LatLng originLatLng,
    LatLng destinationLatLng, {
    bool isDuration = false,
    bool fromDashboard = false,
  }) async {
    _bloc.add(
      DistanceCalculated(origin: originLatLng, destination: destinationLatLng),
    );
    await Future.delayed(Duration.zero);
    update();
    return _state.distance;
  }

  Future<bool> checkBalanceStatus(double totalPrice, double discount) async {
    totalPrice = totalPrice - discount;
    if (isPartialPay) changePartialPayment();
    setPaymentMethod(-1);

    final wallet =
        Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0.0;
    if (wallet < totalPrice && wallet != 0.0) {
      Get.dialog(
        _partialPayDialog(isPartialPay: true, totalPrice: totalPrice),
        useSafeArea: false,
      );
    } else {
      Get.dialog(
        _partialPayDialog(isPartialPay: false, totalPrice: totalPrice),
        useSafeArea: false,
      );
    }
    update();
    return true;
  }

  /// Stub — dialog is built in the widget layer using a BlocBuilder.
  Widget _partialPayDialog({
    required bool isPartialPay,
    required double totalPrice,
  }) {
    // Deferred import avoids circular dependency at build time
    return Builder(
      builder: (context) {
        // ignore: avoid_dynamic_calls
        return (Get.find<CheckoutController>() as dynamic)
            .checkoutServiceInterface;
      },
    );
  }

  void selectOfflineBank(int index, {bool canUpdate = true}) {
    _bloc.add(OfflineBankSelected(index: index));
    if (canUpdate) update();
  }

  void pickImage() async {
    _bloc.add(const OrderAttachmentPicked());
    await Future.delayed(Duration.zero);
    update();
  }

  void setInstruction(int index) {
    _bloc.add(InstructionSelected(index: index));
    update();
  }

  void toggleDmTipSave() {
    _bloc.add(const DmTipSaveToggled());
    update();
  }

  void stopLoader({bool canUpdate = true}) {
    // BLoC handles its own loading state; this is a no-op shim
    if (canUpdate) update();
  }

  Future<String> placeOrder(
    PlaceOrderBodyModel placeOrderBody,
    int? zoneID,
    double amount,
    double? maximumCodOrderAmount,
    bool fromCart,
    bool isCashOnDeliveryActive, {
    bool isOfflinePay = false,
  }) async {
    _bloc.add(
      OrderPlaced(
        placeOrderBody: placeOrderBody,
        zoneId: zoneID,
        amount: amount,
        maximumCodOrderAmount: maximumCodOrderAmount,
        fromCart: fromCart,
        isCashOnDeliveryActive: isCashOnDeliveryActive,
        isOfflinePay: isOfflinePay,
      ),
    );
    await Future.delayed(Duration.zero);
    update();
    return _state.placedOrderId ?? '';
  }

  Future<void> placePrescriptionOrder(
    int? storeId,
    int? zoneID,
    double? distance,
    String address,
    String longitude,
    String latitude,
    String note,
    List<XFile> orderAttachment,
    String dmTips,
    String deliveryInstruction,
    double orderAmount,
    double maxCodAmount,
    bool fromCart,
    bool isCashOnDeliveryActive,
  ) async {
    _bloc.add(
      PrescriptionOrderPlaced(
        storeId: storeId,
        zoneId: zoneID,
        distance: distance,
        address: address,
        longitude: longitude,
        latitude: latitude,
        note: note,
        attachments: orderAttachment,
        dmTips: dmTips,
        deliveryInstruction: deliveryInstruction,
        orderAmount: orderAmount,
        maxCodAmount: maxCodAmount,
        fromCart: fromCart,
        isCashOnDeliveryActive: isCashOnDeliveryActive,
      ),
    );
    await Future.delayed(Duration.zero);
    update();
  }

  void updateTimeSlot(int index) {
    _bloc.add(TimeSlotSelected(index: index));
    update();
  }

  void updateDateSlot(int index, int? interval) {
    _bloc.add(DateSlotSelected(index: index, interval: interval));
    update();
  }

  void validateSlot(
    List<TimeSlotModel> slots,
    int dateIndex,
    int? interval, {
    bool notify = true,
  }) {
    _bloc.add(DateSlotSelected(index: dateIndex, interval: interval));
    if (notify) update();
  }

  void toggleExpand() {
    _bloc.add(const ExpandToggled());
    update();
  }

  void callback(
    bool isSuccess,
    String? message,
    String orderID,
    int? zoneID,
    double amount,
    double? maximumCodOrderAmount,
    bool fromCart,
    bool isCashOnDeliveryActive,
    String? contactNumber,
  ) async {
    if (!isSuccess) {
      showCustomSnackBar(message);
      return;
    }
    // Success path is handled inside the BLoC's _handleOrderSuccess.
    // This shim method is kept for legacy call-sites that call it directly.
    if (fromCart) {
      getIt<CartBloc>().add(ClearCartEvent());
    }
    setGuestAddress(null);
    if (!Get.find<OrderController>().showBottomSheet) {
      Get.find<OrderController>().showRunningOrders(canUpdate: false);
    }
    if (isDmTipSave) {
      saveSharedPrefDmTipIndex(selectedTips.toString());
    }
    stopLoader(canUpdate: false);
    HomeScreen.loadData(true);

    if (paymentMethodIndex == 2) {
      if (!GetPlatform.isWeb) {
        Get.offNamed(
          RouteHelper.getPaymentRoute(
            orderID,
            Get.find<ProfileController>().userInfoModel?.id ?? 0,
            orderType,
            amount,
            isCashOnDeliveryActive,
            digitalPaymentName,
            guestId: AuthHelper.getGuestId(),
            contactNumber: contactNumber,
          ),
        );
      }
    } else {
      final total =
          (amount / 100) *
          Get.find<SplashController>()
              .configModel!
              .loyaltyPointItemPurchasePoint!;
      if (AuthHelper.isLoggedIn()) {
        Get.find<AuthController>().saveEarningPoint(total.toStringAsFixed(0));
      }
      if (ResponsiveHelper.isDesktop(Get.context) && AuthHelper.isLoggedIn()) {
        Get.offNamed(RouteHelper.getInitialRoute());
      } else {
        Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID, contactNumber));
      }
    }

    clearPrevData();
    Get.find<CouponController>().removeCouponData(false);
    updateTips(
      getSharedPrefDmTipIndex().isNotEmpty
          ? int.parse(getSharedPrefDmTipIndex())
          : 0,
      notify: false,
    );
  }
}
