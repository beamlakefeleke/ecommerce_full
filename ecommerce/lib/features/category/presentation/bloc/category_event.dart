import 'package:equatable/equatable.dart';

sealed class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

class CategoryListRequested extends CategoryEvent {
  final bool reload;
  final bool allCategory;
  const CategoryListRequested({this.reload = false, this.allCategory = false});
  @override
  List<Object?> get props => [reload, allCategory];
}

/// Load sub-categories for a parent + kick off the first item page load.
class SubCategoryListRequested extends CategoryEvent {
  final String? categoryId;
  const SubCategoryListRequested(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class SubCategoryIndexChanged extends CategoryEvent {
  final int index;
  final String? categoryId;
  const SubCategoryIndexChanged(this.index, this.categoryId);
  @override
  List<Object?> get props => [index, categoryId];
}

class CategoryItemsRequested extends CategoryEvent {
  final String? categoryId;
  final int offset;
  final String type;
  final bool notify;
  const CategoryItemsRequested({
    required this.categoryId,
    required this.offset,
    required this.type,
    this.notify = false,
  });
  @override
  List<Object?> get props => [categoryId, offset, type, notify];
}

class CategoryStoresRequested extends CategoryEvent {
  final String? categoryId;
  final int offset;
  final String type;
  final bool notify;
  const CategoryStoresRequested({
    required this.categoryId,
    required this.offset,
    required this.type,
    this.notify = false,
  });
  @override
  List<Object?> get props => [categoryId, offset, type, notify];
}

class CategorySearchRequested extends CategoryEvent {
  final String query;
  final String? categoryId;
  final String type;
  const CategorySearchRequested({
    required this.query,
    required this.categoryId,
    required this.type,
  });
  @override
  List<Object?> get props => [query, categoryId, type];
}

class CategorySearchToggled extends CategoryEvent {
  const CategorySearchToggled();
}

class CategoryTypeChanged extends CategoryEvent {
  final String type;
  const CategoryTypeChanged(this.type);
  @override
  List<Object?> get props => [type];
}

class CategoryIsStoreSet extends CategoryEvent {
  final bool isStore;
  const CategoryIsStoreSet(this.isStore);
  @override
  List<Object?> get props => [isStore];
}

class CategoryBottomLoaderShown extends CategoryEvent {
  const CategoryBottomLoaderShown();
}

class CategoryInterestSelectionToggled extends CategoryEvent {
  final int index;
  const CategoryInterestSelectionToggled(this.index);
  @override
  List<Object?> get props => [index];
}

class CategoryInterestSaved extends CategoryEvent {
  final List<int?> interests;
  const CategoryInterestSaved(this.interests);
  @override
  List<Object?> get props => [interests];
}
