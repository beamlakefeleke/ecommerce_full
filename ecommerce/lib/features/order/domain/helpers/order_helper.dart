import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Stateless side-effect helper for the order feature. Holds the pure
/// navigation logic that used to live on `OrderService`/`OrderController`
/// (payment-gateway redirect handling). No API calls, no state — navigation
/// only (allowed per rule 5 until go_router lands).
class OrderHelper {
  const OrderHelper._();

  /// Inspects a payment-gateway webview [url] and, on a terminal
  /// success/fail/cancel URL, closes the webview and routes onward. Mirrors the
  /// legacy `OrderService.paymentRedirect` exactly.
  static void paymentRedirect({
    required String url,
    required bool canRedirect,
    required String? contactNumber,
    required Function onClose,
    required String? addFundUrl,
    required String orderID,
  }) {
    final bool forOrder = (addFundUrl == '' && addFundUrl!.isEmpty);

    if (!canRedirect) return;

    final bool isSuccess = forOrder
        ? url.startsWith('${AppConstants.baseUrl}/payment-success')
        : url.contains('success') && url.contains(AppConstants.baseUrl);
    final bool isFailed = forOrder
        ? url.startsWith('${AppConstants.baseUrl}/payment-fail')
        : url.contains('fail') && url.contains(AppConstants.baseUrl);
    final bool isCancel = forOrder
        ? url.startsWith('${AppConstants.baseUrl}/payment-cancel')
        : url.contains('cancel') && url.contains(AppConstants.baseUrl);

    if (isSuccess || isFailed || isCancel) {
      onClose();
    }

    if (forOrder) {
      if (isSuccess || isFailed || isCancel) {
        Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID, contactNumber));
      }
    } else {
      if (isSuccess || isFailed || isCancel) {
        if (Get.currentRoute.contains(RouteHelper.payment)) {
          Get.back();
        }
        Get.back();
        Get.toNamed(
          RouteHelper.getWalletRoute(
            fundStatus: isSuccess
                ? 'success'
                : isFailed
                ? 'fail'
                : 'cancel',
            token: UniqueKey().toString(),
          ),
        );
      }
    }
  }
}
