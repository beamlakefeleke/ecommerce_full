import 'package:get/get.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce/features/profile/controllers/profile_controller.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';

/// Stateless side-effect helper for the parcel feature. Holds the navigation
/// logic that used to live in `ParcelController.parcelCallback`. No API calls,
/// no state — navigation + the dm-tip persist only (navigation allowed per
/// rule 5 until go_router lands; snackbars stay in the UI listener).
class ParcelHelper {
  const ParcelHelper._();

  /// Runs after a successful parcel place-order. Mirrors the success branch of
  /// the legacy `parcelCallback`: optionally persists the dm-tip index, then
  /// routes to the payment screen (digital, paymentIndex == 2) or to the
  /// order-success screen.
  ///
  /// Returns void; the failure branch (snackbar) is handled by the caller's
  /// `BlocListener` since snackbars must not live in domain code.
  static void onOrderPlaced({
    required String orderId,
    required int paymentIndex,
    required String? digitalPaymentName,
    required double orderAmount,
    required bool isCashOnDeliveryActive,
    required bool isDmTipSave,
    required int selectedTips,
    required String? contactNumber,
  }) {
    if (isDmTipSave) {
      getIt<AuthRepository>().saveDmTipIndex(selectedTips.toString());
    }

    if (paymentIndex == 2) {
      Get.offNamed(
        RouteHelper.getPaymentRoute(
          orderId,
          Get.find<ProfileController>().userInfoModel?.id ??
              int.tryParse(AuthHelper.getGuestId()) ??
              0,
          'parcel',
          orderAmount,
          isCashOnDeliveryActive,
          digitalPaymentName,
          guestId: AuthHelper.getGuestId(),
          contactNumber: contactNumber,
        ),
      );
    } else {
      Get.offNamed(RouteHelper.getOrderSuccessRoute(orderId, contactNumber));
    }
  }
}
