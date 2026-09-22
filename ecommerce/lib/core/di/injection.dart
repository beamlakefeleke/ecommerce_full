import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:ecommerce/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ecommerce/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:ecommerce/features/auth/domain/usecases/guest_login_usecase.dart';
import 'package:ecommerce/features/auth/domain/usecases/login_usecase.dart';
import 'package:ecommerce/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ecommerce/features/auth/domain/usecases/manage_saved_credentials_usecase.dart';
import 'package:ecommerce/features/auth/domain/usecases/register_usecase.dart';
import 'package:ecommerce/features/auth/domain/usecases/social_login_usecase.dart';
import 'package:ecommerce/features/auth/domain/usecases/social_register_usecase.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ecommerce/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ecommerce/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ecommerce/features/profile/domain/repositories/profile_repository.dart';
import 'package:ecommerce/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:ecommerce/features/profile/domain/usecases/delete_user_usecase.dart';
import 'package:ecommerce/features/profile/domain/usecases/get_user_info_usecase.dart';
import 'package:ecommerce/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:ecommerce/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:ecommerce/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:ecommerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecommerce/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:ecommerce/features/cart/domain/services/cart_service_interface.dart';
import 'package:ecommerce/features/cart/domain/services/cart_service.dart';
import 'package:ecommerce/features/cart/domain/usecases/add_shared_pref_cart_list_usecase.dart';
import 'package:ecommerce/features/cart/domain/usecases/get_shared_pref_cart_list_usecase.dart';
import 'package:ecommerce/features/cart/domain/usecases/add_to_cart_online_usecase.dart';
import 'package:ecommerce/features/cart/domain/usecases/delete_cart_usecase.dart';
import 'package:ecommerce/features/cart/domain/usecases/get_cart_data_online_usecase.dart';
import 'package:ecommerce/features/cart/domain/usecases/update_cart_online_usecase.dart';
import 'package:ecommerce/features/cart/domain/usecases/update_cart_quantity_online_usecase.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:ecommerce/features/wallet/domain/repositories/wallet_repository_interface.dart';
import 'package:ecommerce/features/wallet/domain/usecases/add_fund_to_wallet_usecase.dart';
import 'package:ecommerce/features/wallet/domain/usecases/get_wallet_bonus_usecase.dart';
import 'package:ecommerce/features/wallet/domain/usecases/get_wallet_transactions_usecase.dart';
import 'package:ecommerce/features/wallet/domain/usecases/manage_wallet_token_usecase.dart';
import 'package:ecommerce/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:ecommerce/features/parcel/data/repositories/parcel_repository_impl.dart';
import 'package:ecommerce/features/parcel/domain/repositories/parcel_repository_interface.dart';
import 'package:ecommerce/features/parcel/domain/usecases/get_parcel_category_usecase.dart';
import 'package:ecommerce/features/parcel/domain/usecases/get_parcel_instruction_usecase.dart';
import 'package:ecommerce/features/parcel/domain/usecases/get_place_details_usecase.dart';
import 'package:ecommerce/features/parcel/domain/usecases/get_video_content_usecase.dart';
import 'package:ecommerce/features/parcel/domain/usecases/get_why_choose_usecase.dart';
import 'package:ecommerce/features/parcel/presentation/bloc/parcel_bloc.dart';
import 'package:ecommerce/features/checkout/domain/repositories/checkout_repository_interface.dart';
import 'package:ecommerce/features/taxi_booking/data/repositories/taxi_booking_repository_impl.dart';
import 'package:ecommerce/features/taxi_booking/domain/repositories/taxi_booking_repository_interface.dart';
import 'package:ecommerce/features/taxi_booking/domain/usecases/get_brand_list_usecase.dart';
import 'package:ecommerce/features/taxi_booking/domain/usecases/get_place_details_usecase.dart'
    as taxi;
import 'package:ecommerce/features/taxi_booking/domain/usecases/get_route_between_coordinates_usecase.dart';
import 'package:ecommerce/features/taxi_booking/domain/usecases/get_running_trip_list_usecase.dart';
import 'package:ecommerce/features/taxi_booking/domain/usecases/get_top_rated_vehicles_list_usecase.dart';
import 'package:ecommerce/features/taxi_booking/domain/usecases/get_vehicles_list_usecase.dart';
import 'package:ecommerce/features/taxi_booking/domain/usecases/place_trip_usecase.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/booking_checkout_bloc.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/car_selection_bloc.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/rider_bloc.dart';
import 'package:ecommerce/features/location/domain/services/location_service_interface.dart';
import 'package:ecommerce/features/checkout/domain/services/checkout_service_interface.dart';
import 'package:ecommerce/features/splash/domain/services/splash_service_interface.dart';
import 'package:ecommerce/features/order/data/datasources/order_remote_data_source.dart';
import 'package:ecommerce/features/order/data/repositories/order_repository_impl.dart';
import 'package:ecommerce/features/order/domain/repositories/order_repository_new.dart';
import 'package:ecommerce/features/order/domain/usecases/cancel_order_usecase.dart';
import 'package:ecommerce/features/order/domain/usecases/get_cancel_reasons_usecase.dart';
import 'package:ecommerce/features/order/domain/usecases/get_history_orders_usecase.dart';
import 'package:ecommerce/features/order/domain/usecases/get_order_details_usecase.dart';
import 'package:ecommerce/features/order/domain/usecases/get_refund_reasons_usecase.dart';
import 'package:ecommerce/features/order/domain/usecases/get_running_orders_usecase.dart';
import 'package:ecommerce/features/order/domain/usecases/submit_refund_request_usecase.dart';
import 'package:ecommerce/features/order/domain/usecases/switch_to_cod_usecase.dart';
import 'package:ecommerce/features/order/domain/usecases/track_order_usecase.dart';
import 'package:ecommerce/features/order/presentation/bloc/order_bloc.dart';
import 'package:ecommerce/features/checkout/data/datasources/checkout_remote_data_source.dart';
import 'package:ecommerce/features/checkout/data/datasources/checkout_local_data_source.dart';
import 'package:ecommerce/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:ecommerce/features/checkout/domain/repositories/checkout_repository_new.dart';
import 'package:ecommerce/features/checkout/domain/usecases/get_distance_usecase.dart';
import 'package:ecommerce/features/checkout/domain/usecases/get_extra_charge_usecase.dart';
import 'package:ecommerce/features/checkout/domain/usecases/get_most_tipped_usecase.dart';
import 'package:ecommerce/features/checkout/domain/usecases/get_offline_methods_usecase.dart';
import 'package:ecommerce/features/checkout/domain/usecases/place_order_usecase.dart';
import 'package:ecommerce/features/checkout/domain/usecases/place_prescription_order_usecase.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:get/get.dart' as getx;

/// Global get_it service locator.
///
/// Coexists with GetX's service locator during incremental migration.
/// Once all features are migrated off GetX, the `get` package and
/// `get_di.dart` can be removed entirely.
final getIt = GetIt.instance;

/// Register all dependencies for migrated features.
///
/// Called once from `main()` after the existing `di.init()`.
/// Each feature's dependencies are registered in their own section.
Future<void> configureDependencies() async {
  // ─── Core (already initialized by GetX di.init, reuse instances) ──

  // SharedPreferences is already created by get_di.dart. Retrieve it.
  final sharedPreferences = getx.Get.find<SharedPreferences>();
  if (!getIt.isRegistered<SharedPreferences>()) {
    getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  }

  // ApiClient is already created by get_di.dart. Retrieve it.
  final apiClient = getx.Get.find<ApiClient>();
  if (!getIt.isRegistered<ApiClient>()) {
    getIt.registerSingleton<ApiClient>(apiClient);
  }

  // ─── Auth Feature ─────────────────────────────────────────────────

  // Data sources (lazy singletons per RULES.md §4)
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(getIt<SharedPreferences>(), getIt<ApiClient>()),
  );

  // Repository (lazy singleton per RULES.md §4)
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<AuthLocalDataSource>(),
    ),
  );

  // Usecases (factory = new instance per use, per RULES.md §4)
  getIt.registerFactory(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => GuestLoginUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => SocialLoginUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => SocialRegisterUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => CheckAuthStatusUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(
    () => ManageSavedCredentialsUseCase(getIt<AuthRepository>()),
  );

  // Bloc (factory = new instance per screen, per RULES.md §4)
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
      guestLoginUseCase: getIt<GuestLoginUseCase>(),
      socialLoginUseCase: getIt<SocialLoginUseCase>(),
      socialRegisterUseCase: getIt<SocialRegisterUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      checkAuthStatusUseCase: getIt<CheckAuthStatusUseCase>(),
      credentialsUseCase: getIt<ManageSavedCredentialsUseCase>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );

  // ─── Profile Feature ──────────────────────────────────────────────

  // Data sources
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(apiClient: getIt<ApiClient>()),
  );

  // Repository
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: getIt<ProfileRemoteDataSource>(),
    ),
  );

  // Usecases
  getIt.registerFactory(() => GetUserInfoUseCase(getIt<ProfileRepository>()));
  getIt.registerFactory(() => UpdateProfileUseCase(getIt<ProfileRepository>()));
  getIt.registerFactory(
    () => ChangePasswordUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerFactory(() => DeleteUserUseCase(getIt<ProfileRepository>()));

  // Bloc
  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getUserInfoUseCase: getIt<GetUserInfoUseCase>(),
      updateProfileUseCase: getIt<UpdateProfileUseCase>(),
      changePasswordUseCase: getIt<ChangePasswordUseCase>(),
      deleteUserUseCase: getIt<DeleteUserUseCase>(),
    ),
  );

  // ─── Wallet Feature ───────────────────────────────────────────────

  // Repository
  getIt.registerLazySingleton<WalletRepositoryInterface>(
    () => WalletRepositoryImpl(
      apiClient: getIt<ApiClient>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // Usecases
  getIt.registerFactory(
    () => GetWalletTransactionsUseCase(getIt<WalletRepositoryInterface>()),
  );
  getIt.registerFactory(
    () => AddFundToWalletUseCase(getIt<WalletRepositoryInterface>()),
  );
  getIt.registerFactory(
    () => GetWalletBonusUseCase(getIt<WalletRepositoryInterface>()),
  );
  getIt.registerFactory(
    () => ManageWalletTokenUseCase(getIt<WalletRepositoryInterface>()),
  );

  // Bloc
  getIt.registerFactory<WalletBloc>(
    () => WalletBloc(
      getWalletTransactionsUseCase: getIt<GetWalletTransactionsUseCase>(),
      addFundToWalletUseCase: getIt<AddFundToWalletUseCase>(),
      getWalletBonusUseCase: getIt<GetWalletBonusUseCase>(),
    ),
  );
  // ─── Parcel Feature ───────────────────────────────────────────────

  // Repository
  getIt.registerLazySingleton<ParcelRepositoryInterface>(
    () => ParcelRepositoryImpl(apiClient: getIt<ApiClient>()),
  );

  // Usecases
  getIt.registerFactory(
    () => GetParcelCategoryUseCase(getIt<ParcelRepositoryInterface>()),
  );
  getIt.registerFactory(
    () => GetWhyChooseUseCase(getIt<ParcelRepositoryInterface>()),
  );
  getIt.registerFactory(
    () => GetVideoContentUseCase(getIt<ParcelRepositoryInterface>()),
  );
  getIt.registerFactory(
    () => GetParcelInstructionUseCase(getIt<ParcelRepositoryInterface>()),
  );
  getIt.registerFactory(
    () => GetPlaceDetailsUseCase(getIt<ParcelRepositoryInterface>()),
  );

  // Bloc
  getIt.registerFactory<ParcelBloc>(
    () => ParcelBloc(
      getParcelCategoryUseCase: getIt<GetParcelCategoryUseCase>(),
      getWhyChooseUseCase: getIt<GetWhyChooseUseCase>(),
      getVideoContentUseCase: getIt<GetVideoContentUseCase>(),
      getParcelInstructionUseCase: getIt<GetParcelInstructionUseCase>(),
      getPlaceDetailsUseCase: getIt<GetPlaceDetailsUseCase>(),
      checkoutRepositoryInterface: getx.Get.find<CheckoutRepositoryInterface>(),
    ),
  );

  // ─── Taxi Booking Feature ─────────────────────────────────────────

  // Repository
  getIt.registerLazySingleton<TaxiBookingRepositoryInterface>(
    () => TaxiBookingRepositoryImpl(apiClient: getIt<ApiClient>()),
  );

  // Usecases
  getIt.registerFactory(
    () => GetBrandListUseCase(getIt<TaxiBookingRepositoryInterface>()),
  );
  getIt.registerFactory(
    () => taxi.GetPlaceDetailsUseCase(getIt<TaxiBookingRepositoryInterface>()),
  );
  getIt.registerFactory(
    () => GetRouteBetweenCoordinatesUseCase(
      getIt<TaxiBookingRepositoryInterface>(),
    ),
  );
  getIt.registerFactory(
    () => GetRunningTripListUseCase(getIt<TaxiBookingRepositoryInterface>()),
  );
  getIt.registerFactory(
    () =>
        GetTopRatedVehiclesListUseCase(getIt<TaxiBookingRepositoryInterface>()),
  );
  getIt.registerFactory(
    () => GetVehiclesListUseCase(getIt<TaxiBookingRepositoryInterface>()),
  );
  getIt.registerFactory(
    () => PlaceTripUseCase(getIt<TaxiBookingRepositoryInterface>()),
  );

  // Blocs
  getIt.registerFactory<RiderBloc>(
    () => RiderBloc(
      getTopRatedVehiclesListUseCase: getIt<GetTopRatedVehiclesListUseCase>(),
      getRunningTripListUseCase: getIt<GetRunningTripListUseCase>(),
      getPlaceDetailsUseCase: getIt<taxi.GetPlaceDetailsUseCase>(),
      getRouteBetweenCoordinatesUseCase:
          getIt<GetRouteBetweenCoordinatesUseCase>(),
      locationServiceInterface: getx.Get.find<LocationServiceInterface>(),
      checkoutServiceInterface: getx.Get.find<CheckoutServiceInterface>(),
      splashServiceInterface: getx.Get.find<SplashServiceInterface>(),
    ),
  );

  getIt.registerFactory<CarSelectionBloc>(
    () => CarSelectionBloc(
      getVehiclesListUseCase: getIt<GetVehiclesListUseCase>(),
      getBrandListUseCase: getIt<GetBrandListUseCase>(),
    ),
  );

  getIt.registerFactory<BookingCheckoutBloc>(
    () => BookingCheckoutBloc(placeTripUseCase: getIt<PlaceTripUseCase>()),
  );

  // ─── Cart Feature ─────────────────────────────────────────────────

  // Data sources
  getIt.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSource(
      apiClient: getIt<ApiClient>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );
  getIt.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSource(sharedPreferences: getIt<SharedPreferences>()),
  );

  // Repository
  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      remoteDataSource: getIt<CartRemoteDataSource>(),
      localDataSource: getIt<CartLocalDataSource>(),
    ),
  );

  // Service
  getIt.registerLazySingleton<CartServiceInterface>(() => CartService());

  // Usecases
  getIt.registerFactory(
    () => AddSharedPrefCartListUseCase(getIt<CartRepository>()),
  );
  getIt.registerFactory(
    () => GetSharedPrefCartListUseCase(getIt<CartRepository>()),
  );
  getIt.registerFactory(() => AddToCartOnlineUseCase(getIt<CartRepository>()));
  getIt.registerFactory(() => DeleteCartUseCase(getIt<CartRepository>()));
  getIt.registerFactory(
    () => GetCartDataOnlineUseCase(getIt<CartRepository>()),
  );
  getIt.registerFactory(() => UpdateCartOnlineUseCase(getIt<CartRepository>()));
  getIt.registerFactory(
    () => UpdateCartQuantityOnlineUseCase(getIt<CartRepository>()),
  );

  // Bloc
  getIt.registerLazySingleton<CartBloc>(
    () => CartBloc(
      getSharedPrefCartListUseCase: getIt(),
      addSharedPrefCartListUseCase: getIt(),
      addToCartOnlineUseCase: getIt(),
      deleteCartUseCase: getIt(),
      getCartDataOnlineUseCase: getIt(),
      updateCartOnlineUseCase: getIt(),
      updateCartQuantityOnlineUseCase: getIt(),
      cartServiceInterface: getIt(),
    ),
  );

  // ─── Order Feature ────────────────────────────────────────────────

  // Data source
  getIt.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSource(getIt<ApiClient>()),
  );

  // Repository
  getIt.registerLazySingleton<OrderRepositoryNew>(
    () => OrderRepositoryImpl(getIt<OrderRemoteDataSource>()),
  );

  // Usecases
  getIt.registerFactory(
    () => GetRunningOrdersUseCase(getIt<OrderRepositoryNew>()),
  );
  getIt.registerFactory(
    () => GetHistoryOrdersUseCase(getIt<OrderRepositoryNew>()),
  );
  getIt.registerFactory(
    () => GetOrderDetailsUseCase(getIt<OrderRepositoryNew>()),
  );
  getIt.registerFactory(() => TrackOrderUseCase(getIt<OrderRepositoryNew>()));
  getIt.registerFactory(() => CancelOrderUseCase(getIt<OrderRepositoryNew>()));
  getIt.registerFactory(() => SwitchToCodUseCase(getIt<OrderRepositoryNew>()));
  getIt.registerFactory(
    () => GetRefundReasonsUseCase(getIt<OrderRepositoryNew>()),
  );
  getIt.registerFactory(
    () => GetCancelReasonsUseCase(getIt<OrderRepositoryNew>()),
  );
  getIt.registerFactory(
    () => SubmitRefundRequestUseCase(getIt<OrderRepositoryNew>()),
  );

  // Bloc — lazySingleton: the timer-based polling requires a single shared instance
  getIt.registerLazySingleton<OrderBloc>(
    () => OrderBloc(
      getRunningOrdersUseCase: getIt<GetRunningOrdersUseCase>(),
      getHistoryOrdersUseCase: getIt<GetHistoryOrdersUseCase>(),
      getOrderDetailsUseCase: getIt<GetOrderDetailsUseCase>(),
      trackOrderUseCase: getIt<TrackOrderUseCase>(),
      cancelOrderUseCase: getIt<CancelOrderUseCase>(),
      switchToCodUseCase: getIt<SwitchToCodUseCase>(),
      getRefundReasonsUseCase: getIt<GetRefundReasonsUseCase>(),
      getCancelReasonsUseCase: getIt<GetCancelReasonsUseCase>(),
      submitRefundRequestUseCase: getIt<SubmitRefundRequestUseCase>(),
    ),
  );

  // ─── Checkout Feature ─────────────────────────────────────────────

  // Data sources
  getIt.registerLazySingleton<CheckoutRemoteDataSource>(
    () => CheckoutRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<CheckoutLocalDataSource>(
    () => CheckoutLocalDataSource(getIt<SharedPreferences>()),
  );

  // Repository
  getIt.registerLazySingleton<CheckoutRepositoryNew>(
    () => CheckoutRepositoryImpl(
      getIt<CheckoutRemoteDataSource>(),
      getIt<CheckoutLocalDataSource>(),
    ),
  );

  // Usecases
  getIt.registerFactory(
    () => PlaceOrderUseCase(getIt<CheckoutRepositoryNew>()),
  );
  getIt.registerFactory(
    () => PlacePrescriptionOrderUseCase(getIt<CheckoutRepositoryNew>()),
  );
  getIt.registerFactory(
    () => GetDistanceUseCase(getIt<CheckoutRepositoryNew>()),
  );
  getIt.registerFactory(
    () => GetExtraChargeUseCase(getIt<CheckoutRepositoryNew>()),
  );
  getIt.registerFactory(
    () => GetMostTippedUseCase(getIt<CheckoutRepositoryNew>()),
  );
  getIt.registerFactory(
    () => GetOfflineMethodsUseCase(getIt<CheckoutRepositoryNew>()),
  );

  // Bloc — lazySingleton: single checkout flow at a time
  getIt.registerLazySingleton<CheckoutBloc>(
    () => CheckoutBloc(
      placeOrderUseCase: getIt<PlaceOrderUseCase>(),
      placePrescriptionOrderUseCase: getIt<PlacePrescriptionOrderUseCase>(),
      getDistanceUseCase: getIt<GetDistanceUseCase>(),
      getExtraChargeUseCase: getIt<GetExtraChargeUseCase>(),
      getMostTippedUseCase: getIt<GetMostTippedUseCase>(),
      getOfflineMethodsUseCase: getIt<GetOfflineMethodsUseCase>(),
    ),
  );
}
