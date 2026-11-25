import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';
import 'package:ecommerce/helper/address_helper.dart';
import 'package:ecommerce/helper/date_converter.dart';

/// Pure helper — no Flutter, no GetX state. UI helpers that need side-effects
/// (e.g. navigation) remain in the presentation layer.
class StoreHelper {
  const StoreHelper._();

  static bool isStoreClosed(
    bool today,
    bool active,
    List<Schedules>? schedules,
  ) {
    if (!active) return true;
    DateTime date = DateTime.now();
    if (!today) {
      date = date.add(const Duration(days: 1));
    }
    int weekday = date.weekday;
    if (weekday == 7) weekday = 0;
    for (int i = 0; i < (schedules?.length ?? 0); i++) {
      if (weekday == schedules![i].day) return false;
    }
    return true;
  }

  static bool isStoreOpenNow(bool active, List<Schedules>? schedules) {
    if (isStoreClosed(true, active, schedules)) return false;
    int weekday = DateTime.now().weekday;
    if (weekday == 7) weekday = 0;
    for (int i = 0; i < (schedules?.length ?? 0); i++) {
      if (weekday == schedules![i].day &&
          DateConverter.isAvailable(
            schedules[i].openingTime,
            schedules[i].closingTime,
          )) {
        return true;
      }
    }
    return false;
  }

  static bool isOpenNow(Store store) =>
      store.open == 1 && (store.active ?? false);

  static double getDiscount(Store store) => store.discount?.discount ?? 0;

  static String getDiscountType(Store store) =>
      store.discount?.discountType ?? 'percent';

  /// Distance (km) from the user's saved address to a store's LatLng.
  static double getRestaurantDistance(LatLng storeLatLng) {
    final userAddress = AddressHelper.getUserAddressFromSharedPref();
    return Geolocator.distanceBetween(
          storeLatLng.latitude,
          storeLatLng.longitude,
          double.parse(userAddress?.latitude ?? '0'),
          double.parse(userAddress?.longitude ?? '0'),
        ) /
        1000;
  }
}
