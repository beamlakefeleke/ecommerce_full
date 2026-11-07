import 'package:get/get.dart' as getx;
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/features/address/data/datasources/address_remote_data_source.dart';
import 'package:ecommerce/features/address/data/repositories/address_repository_impl.dart';
import 'package:ecommerce/features/address/domain/repositories/address_repository.dart';
import 'package:ecommerce/features/address/domain/usecases/add_address_usecase.dart';
import 'package:ecommerce/features/address/domain/usecases/delete_address_usecase.dart';
import 'package:ecommerce/features/address/domain/usecases/get_addresses_usecase.dart';
import 'package:ecommerce/features/address/domain/usecases/update_address_usecase.dart';
import 'package:ecommerce/features/address/presentation/bloc/address_bloc.dart';
import 'package:ecommerce/features/banner/data/datasources/banner_remote_data_source.dart';
import 'package:ecommerce/features/banner/data/repositories/banner_repository_impl.dart';
import 'package:ecommerce/features/banner/domain/repositories/banner_repository.dart';
import 'package:ecommerce/features/banner/domain/usecases/get_banners_usecase.dart';
import 'package:ecommerce/features/banner/domain/usecases/get_featured_banners_usecase.dart';
import 'package:ecommerce/features/banner/domain/usecases/get_parcel_other_banners_usecase.dart';
import 'package:ecommerce/features/banner/domain/usecases/get_promotional_banners_usecase.dart';
import 'package:ecommerce/features/banner/domain/usecases/get_taxi_banners_usecase.dart';
import 'package:ecommerce/features/banner/presentation/bloc/banner_bloc.dart';
import 'package:ecommerce/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:ecommerce/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:ecommerce/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:ecommerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecommerce/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:ecommerce/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:ecommerce/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:ecommerce/features/cart/domain/usecases/remove_cart_item_usecase.dart';
import 'package:ecommerce/features/cart/domain/usecases/update_cart_quantity_usecase.dart';
import 'package:ecommerce/features/cart/domain/usecases/update_cart_usecase.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/category/data/datasources/category_remote_data_source.dart';
import 'package:ecommerce/features/category/data/repositories/category_repository_impl.dart';
import 'package:ecommerce/features/category/domain/repositories/category_repository.dart';
import 'package:ecommerce/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:ecommerce/features/category/domain/usecases/get_category_items_usecase.dart';
import 'package:ecommerce/features/category/domain/usecases/get_category_stores_usecase.dart';
import 'package:ecommerce/features/category/domain/usecases/get_sub_categories_usecase.dart';
import 'package:ecommerce/features/category/domain/usecases/save_interest_usecase.dart';
import 'package:ecommerce/features/category/domain/usecases/search_category_usecase.dart';
import 'package:ecommerce/features/category/presentation/bloc/category_bloc.dart';
import 'package:ecommerce/features/checkout/data/datasources/checkout_local_data_source.dart';
import 'package:ecommerce/features/checkout/data/datasources/checkout_remote_data_source.dart';
import 'package:ecommerce/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:ecommerce/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:ecommerce/features/checkout/domain/usecases/get_distance_usecase.dart';
import 'package:ecommerce/features/checkout/domain/usecases/get_dm_tip_usecase.dart';
import 'package:ecommerce/features/checkout/domain/usecases/get_extra_charge_usecase.dart';
import 'package:ecommerce/features/checkout/domain/usecases/get_offline_methods_usecase.dart';
import 'package:ecommerce/features/checkout/domain/usecases/place_order_usecase.dart';
import 'package:ecommerce/features/checkout/domain/usecases/place_prescription_order_usecase.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:ecommerce/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:ecommerce/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:ecommerce/features/chat/domain/repositories/chat_repository.dart';
import 'package:ecommerce/features/chat/domain/usecases/get_conversation_list_usecase.dart';
import 'package:ecommerce/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:ecommerce/features/chat/domain/usecases/search_conversation_usecase.dart';
import 'package:ecommerce/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:ecommerce/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:ecommerce/features/coupon/data/datasources/coupon_remote_data_source.dart';
import 'package:ecommerce/features/coupon/data/repositories/coupon_repository_impl.dart';
import 'package:ecommerce/features/coupon/domain/repositories/coupon_repository.dart';
import 'package:ecommerce/features/coupon/domain/usecases/apply_coupon_usecase.dart';
import 'package:ecommerce/features/coupon/domain/usecases/apply_taxi_coupon_usecase.dart';
import 'package:ecommerce/features/coupon/domain/usecases/get_coupon_list_usecase.dart';
import 'package:ecommerce/features/coupon/domain/usecases/get_taxi_coupon_list_usecase.dart';
import 'package:ecommerce/features/coupon/presentation/bloc/coupon_bloc.dart';
import 'package:ecommerce/features/favourite/data/datasources/favourite_remote_data_source.dart';
import 'package:ecommerce/features/favourite/data/repositories/favourite_repository_impl.dart';
import 'package:ecommerce/features/favourite/domain/repositories/favourite_repository.dart';
import 'package:ecommerce/features/favourite/domain/usecases/add_favourite_usecase.dart';
import 'package:ecommerce/features/favourite/domain/usecases/get_favourite_list_usecase.dart';
import 'package:ecommerce/features/favourite/domain/usecases/remove_favourite_usecase.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_bloc.dart';
import 'package:ecommerce/features/flash_sale/data/datasources/flash_sale_remote_data_source.dart';
import 'package:ecommerce/features/flash_sale/data/repositories/flash_sale_repository_impl.dart';
import 'package:ecommerce/features/flash_sale/domain/repositories/flash_sale_repository.dart';
import 'package:ecommerce/features/flash_sale/domain/usecases/get_flash_sale_usecase.dart';
import 'package:ecommerce/features/flash_sale/domain/usecases/get_flash_sale_with_id_usecase.dart';
import 'package:ecommerce/features/flash_sale/presentation/bloc/flash_sale_bloc.dart';
import 'package:ecommerce/features/html/data/datasources/html_remote_data_source.dart';
import 'package:ecommerce/features/html/data/repositories/html_repository_impl.dart';
import 'package:ecommerce/features/html/domain/repositories/html_repository.dart';
import 'package:ecommerce/features/html/domain/usecases/get_html_text_usecase.dart';
import 'package:ecommerce/features/html/presentation/bloc/html_bloc.dart';
import 'package:ecommerce/features/item/data/datasources/campaign_remote_data_source.dart';
import 'package:ecommerce/features/item/data/datasources/item_remote_data_source.dart';
import 'package:ecommerce/features/item/data/repositories/campaign_repository_impl.dart';
import 'package:ecommerce/features/item/data/repositories/item_repository_impl.dart';
import 'package:ecommerce/features/item/domain/repositories/campaign_repository.dart';
import 'package:ecommerce/features/item/domain/repositories/item_repository.dart';
import 'package:ecommerce/features/item/domain/usecases/campaign_usecases.dart';
import 'package:ecommerce/features/item/domain/usecases/item_usecases.dart';
import 'package:ecommerce/features/item/presentation/bloc/campaign_bloc.dart';
import 'package:ecommerce/features/item/presentation/bloc/item_bloc.dart';
import 'package:ecommerce/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:ecommerce/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ecommerce/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce/features/auth/domain/usecases/guest_login_usecase.dart';
import 'package:ecommerce/features/auth/domain/usecases/login_usecase.dart';
import 'package:ecommerce/features/auth/domain/usecases/register_usecase.dart';
import 'package:ecommerce/features/auth/domain/usecases/social_login_usecase.dart';
import 'package:ecommerce/features/auth/domain/usecases/social_register_usecase.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';

/// Service locator for the migrated (Clean Architecture + BLoC) features.
///
/// Lives alongside the legacy GetX locator (`lib/helper/get_di.dart`) during
/// migration. Call [configureDependencies] once in `main()` AFTER the GetX
/// `di.init()` so the shared [ApiClient] is already registered with GetX.
final GetIt getIt = GetIt.instance;

void configureDependencies() {
  // Reuse the single ApiClient instance that the legacy GetX locator created,
  // so both stacks share the same auth token / headers during migration.
  if (!getIt.isRegistered<ApiClient>()) {
    getIt.registerLazySingleton<ApiClient>(() => getx.Get.find<ApiClient>());
  }

  if (!getIt.isRegistered<SharedPreferences>()) {
    getIt.registerLazySingleton<SharedPreferences>(
      () => getx.Get.find<SharedPreferences>(),
    );
  }

  _registerAddress();
  _registerAuth();
  _registerBanner();
  _registerCart();
  _registerCategory();
  _registerChat();
  _registerCheckout();
  _registerCoupon();
  _registerFavourite();
  _registerFlashSale();
  _registerHtml();
  _registerItem();
}

void _registerItem() {
  // data
  getIt.registerLazySingleton<ItemRemoteDataSource>(
    () => ItemRemoteDataSourceImpl(apiClient: getIt()),
  );
  getIt.registerLazySingleton<CampaignRemoteDataSource>(
    () => CampaignRemoteDataSourceImpl(apiClient: getIt()),
  );
  getIt.registerLazySingleton<ItemRepository>(
    () => ItemRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton<CampaignRepository>(
    () => CampaignRepositoryImpl(remoteDataSource: getIt()),
  );

  // item usecases
  getIt.registerFactory(() => GetPopularItemsUseCase(getIt()));
  getIt.registerFactory(() => GetReviewedItemsUseCase(getIt()));
  getIt.registerFactory(() => GetFeaturedCategoriesItemsUseCase(getIt()));
  getIt.registerFactory(() => GetRecommendedItemsUseCase(getIt()));
  getIt.registerFactory(() => GetDiscountedItemsUseCase(getIt()));
  getIt.registerFactory(() => GetItemDetailsUseCase(getIt()));
  getIt.registerFactory(() => GetBasicMedicineUseCase(getIt()));
  getIt.registerFactory(() => GetCommonConditionsUseCase(getIt()));
  getIt.registerFactory(() => GetConditionsWiseItemsUseCase(getIt()));

  // campaign usecases
  getIt.registerFactory(() => GetBasicCampaignListUseCase(getIt()));
  getIt.registerFactory(() => GetCampaignDetailsUseCase(getIt()));
  getIt.registerFactory(() => GetItemCampaignListUseCase(getIt()));

  // app-wide blocs (list caches + item selection state shared across screens)
  getIt.registerLazySingleton(
    () => ItemBloc(
      getPopularItems: getIt(),
      getReviewedItems: getIt(),
      getFeaturedCategoriesItems: getIt(),
      getRecommendedItems: getIt(),
      getDiscountedItems: getIt(),
      getItemDetails: getIt(),
      getBasicMedicine: getIt(),
      getCommonConditions: getIt(),
      getConditionsWiseItems: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => CampaignBloc(
      getBasicCampaignListUseCase: getIt(),
      getCampaignDetailsUseCase: getIt(),
      getItemCampaignListUseCase: getIt(),
    ),
  );
}

void _registerHtml() {
  getIt.registerLazySingleton<HtmlRemoteDataSource>(
    () => HtmlRemoteDataSourceImpl(apiClient: getIt()),
  );
  getIt.registerLazySingleton<HtmlRepository>(
    () => HtmlRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerFactory(() => GetHtmlTextUseCase(getIt()));
  // screen-scoped: a fresh bloc per html viewer screen.
  getIt.registerFactory(() => HtmlBloc(getHtmlTextUseCase: getIt()));
}

void _registerFlashSale() {
  getIt.registerLazySingleton<FlashSaleRemoteDataSource>(
    () => FlashSaleRemoteDataSourceImpl(apiClient: getIt()),
  );
  getIt.registerLazySingleton<FlashSaleRepository>(
    () => FlashSaleRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerFactory(() => GetFlashSaleUseCase(getIt()));
  getIt.registerFactory(() => GetFlashSaleWithIdUseCase(getIt()));
  // app-wide: flash-sale countdown + list are read on home and details screens.
  getIt.registerLazySingleton(
    () => FlashSaleBloc(
      getFlashSaleUseCase: getIt(),
      getFlashSaleWithIdUseCase: getIt(),
    ),
  );
}

void _registerFavourite() {
  getIt.registerLazySingleton<FavouriteRemoteDataSource>(
    () => FavouriteRemoteDataSourceImpl(apiClient: getIt()),
  );
  getIt.registerLazySingleton<FavouriteRepository>(
    () => FavouriteRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerFactory(() => GetFavouriteListUseCase(getIt()));
  getIt.registerFactory(() => AddFavouriteUseCase(getIt()));
  getIt.registerFactory(() => RemoveFavouriteUseCase(getIt()));
  // app-wide: wish state is read across item/store/menu/profile screens.
  getIt.registerLazySingleton(
    () => FavouriteBloc(
      getFavouriteListUseCase: getIt(),
      addFavouriteUseCase: getIt(),
      removeFavouriteUseCase: getIt(),
    ),
  );
}

void _registerCoupon() {
  getIt.registerLazySingleton<CouponRemoteDataSource>(
    () => CouponRemoteDataSourceImpl(apiClient: getIt()),
  );
  getIt.registerLazySingleton<CouponRepository>(
    () => CouponRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerFactory(() => GetCouponListUseCase(getIt()));
  getIt.registerFactory(() => GetTaxiCouponListUseCase(getIt()));
  getIt.registerFactory(() => ApplyCouponUseCase(getIt()));
  getIt.registerFactory(() => ApplyTaxiCouponUseCase(getIt()));
  getIt.registerFactory(
    () => CouponBloc(
      getCouponListUseCase: getIt(),
      getTaxiCouponListUseCase: getIt(),
      applyCouponUseCase: getIt(),
      applyTaxiCouponUseCase: getIt(),
    ),
  );
}

void _registerCheckout() {
  getIt.registerLazySingleton<CheckoutRemoteDataSource>(
    () => CheckoutRemoteDataSourceImpl(apiClient: getIt()),
  );
  getIt.registerLazySingleton<CheckoutLocalDataSource>(
    () => CheckoutLocalDataSourceImpl(sharedPreferences: getIt()),
  );
  getIt.registerLazySingleton<CheckoutRepository>(
    () => CheckoutRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );
  getIt.registerFactory(() => GetOfflineMethodsUseCase(getIt()));
  getIt.registerFactory(() => GetDmTipMostTappedUseCase(getIt()));
  getIt.registerFactory(() => GetExtraChargeUseCase(getIt()));
  getIt.registerFactory(() => GetDistanceUseCase(getIt()));
  getIt.registerFactory(() => PlaceOrderUseCase(getIt()));
  getIt.registerFactory(() => PlacePrescriptionOrderUseCase(getIt()));
  getIt.registerFactory(
    () => CheckoutBloc(
      repository: getIt(),
      getOfflineMethods: getIt(),
      getDmTipMostTapped: getIt(),
      getExtraCharge: getIt(),
      getDistance: getIt(),
      placeOrder: getIt(),
      placePrescriptionOrder: getIt(),
    ),
  );
}

void _registerCart() {
  // data
  getIt.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(apiClient: getIt()),
  );
  getIt.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(sharedPreferences: getIt()),
  );
  getIt.registerLazySingleton<CartRepository>(
    () =>
        CartRepositoryImpl(remoteDataSource: getIt(), localDataSource: getIt()),
  );

  // usecases
  getIt.registerFactory(() => AddToCartUseCase(getIt()));
  getIt.registerFactory(() => UpdateCartUseCase(getIt()));
  getIt.registerFactory(() => UpdateCartQuantityUseCase(getIt()));
  getIt.registerFactory(() => GetCartUseCase(getIt()));
  getIt.registerFactory(() => RemoveCartItemUseCase(getIt()));
  getIt.registerFactory(() => ClearCartUseCase(getIt()));

  // bloc — app-wide (cart badge count is cross-cutting)
  getIt.registerFactory(
    () => CartBloc(
      addToCartUseCase: getIt(),
      updateCartUseCase: getIt(),
      updateCartQuantityUseCase: getIt(),
      getCartUseCase: getIt(),
      removeCartItemUseCase: getIt(),
      clearCartUseCase: getIt(),
      repository: getIt(),
    ),
  );
}

void _registerBanner() {
  // data
  getIt.registerLazySingleton<BannerRemoteDataSource>(
    () => BannerRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<BannerRepository>(
    () => BannerRepositoryImpl(remoteDataSource: getIt()),
  );

  // usecases
  getIt.registerFactory(() => GetBannersUseCase(getIt()));
  getIt.registerFactory(() => GetFeaturedBannersUseCase(getIt()));
  getIt.registerFactory(() => GetTaxiBannersUseCase(getIt()));
  getIt.registerFactory(() => GetParcelOtherBannersUseCase(getIt()));
  getIt.registerFactory(() => GetPromotionalBannersUseCase(getIt()));

  // bloc
  getIt.registerFactory(
    () => BannerBloc(
      getBanners: getIt(),
      getFeaturedBanners: getIt(),
      getTaxiBanners: getIt(),
      getParcelOtherBanners: getIt(),
      getPromotionalBanners: getIt(),
      repository: getIt(),
    ),
  );
}

void _registerAuth() {
  // data
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      sharedPreferences: getIt<SharedPreferences>(),
      apiClient: getIt<ApiClient>(),
    ),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: getIt(), local: getIt()),
  );

  // usecases
  getIt.registerFactory(() => LoginUseCase(getIt()));
  getIt.registerFactory(() => RegisterUseCase(getIt()));
  getIt.registerFactory(() => GuestLoginUseCase(getIt()));
  getIt.registerFactory(() => SocialLoginUseCase(getIt()));
  getIt.registerFactory(() => SocialRegisterUseCase(getIt()));

  // bloc
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt(),
      registerUseCase: getIt(),
      guestLoginUseCase: getIt(),
      socialLoginUseCase: getIt(),
      socialRegisterUseCase: getIt(),
      repository: getIt(),
      // Config lives in the still-GetX splash feature; read it lazily so the
      // domain layer stays decoupled from SplashController.
      isCustomerVerificationOn: () =>
          getx.Get.find<SplashController>().configModel?.customerVerification ??
          false,
    ),
  );
}

void _registerAddress() {
  // data
  getIt.registerLazySingleton<AddressRemoteDataSource>(
    () => AddressRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(remoteDataSource: getIt()),
  );

  // usecases
  getIt.registerFactory(() => GetAddressesUseCase(getIt()));
  getIt.registerFactory(() => AddAddressUseCase(getIt()));
  getIt.registerFactory(() => UpdateAddressUseCase(getIt()));
  getIt.registerFactory(() => DeleteAddressUseCase(getIt()));

  // bloc (new instance per screen)
  getIt.registerFactory(
    () => AddressBloc(
      getAddresses: getIt(),
      addAddress: getIt(),
      updateAddress: getIt(),
      deleteAddress: getIt(),
    ),
  );
}

// ── Category ─────────────────────────────────────────────────────────────────
// imports appended here — add to the top of the file when tidying imports

// ── Category ──────────────────────────────────────────────────────────────────

void _registerCategory() {
  getIt.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(apiClient: getIt()),
  );
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerFactory(() => GetCategoriesUseCase(getIt()));
  getIt.registerFactory(() => GetSubCategoriesUseCase(getIt()));
  getIt.registerFactory(() => GetCategoryItemsUseCase(getIt()));
  getIt.registerFactory(() => GetCategoryStoresUseCase(getIt()));
  getIt.registerFactory(() => SearchCategoryUseCase(getIt()));
  getIt.registerFactory(() => SaveInterestUseCase(getIt()));
  getIt.registerFactory(
    () => CategoryBloc(
      getCategories: getIt(),
      getSubCategories: getIt(),
      getCategoryItems: getIt(),
      getCategoryStores: getIt(),
      searchCategory: getIt(),
      saveInterest: getIt(),
    ),
  );
}

void _registerChat() {
  getIt.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(apiClient: getIt()),
  );
  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerFactory(() => GetConversationListUseCase(getIt()));
  getIt.registerFactory(() => SearchConversationUseCase(getIt()));
  getIt.registerFactory(() => GetMessagesUseCase(getIt()));
  getIt.registerFactory(() => SendMessageUseCase(getIt()));
  getIt.registerFactory(
    () => ChatBloc(
      getConversationList: getIt(),
      searchConversation: getIt(),
      getMessages: getIt(),
      sendMessage: getIt(),
      repository: getIt(),
    ),
  );
}
