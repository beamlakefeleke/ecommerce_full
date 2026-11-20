import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';
import 'package:ecommerce/helper/date_converter.dart';

/// Pure stateless sort/filter logic ported from [SearchService]. No IO, no
/// Flutter, no state — called from the bloc (or testable standalone).
class SearchSortHelper {
  const SearchSortHelper._();

  static List<Item> sortItems({
    required List<Item> all,
    required double lowerValue,
    required double upperValue,
    required int rating,
    required bool veg,
    required bool nonVeg,
    required bool isAvailable,
    required bool isDiscounted,
    required int sortIndex,
  }) {
    List<Item> result = List<Item>.from(all);
    if (upperValue > 0) {
      result.removeWhere(
        (p) => p.price! <= lowerValue || p.price! > upperValue,
      );
    }
    if (rating != -1) result.removeWhere((p) => p.avgRating! < rating);
    if (!veg && nonVeg) result.removeWhere((p) => p.veg == 1);
    if (!nonVeg && veg) result.removeWhere((p) => p.veg == 0);
    if (isAvailable) {
      result.removeWhere(
        (p) => !DateConverter.isAvailable(
          p.availableTimeStarts,
          p.availableTimeEnds,
        ),
      );
    }
    if (isDiscounted) result.removeWhere((p) => p.discount == 0);
    if (sortIndex != -1) {
      result.sort(
        (a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()),
      );
      if (sortIndex == 1) result = result.reversed.toList();
    }
    return result;
  }

  static List<Store> sortStores({
    required List<Store> all,
    required int rating,
    required bool veg,
    required bool nonVeg,
    required bool isAvailable,
    required bool isDiscounted,
    required int sortIndex,
  }) {
    List<Store> result = List<Store>.from(all);
    if (rating != -1) result.removeWhere((s) => s.avgRating! < rating);
    if (!veg && nonVeg) result.removeWhere((s) => s.nonVeg == 0);
    if (!nonVeg && veg) result.removeWhere((s) => s.veg == 0);
    if (isAvailable) {
      result.removeWhere((s) => s.open == 0 || !(s.active ?? false));
    }
    if (isDiscounted) result.removeWhere((s) => s.discount == null);
    if (sortIndex != -1) {
      result.sort(
        (a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()),
      );
      if (sortIndex == 1) result = result.reversed.toList();
    }
    return result;
  }
}
