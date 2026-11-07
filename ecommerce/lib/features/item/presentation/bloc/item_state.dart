part of 'item_bloc.dart';

class ItemState extends Equatable {
  // Lists
  final List<Item>? popularItemList;
  final List<Item>? reviewedItemList;
  final List<Item>? recommendedItemList;
  final List<Item>? discountedItemList;
  final List<Categories>? reviewedCategoriesList;
  final ItemModel? featuredCategoriesItem;
  final BasicMedicineModel? basicMedicineModel;
  final List<CommonConditionModel>? commonConditions;
  final List<Item>? conditionWiseProduct;

  final bool isLoading;

  final String popularType;
  final String reviewedType;
  final String discountedType;

  // Per-item selection state
  final List<int>? variationIndex;
  final List<List<bool?>> selectedVariations;
  final int? quantity;
  final List<bool> addOnActiveList;
  final List<int?> addOnQtyList;
  final List<bool> collapseVariation;
  final int cartIndex;
  final Item? item;

  // UI indices
  final int imageIndex;
  final int productSelect;
  final int imageSliderIndex;
  final int currentIndex;
  final int selectedCommonCondition;
  final int selectedCategory;
  final bool isReadMore;

  const ItemState({
    this.popularItemList,
    this.reviewedItemList,
    this.recommendedItemList,
    this.discountedItemList,
    this.reviewedCategoriesList,
    this.featuredCategoriesItem,
    this.basicMedicineModel,
    this.commonConditions,
    this.conditionWiseProduct,
    this.isLoading = false,
    this.popularType = 'all',
    this.reviewedType = 'all',
    this.discountedType = 'all',
    this.variationIndex,
    this.selectedVariations = const [],
    this.quantity = 1,
    this.addOnActiveList = const [],
    this.addOnQtyList = const [],
    this.collapseVariation = const [],
    this.cartIndex = -1,
    this.item,
    this.imageIndex = 0,
    this.productSelect = 0,
    this.imageSliderIndex = 0,
    this.currentIndex = 0,
    this.selectedCommonCondition = 0,
    this.selectedCategory = 0,
    this.isReadMore = false,
  });

  static const List<String> itemTypeList = ['all', 'veg', 'non_veg'];

  ItemState copyWith({
    List<Item>? popularItemList,
    List<Item>? reviewedItemList,
    List<Item>? recommendedItemList,
    List<Item>? discountedItemList,
    List<Categories>? reviewedCategoriesList,
    ItemModel? featuredCategoriesItem,
    BasicMedicineModel? basicMedicineModel,
    List<CommonConditionModel>? commonConditions,
    List<Item>? conditionWiseProduct,
    bool? isLoading,
    String? popularType,
    String? reviewedType,
    String? discountedType,
    List<int>? variationIndex,
    List<List<bool?>>? selectedVariations,
    int? quantity,
    List<bool>? addOnActiveList,
    List<int?>? addOnQtyList,
    List<bool>? collapseVariation,
    int? cartIndex,
    Item? item,
    int? imageIndex,
    int? productSelect,
    int? imageSliderIndex,
    int? currentIndex,
    int? selectedCommonCondition,
    int? selectedCategory,
    bool? isReadMore,
    bool clearPopular = false,
    bool clearReviewed = false,
    bool clearRecommended = false,
    bool clearDiscounted = false,
    bool clearFeatured = false,
    bool clearMedicine = false,
    bool clearConditionWise = false,
    bool clearItem = false,
  }) {
    return ItemState(
      popularItemList: clearPopular
          ? null
          : (popularItemList ?? this.popularItemList),
      reviewedItemList: clearReviewed
          ? null
          : (reviewedItemList ?? this.reviewedItemList),
      recommendedItemList: clearRecommended
          ? null
          : (recommendedItemList ?? this.recommendedItemList),
      discountedItemList: clearDiscounted
          ? null
          : (discountedItemList ?? this.discountedItemList),
      reviewedCategoriesList:
          reviewedCategoriesList ?? this.reviewedCategoriesList,
      featuredCategoriesItem: clearFeatured
          ? null
          : (featuredCategoriesItem ?? this.featuredCategoriesItem),
      basicMedicineModel: clearMedicine
          ? null
          : (basicMedicineModel ?? this.basicMedicineModel),
      commonConditions: commonConditions ?? this.commonConditions,
      conditionWiseProduct: clearConditionWise
          ? null
          : (conditionWiseProduct ?? this.conditionWiseProduct),
      isLoading: isLoading ?? this.isLoading,
      popularType: popularType ?? this.popularType,
      reviewedType: reviewedType ?? this.reviewedType,
      discountedType: discountedType ?? this.discountedType,
      variationIndex: variationIndex ?? this.variationIndex,
      selectedVariations: selectedVariations ?? this.selectedVariations,
      quantity: quantity ?? this.quantity,
      addOnActiveList: addOnActiveList ?? this.addOnActiveList,
      addOnQtyList: addOnQtyList ?? this.addOnQtyList,
      collapseVariation: collapseVariation ?? this.collapseVariation,
      cartIndex: cartIndex ?? this.cartIndex,
      item: clearItem ? null : (item ?? this.item),
      imageIndex: imageIndex ?? this.imageIndex,
      productSelect: productSelect ?? this.productSelect,
      imageSliderIndex: imageSliderIndex ?? this.imageSliderIndex,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedCommonCondition:
          selectedCommonCondition ?? this.selectedCommonCondition,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isReadMore: isReadMore ?? this.isReadMore,
    );
  }

  @override
  List<Object?> get props => [
    popularItemList,
    reviewedItemList,
    recommendedItemList,
    discountedItemList,
    reviewedCategoriesList,
    featuredCategoriesItem,
    basicMedicineModel,
    commonConditions,
    conditionWiseProduct,
    isLoading,
    popularType,
    reviewedType,
    discountedType,
    variationIndex,
    selectedVariations,
    quantity,
    addOnActiveList,
    addOnQtyList,
    collapseVariation,
    cartIndex,
    item,
    imageIndex,
    productSelect,
    imageSliderIndex,
    currentIndex,
    selectedCommonCondition,
    selectedCategory,
    isReadMore,
  ];
}
