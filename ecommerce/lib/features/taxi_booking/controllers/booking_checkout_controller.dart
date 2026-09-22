import 'package:get/get.dart';
import 'package:ecommerce/features/profile/domain/models/user_information_body.dart';
import 'package:ecommerce/features/taxi_booking/domain/models/vehicle_model.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/booking_checkout_bloc.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/booking_checkout_event.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/booking_checkout_state.dart';
import 'package:ecommerce/core/di/injection.dart';

export 'package:ecommerce/features/taxi_booking/presentation/bloc/booking_checkout_state.dart' show PageState, PaymentMethodName;

class BookingCheckoutController extends GetxController implements GetxService {
  late final BookingCheckoutBloc bookingCheckoutBloc;

  BookingCheckoutController() {
    bookingCheckoutBloc = getIt<BookingCheckoutBloc>();
    bookingCheckoutBloc.stream.listen((state) {
      update();
    });
  }

  PageState get currentPage => bookingCheckoutBloc.state.currentPage;
  bool get isLoading => bookingCheckoutBloc.state.isLoading;
  PaymentMethodName get selectedPaymentMethod => bookingCheckoutBloc.state.selectedPaymentMethod;
  bool get showCouponSection => bookingCheckoutBloc.state.showCouponSection;
  bool get cancelPayment => bookingCheckoutBloc.state.cancelPayment;
  double? get couponDiscount => bookingCheckoutBloc.state.couponDiscount;
  int get paymentMethodIndex => bookingCheckoutBloc.state.paymentMethodIndex;
  int? get tripId => bookingCheckoutBloc.state.tripId;

  // Needed for UI that uses it as variable
  bool showCoupon = false;

  void setPaymentMethod(int index, {bool isUpdate = true}) {
    bookingCheckoutBloc.add(SetPaymentMethodEvent(index: index, isUpdate: isUpdate));
  }

  void showHideCoupon(){
    showCoupon = !showCoupon; // Keep local sync if UI uses it directly
    bookingCheckoutBloc.add(ShowHideCouponEvent());
  }

  void setCouponDiscount(double? discount){
    bookingCheckoutBloc.add(SetCouponDiscountEvent(discount: discount));
  }

  void cancelPaymentOption(){
    bookingCheckoutBloc.add(CancelPaymentOptionEvent());
  }

  void updateState(PageState currentPage, {bool shouldUpdate = true}){
    bookingCheckoutBloc.add(UpdateStateEvent(currentPage: currentPage, shouldUpdate: shouldUpdate));
  }

  void updateDigitalPaymentOption(PaymentMethodName paymentMethodName, {bool shouldUpdate = true}){
    bookingCheckoutBloc.add(UpdateDigitalPaymentOptionEvent(paymentMethodName: paymentMethodName, shouldUpdate: shouldUpdate));
  }

  Future<bool> placeTrip({required UserInformationBody filterBody, required Vehicles vehicle}) async {
    bookingCheckoutBloc.add(PlaceTripEvent(filterBody: filterBody, vehicle: vehicle));
    // Wait for the state to stop loading
    await for (final state in bookingCheckoutBloc.stream) {
      if (!state.isLoading) {
        return state is! BookingCheckoutError;
      }
    }
    return false;
  }
}