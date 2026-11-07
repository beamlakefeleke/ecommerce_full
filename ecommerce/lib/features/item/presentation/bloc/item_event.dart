part of 'item_bloc.dart';

sealed class ItemEvent extends Equatable {
  const ItemEvent();
  @override
  List<Object?> get props => [];
}

class PopularItemsRequested extends ItemEvent {
  final bool reload;
  final String type;
  const PopularItemsRequested({this.reload = false, this.type = 'all'});
  @override
  List<Object?> get props => [reload, type];
}

class ReviewedItemsRequested extends ItemEvent {
  final bool reload;
  final String type;
  const ReviewedItemsRequested({this.reload = false, this.type = 'all'});
  @override
  List<Object?> get props => [reload, type];
}

class DiscountedItemsRequested extends ItemEvent {
  final bool reload;
  final String type;
  const DiscountedItemsRequested({this.reload = false, this.type = 'all'});
  @override
  List<Object?> get props => [reload, type];
}

class RecommendedItemsRequested extends ItemEvent {
  final bool reload;
  final String type;
  const RecommendedItemsRequested({this.reload = false, this.type = 'all'});
  @override
  List<Object?> get props => [reload, type];
}

class FeaturedCategoriesItemsRequested extends ItemEvent {
  final bool reload;
  const FeaturedCategoriesItemsRequested({this.reload = false});
  @override
  List<Object?> get props => [reload];
}

class BasicMedicineRequested extends ItemEvent {
  final bool reload;
  const BasicMedicineRequested({this.reload = false});
  @override
  List<Object?> get props => [reload];
}

class CommonConditionsRequested extends ItemEvent {
  const CommonConditionsRequested();
}

class ConditionsWiseItemsRequested extends ItemEvent {
  final int id;
  const ConditionsWiseItemsRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class CommonConditionSelected extends ItemEvent {
  final int index;
  const CommonConditionSelected(this.index);
  @override
  List<Object?> get props => [index];
}

class FeaturedCategorySelected extends ItemEvent {
  final int index;
  const FeaturedCategorySelected(this.index);
  @override
  List<Object?> get props => [index];
}

class ItemCurrentIndexChanged extends ItemEvent {
  final int index;
  const ItemCurrentIndexChanged(this.index);
  @override
  List<Object?> get props => [index];
}

/// Loads product details and initialises the per-item selection state.
class ProductDetailsRequested extends ItemEvent {
  final Item item;
  final CartModel? cart;
  const ProductDetailsRequested(this.item, {this.cart});
  @override
  List<Object?> get props => [item, cart];
}

/// Re-initialises the selection state for an item (used by the bottom sheet).
class ItemDataInitialized extends ItemEvent {
  final Item item;
  final CartModel? cart;
  const ItemDataInitialized(this.item, {this.cart});
  @override
  List<Object?> get props => [item, cart];
}

class AddOnQuantityChanged extends ItemEvent {
  final bool isIncrement;
  final int index;
  const AddOnQuantityChanged({required this.isIncrement, required this.index});
  @override
  List<Object?> get props => [isIncrement, index];
}

class ItemQuantityChanged extends ItemEvent {
  final bool isIncrement;
  final int? stock;
  final int? quantityLimit;
  final bool getxSnackBar;
  const ItemQuantityChanged({
    required this.isIncrement,
    this.stock,
    this.quantityLimit,
    this.getxSnackBar = false,
  });
  @override
  List<Object?> get props => [isIncrement, stock, quantityLimit, getxSnackBar];
}

class CartVariationIndexSet extends ItemEvent {
  final int index;
  final int i;
  final Item? item;
  const CartVariationIndexSet(this.index, this.i, this.item);
  @override
  List<Object?> get props => [index, i, item];
}

class NewCartVariationIndexSet extends ItemEvent {
  final int index;
  final int i;
  final Item item;
  const NewCartVariationIndexSet(this.index, this.i, this.item);
  @override
  List<Object?> get props => [index, i, item];
}

class AddOnToggled extends ItemEvent {
  final bool isAdd;
  final int index;
  const AddOnToggled({required this.isAdd, required this.index});
  @override
  List<Object?> get props => [isAdd, index];
}

class VariationSectionToggled extends ItemEvent {
  final int index;
  const VariationSectionToggled(this.index);
  @override
  List<Object?> get props => [index];
}

class ItemImageIndexChanged extends ItemEvent {
  final int index;
  const ItemImageIndexChanged(this.index);
  @override
  List<Object?> get props => [index];
}

class ProductSelectChanged extends ItemEvent {
  final int select;
  const ProductSelectChanged(this.select);
  @override
  List<Object?> get props => [select];
}

class ImageSliderIndexChanged extends ItemEvent {
  final int index;
  const ImageSliderIndexChanged(this.index);
  @override
  List<Object?> get props => [index];
}

class ReadMoreToggled extends ItemEvent {
  const ReadMoreToggled();
}

class ExistInCartChecked extends ItemEvent {
  final Item item;
  const ExistInCartChecked(this.item);
  @override
  List<Object?> get props => [item];
}
