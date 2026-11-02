import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/category/domain/entities/category.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';

enum CategoryStatus { initial, loading, loaded, error }

enum CategoryActionStatus { none, inProgress, success, failure }

class CategoryState extends Equatable {
  final CategoryStatus status;
  final List<Category> categories;
  final List<Category>? subCategories;
  final List<Item>? categoryItems;
  final List<Store>? categoryStores;
  final List<Item>? searchItems;
  final List<Store>? searchStores;
  final List<bool> interestSelected;

  final bool isLoading;
  final bool isSearching;
  final bool isStore;
  final int subCategoryIndex;
  final String type;
  final String? searchText;
  final int offset;
  final int? pageSize;
  final int? restPageSize;

  final CategoryActionStatus actionStatus;
  final String? errorMessage;

  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories = const [],
    this.subCategories,
    this.categoryItems,
    this.categoryStores,
    this.searchItems,
    this.searchStores,
    this.interestSelected = const [],
    this.isLoading = false,
    this.isSearching = false,
    this.isStore = false,
    this.subCategoryIndex = 0,
    this.type = 'all',
    this.searchText,
    this.offset = 1,
    this.pageSize,
    this.restPageSize,
    this.actionStatus = CategoryActionStatus.none,
    this.errorMessage,
  });

  CategoryState copyWith({
    CategoryStatus? status,
    List<Category>? categories,
    List<Category>? subCategories,
    List<Item>? categoryItems,
    List<Store>? categoryStores,
    List<Item>? searchItems,
    List<Store>? searchStores,
    List<bool>? interestSelected,
    bool? isLoading,
    bool? isSearching,
    bool? isStore,
    int? subCategoryIndex,
    String? type,
    String? searchText,
    int? offset,
    int? pageSize,
    int? restPageSize,
    CategoryActionStatus? actionStatus,
    String? errorMessage,
    bool clearSubCategories = false,
    bool clearCategoryItems = false,
    bool clearCategoryStores = false,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      subCategories: clearSubCategories
          ? null
          : (subCategories ?? this.subCategories),
      categoryItems: clearCategoryItems
          ? null
          : (categoryItems ?? this.categoryItems),
      categoryStores: clearCategoryStores
          ? null
          : (categoryStores ?? this.categoryStores),
      searchItems: searchItems ?? this.searchItems,
      searchStores: searchStores ?? this.searchStores,
      interestSelected: interestSelected ?? this.interestSelected,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      isStore: isStore ?? this.isStore,
      subCategoryIndex: subCategoryIndex ?? this.subCategoryIndex,
      type: type ?? this.type,
      searchText: searchText ?? this.searchText,
      offset: offset ?? this.offset,
      pageSize: pageSize ?? this.pageSize,
      restPageSize: restPageSize ?? this.restPageSize,
      actionStatus: actionStatus ?? this.actionStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    categories,
    subCategories,
    categoryItems,
    categoryStores,
    searchItems,
    searchStores,
    interestSelected,
    isLoading,
    isSearching,
    isStore,
    subCategoryIndex,
    type,
    searchText,
    offset,
    pageSize,
    restPageSize,
    actionStatus,
    errorMessage,
  ];
}
