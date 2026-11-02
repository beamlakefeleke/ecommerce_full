import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/category/domain/entities/category.dart';
import 'package:ecommerce/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:ecommerce/features/category/domain/usecases/get_category_items_usecase.dart';
import 'package:ecommerce/features/category/domain/usecases/get_category_stores_usecase.dart';
import 'package:ecommerce/features/category/domain/usecases/get_sub_categories_usecase.dart';
import 'package:ecommerce/features/category/domain/usecases/save_interest_usecase.dart';
import 'package:ecommerce/features/category/domain/usecases/search_category_usecase.dart';
import 'package:ecommerce/features/category/presentation/bloc/category_event.dart';
import 'package:ecommerce/features/category/presentation/bloc/category_state.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesUseCase getCategories;
  final GetSubCategoriesUseCase getSubCategories;
  final GetCategoryItemsUseCase getCategoryItems;
  final GetCategoryStoresUseCase getCategoryStores;
  final SearchCategoryUseCase searchCategory;
  final SaveInterestUseCase saveInterest;

  CategoryBloc({
    required this.getCategories,
    required this.getSubCategories,
    required this.getCategoryItems,
    required this.getCategoryStores,
    required this.searchCategory,
    required this.saveInterest,
  }) : super(const CategoryState()) {
    on<CategoryListRequested>(_onCategoryList);
    on<SubCategoryListRequested>(_onSubCategoryList);
    on<SubCategoryIndexChanged>(_onSubCategoryIndexChanged);
    on<CategoryItemsRequested>(_onCategoryItems);
    on<CategoryStoresRequested>(_onCategoryStores);
    on<CategorySearchRequested>(_onSearch);
    on<CategorySearchToggled>(_onSearchToggled);
    on<CategoryTypeChanged>(_onTypeChanged);
    on<CategoryIsStoreSet>(_onIsStoreSet);
    on<CategoryBottomLoaderShown>(_onBottomLoader);
    on<CategoryInterestSelectionToggled>(_onInterestToggled);
    on<CategoryInterestSaved>(_onInterestSaved);
  }

  Future<void> _onCategoryList(
    CategoryListRequested event,
    Emitter<CategoryState> emit,
  ) async {
    if (state.categories.isNotEmpty && !event.reload) return;
    emit(state.copyWith(status: CategoryStatus.loading));
    final result = await getCategories(
      GetCategoriesParams(allCategory: event.allCategory),
    );
    result.fold(
      (f) => emit(
        state.copyWith(status: CategoryStatus.error, errorMessage: f.message),
      ),
      (cats) {
        final selected = List.filled(cats.length, false);
        emit(
          state.copyWith(
            status: CategoryStatus.loaded,
            categories: cats,
            interestSelected: selected,
          ),
        );
      },
    );
  }

  Future<void> _onSubCategoryList(
    SubCategoryListRequested event,
    Emitter<CategoryState> emit,
  ) async {
    emit(
      state.copyWith(
        subCategoryIndex: 0,
        clearSubCategories: true,
        clearCategoryItems: true,
      ),
    );
    final result = await getSubCategories(event.categoryId);
    result.fold((f) => emit(state.copyWith(errorMessage: f.message)), (subs) {
      final all = [
        Category(id: int.tryParse(event.categoryId ?? ''), name: 'all'),
        ...subs,
      ];
      emit(state.copyWith(subCategories: all));
      add(
        CategoryItemsRequested(
          categoryId: event.categoryId,
          offset: 1,
          type: 'all',
        ),
      );
    });
  }

  void _onSubCategoryIndexChanged(
    SubCategoryIndexChanged event,
    Emitter<CategoryState> emit,
  ) {
    emit(state.copyWith(subCategoryIndex: event.index));
    final String? id = event.index == 0
        ? event.categoryId
        : state.subCategories![event.index].id.toString();
    if (state.isStore) {
      add(
        CategoryStoresRequested(
          categoryId: id,
          offset: 1,
          type: state.type,
          notify: true,
        ),
      );
    } else {
      add(
        CategoryItemsRequested(
          categoryId: id,
          offset: 1,
          type: state.type,
          notify: true,
        ),
      );
    }
  }

  Future<void> _onCategoryItems(
    CategoryItemsRequested event,
    Emitter<CategoryState> emit,
  ) async {
    if (event.offset == 1) {
      if (state.type == event.type) {
        emit(state.copyWith(isSearching: false));
      }
      emit(
        state.copyWith(
          type: event.type,
          offset: event.offset,
          clearCategoryItems: true,
          isLoading: event.notify,
        ),
      );
    }
    final result = await getCategoryItems(
      GetCategoryItemsParams(
        categoryId: event.categoryId,
        offset: event.offset,
        type: event.type,
      ),
    );
    result.fold(
      (f) => emit(state.copyWith(isLoading: false, errorMessage: f.message)),
      (itemModel) {
        final items = event.offset == 1
            ? itemModel.items ?? []
            : [...(state.categoryItems ?? []), ...(itemModel.items ?? [])];
        emit(
          state.copyWith(
            categoryItems: items,
            pageSize: itemModel.totalSize,
            isLoading: false,
            offset: event.offset,
          ),
        );
      },
    );
  }

  Future<void> _onCategoryStores(
    CategoryStoresRequested event,
    Emitter<CategoryState> emit,
  ) async {
    if (event.offset == 1) {
      if (state.type == event.type) {
        emit(state.copyWith(isSearching: false));
      }
      emit(
        state.copyWith(
          type: event.type,
          offset: event.offset,
          clearCategoryStores: true,
          isLoading: event.notify,
        ),
      );
    }
    final result = await getCategoryStores(
      GetCategoryStoresParams(
        categoryId: event.categoryId,
        offset: event.offset,
        type: event.type,
      ),
    );
    result.fold(
      (f) => emit(state.copyWith(isLoading: false, errorMessage: f.message)),
      (storeModel) {
        final stores = event.offset == 1
            ? storeModel.stores ?? []
            : [...(state.categoryStores ?? []), ...(storeModel.stores ?? [])];
        emit(
          state.copyWith(
            categoryStores: stores,
            restPageSize: storeModel.totalSize,
            isLoading: false,
            offset: event.offset,
          ),
        );
      },
    );
  }

  Future<void> _onSearch(
    CategorySearchRequested event,
    Emitter<CategoryState> emit,
  ) async {
    if (event.query.isEmpty) return;
    emit(
      state.copyWith(
        isSearching: true,
        searchText: event.query,
        type: event.type,
        searchItems: state.isStore ? state.searchItems : null,
        searchStores: state.isStore ? null : state.searchStores,
      ),
    );
    final result = await searchCategory(
      SearchCategoryParams(
        query: event.query,
        categoryId: event.categoryId,
        isStore: state.isStore,
        type: event.type,
      ),
    );
    result.fold((f) => emit(state.copyWith(errorMessage: f.message)), (data) {
      if (state.isStore) {
        final s = data as StoreModel;
        emit(state.copyWith(searchStores: s.stores ?? []));
      } else {
        final m = data as ItemModel;
        emit(state.copyWith(searchItems: m.items ?? []));
      }
    });
  }

  void _onSearchToggled(
    CategorySearchToggled event,
    Emitter<CategoryState> emit,
  ) {
    final searching = !state.isSearching;
    emit(
      state.copyWith(
        isSearching: searching,
        searchItems: searching
            ? List.from(state.categoryItems ?? [])
            : state.searchItems,
        searchStores: searching
            ? List.from(state.categoryStores ?? [])
            : state.searchStores,
      ),
    );
  }

  void _onTypeChanged(CategoryTypeChanged event, Emitter<CategoryState> emit) {
    emit(state.copyWith(type: event.type));
  }

  void _onIsStoreSet(CategoryIsStoreSet event, Emitter<CategoryState> emit) {
    emit(state.copyWith(isStore: event.isStore));
  }

  void _onBottomLoader(
    CategoryBottomLoaderShown event,
    Emitter<CategoryState> emit,
  ) {
    emit(state.copyWith(isLoading: true));
  }

  void _onInterestToggled(
    CategoryInterestSelectionToggled event,
    Emitter<CategoryState> emit,
  ) {
    final updated = List<bool>.from(state.interestSelected);
    updated[event.index] = !updated[event.index];
    emit(state.copyWith(interestSelected: updated));
  }

  Future<void> _onInterestSaved(
    CategoryInterestSaved event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(actionStatus: CategoryActionStatus.inProgress));
    final result = await saveInterest(event.interests);
    result.fold(
      (f) => emit(
        state.copyWith(
          actionStatus: CategoryActionStatus.failure,
          errorMessage: f.message,
        ),
      ),
      (_) => emit(state.copyWith(actionStatus: CategoryActionStatus.success)),
    );
  }
}
