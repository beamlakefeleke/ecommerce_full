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
import 'package:ecommerce/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:ecommerce/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:ecommerce/features/chat/domain/repositories/chat_repository.dart';
import 'package:ecommerce/features/chat/domain/usecases/get_conversation_list_usecase.dart';
import 'package:ecommerce/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:ecommerce/features/chat/domain/usecases/search_conversation_usecase.dart';
import 'package:ecommerce/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:ecommerce/features/chat/presentation/bloc/chat_bloc.dart';
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
