# 6amMart Flutter — Project Document

## 1. Overview
Multi-vendor, multi-module marketplace client built with Flutter (food, grocery,
pharmacy, e-commerce, parcel, taxi). Targets Android, iOS, web, desktop.

- Package: `ecommerce` · App name: `6amMart` · Version: `1.0.0+1` (internal 2.6)
- Dart SDK: `^3.10.0`
- API base: `https://6ammart-admin.6amtech.com` · Web: `https://6ammart-web.6amtech.com`

## 2. Architecture (single implementation per feature)
Every feature uses feature-based Clean Architecture with BLoC. There is exactly
ONE implementation per feature. When a feature is migrated, its GetX controller,
service, repository and old models are DELETED in the same change.

    presentation (Bloc) → domain (UseCase → Repository abstract) ← data (RepositoryImpl → DataSource → ApiClient)

## 3. Tech stack
| Concern | Standard |
|---|---|
| State management | `flutter_bloc` — event-driven Bloc; separate `*_bloc.dart`, `*_event.dart`, `*_state.dart`. Input only via `add(Event)` |
| DI | `get_it`, MANUAL registration in `lib/core/di/injection.dart`. No `injectable` codegen. Coexists with the legacy GetX locator and reuses its `ApiClient` |
| Errors | `Either<Failure, T>` via `fpdart`; data sources throw `Server/NetworkException` |
| Value equality | `equatable` |
| Routing | Still GetX (`RouteHelper` + `GetMaterialApp`). `Get.toNamed/offNamed/back/dialog` allowed for navigation only inside migrated pages until `go_router` lands (separate later pass) |


## 4. Directory layout
    lib/
    ├── api/api_client.dart          # the shared ApiClient stays HERE (GetxService). NOT in core/network
    ├── core/
    │   ├── di/injection.dart        # manual get_it; configureDependencies()
    │   ├── error/{failure.dart, exceptions.dart}
    │   └── usecase/usecase.dart     # UseCase<Type,Params> + NoParams
    ├── features/<feature>/
    │   ├── data/{datasources, models, repositories}
    │   ├── domain/{entities, repositories, usecases}
    │   └── presentation/{bloc, pages, widgets}
    ├── common/ helper/ theme/ util/
    └── main.dart

    Note: `lib/core/network/` and `lib/core/router/` do NOT exist yet. Networking uses
    the existing `lib/api/api_client.dart`; routing uses the existing
    `lib/helper/route_helper.dart`. Introduce those core folders only when ApiClient /
    go_router get their own dedicated migration pass.

## 5. Rules (see RULES.md for the full spec)
1. `domain/` is pure Dart: no Flutter, no http, no `get`, no `data/` imports.
2. Entities have no JSON and no transport-only fields. The ONE model lives in
   `data/models/` and owns `fromJson/toJson/toEntity/fromEntity`. A model MAY be a
   standalone mutable class when still-GetX code mutates it in place (e.g.
   `AddressModel`); otherwise prefer `extends <Entity>`.
3. Repositories return `Either<Failure, T>`. Data sources throw `Server/NetworkException`
   only; the repository impl maps them to `Failure`.
4. Blocs receive input ONLY through `add(Event)`. No public methods on a Bloc. No
   navigation/snackbars inside a Bloc — use `BlocListener`.
5. One Bloc per feature concern. Genuinely cross-cutting state (e.g. the address list) is
   provided app-wide with `MultiBlocProvider` wrapping `GetMaterialApp` in `main.dart`.
   Feature-scoped blocs are provided per-screen via `BlocProvider(create: getIt<X>())`.
6. State is immutable (`equatable`). Default: one state class + a `status` enum and an
   `actionStatus` enum (so a loaded list survives across add/update/delete). Use a sealed
   hierarchy only when states are mutually exclusive and carry no shared data.
7. DI is manual `get_it` in `lib/core/di/injection.dart`; also delete the feature's
   `Get.lazyPut` lines from `lib/helper/get_di.dart` when migrating it.
8. A feature migration is complete when: all three layers built, legacy files for THIS
   feature deleted, its get_di registrations removed, and
   `getDiagnostics` is clean on THIS feature's files + `main.dart` + the two DI files.
   **Cross-feature breakage in OTHER still-GetX features is expected and left as-is** —
   those compile again on their own alphabetical turn. Do not half-migrate them.

## 6. Bootstrap (main.dart)
1. `setPathUrlStrategy()`, `WidgetsFlutterBinding.ensureInitialized()`
2. Crashlytics hooks, Firebase init
3. `di.init()` — GetX locator (still used by features not yet migrated)
4. `configureDependencies()` — get_it
5. Notifications (mobile), Facebook auth (web)
6. `runApp` → `MultiBlocProvider` → `GetMaterialApp`

## 7. Networking
`ApiClient` (`lib/api/api_client.dart`) is shared. Data sources are the only
layer allowed to call it, and must convert its responses into
`ServerException` / `NetworkException` so no GetX `Response` type leaks upward.

## 8. Web deep-linking (do not break)
`RouteHelper` getters that base64-encode params (e.g. `getItemImagesRoute`)
are intentional for SEO/shareable URLs. Preserve them in any routing change.

## 9. Features
address, auth, banner, cart, category, chat, checkout, coupon, dashboard,
favourite, flash_sale, home, html, interest, item, language, location, loyalty,
menu, notification, onboard, online_payment, order, parcel, payment, profile,
refer_and_earn, review, search, splash, store, support, taxi_booking, update,
verification, wallet.

## 10. Migration status
| Feature | Status |
|---|---|
| core | Done — `error/failure.dart`, `error/exceptions.dart`, `usecase/usecase.dart`, `di/injection.dart` (manual get_it, bridges to GetX `ApiClient`) |
| address | Done — single `AddressBloc`; legacy controller/service/repository/old-model deleted; model unified at `data/models/`; provided app-wide via `MultiBlocProvider`; pages/widgets under `presentation/` |
| auth | Core DONE — `AuthBloc` (login/register/social/guest/toggles); usecases, repo (remote+local data sources), entities built; legacy `AuthController`/`AuthService(Interface)` deleted + removed from get_di; `AuthHelper` now reads `getIt<AuthRepository>()`; `AuthBloc` provided app-wide via `MultiBlocProvider`. See transitional notes below. |
| **banner** | Done — single `BannerBloc`; five fetch usecases; legacy deleted; provided app-wide |
| cart | Done — single `CartBloc`; all CRUD/sync usecases; legacy `CartController`/service deleted; screens/widgets migrated; provided app-wide |
| category | Done — single `CategoryBloc`; all list/subcategory/item/store/search/interest usecases; legacy deleted; screens under `presentation/pages/`; `interest_screen.dart` migrated |
| chat | Done — single `ChatBloc`; conversation/message/search/send usecases; missing `domain/repositories/chat_repository.dart` contract added; pages + web widgets under `presentation/`; `notification_helper` + `route_helper` repointed to bloc; legacy screens/widgets deleted |
| checkout | Done — single `CheckoutBloc` (event-driven; distance, dm-tip, extra-charge, offline-methods, place-order, prescription-order); entities/`TimeSlot`, unified `data/models/` (distance/place-order-body/timeslote); repo with distance fallback + pure time-slot generation/validation + `PlaceOrderResult`; legacy `CheckoutController`/service/interface/repository deleted + removed from get_di; all widgets + `checkout_screen` migrated; shared `TextEditingController`/`FocusNode`s moved into screen State and passed to child widgets; provided app-wide. Pending package-level `DottedBorder` API errors in `top_section.dart` are pre-existing and ignored. Cross-feature: `ParcelService` (get_di) and `store/widgets/camera_button_sheet_widget.dart` still reference deleted checkout APIs — fixed on parcel/store turns. |
| coupon | Done — single `CouponBloc` (app-wide; coupon list, taxi coupon list, apply/apply-taxi with full min-purchase + percent/max-discount + free-delivery logic ported into the bloc, remove-coupon, current-index); pure `Coupon` entity + unified mutable `data/models/coupon_model.dart` (keeps UI-only `JustTheController toolTip`) with `toEntity/fromEntity`; four usecases; repo returns `Either<Failure, …>`; legacy `CouponController`/service(+interface)/repository-interface/old-model/old screen+card-widget deleted + removed from get_di; pages/widgets under `presentation/`; checkout `coupon_section`/`coupon_bottom_sheet`/`bottom_section`/`checkout_screen` + `cart_screen` migrated to `CouponBloc`; snackbar/balance side-effects moved to a `BlocConsumer` listener. Cross-feature: taxi_booking (`taxi_coupon_screen`, `booking_details_info`), `store_controller`, home (`home_screen`, `web_coupon_banner_view_widget`, `promo_code_banner_view`) still reference the deleted `CouponController` — fixed on their turns. |
| dashboard | N/A — UI-only shell (bottom-nav scaffold composing other features' screens). No controller/service/repository/model, so nothing to migrate; only repointed its `favourite_screen` import to the new `presentation/pages` path. |
| favourite | Done — single app-wide `FavouriteBloc` (singleton: wish state read across item/store/menu/profile); optimistic add/remove with rollback, zone-filtered list parsing (ported from legacy `FavouriteService`, uses `AddressHelper` + `SplashController.module`), clear-on-logout; raw data source + `Either<Failure, …>` repository (returns raw `{item,store}` body; bloc parses); three usecases (`GetFavouriteList`, `AddFavourite`, `RemoveFavourite` sharing `FavouriteParams`); legacy controller/service(+interface)/repository(+interface)/old screen+widget deleted + removed from get_di; pages/widgets under `presentation/`; snackbar messages surfaced via transient state fields. `main.dart` migrated to `FavouriteBloc`. Cross-feature: splash, store, profile, menu, item, location, home still reference the deleted `FavouriteController` — fixed on their turns. |
| flash_sale | Done — single app-wide `FlashSaleBloc` (singleton; read on home + details). Second-by-second countdown ported from the legacy `Timer.periodic` to an internal `Stream.periodic` → `FlashSaleTicked` event (ticker cancelled in `close()`); pagination merges pages into a fresh `ProductFlashSale` (immutable swap so Equatable rebuilds); page-index + set-empty events preserved. Models moved to `data/models/` (`flash_sale_model`, `product_flash_sale`, kept mutable for still-GetX home consumers); raw data source + `Either<Failure,…>` repository; two usecases. Legacy controller/service(+interface)/repository(+interface)/old models/old screen+4 widgets deleted + removed from get_di; screen under `presentation/pages`, 4 widgets under `presentation/widgets`. `home/widgets/components/flash_sale_card_widget.dart` repointed to the data model + `FlashSaleBloc` for its page-index callback. Cross-feature: home (`home_screen`, `web_new_home_screen`, `web_flash_sale_view_widget`) still reference the deleted `FlashSaleController` — fixed on home's turn. |
| home | N/A — UI-only module screens (food/grocery/shop/pharmacy home layouts) composing other features' widgets. No dedicated controller/service/repository/model. Still references several not-yet-migrated GetX controllers (splash, item, store, location, banner, coupon, flash_sale-consumers) — those resolve as each owning feature migrates; nothing of its own to migrate. |
| html | Done — single screen-scoped `HtmlBloc` (factory, provided via `BlocProvider` at the viewer screen with the route's `HtmlType`); raw data source (keeps the localization header + GetX `LocalizationController` read), `Either<Failure,String>` repository (ports the `href` → `target="_blank" href=` rewrite), one `GetHtmlText` usecase. Legacy controller/service(+interface)/repository(+interface)/old screen deleted + removed from get_di; screen under `presentation/pages`; route_helper repointed. Pre-existing `flutter_html` package API errors (`RenderContext`, `SelectableHtml`) in the screen are unrelated to the migration and left as-is. |
| interest | N/A — UI-only single screen already migrated to `CategoryBloc` during the category migration. Nothing of its own to migrate. |
| item | Done — app-wide `ItemBloc` (all list loaders: popular/reviewed/discounted/recommended/featured-categories/basic-medicine/common-conditions/condition-wise + full per-item selection state: variations/foodVariations/addons/quantity/collapse/cartIndex/exist-in-cart, reading cart via `getIt<CartBloc>().state.cartList`) and app-wide `CampaignBloc` (basic list/details, item-campaign list with module filter, page index). Data sources + `Either`-returning repositories + contracts + grouped usecases (`item_usecases.dart`, `campaign_usecases.dart`). Stateless `ItemHelper` ports every pure `ItemService` fn + `navigateToItemPage`/`itemDirectlyAddToCart`/`existAnotherStoreItem`. Models stay in `domain/models/` (`item_model`, `basic_campaign_model`, `basic_medicine_model`, `common_condition_model`) because `Item` is shared app-wide. All screens/widgets migrated under `presentation/` (`item_details_screen`, `popular_item_screen`, `item_campaign_screen`, `item_image_view_widget`, `item_title_view_widget`, `details_web_view_widget`, `details_app_bar_widget` w/ `shake()`, `quantity_button`), plus the common `item_bottom_sheet.dart` (+ its `AddonView`/`VariationView`/`NewVariationView` sub-widgets) fully retargeted to `ItemBloc`/`CartBloc`/`FavouriteBloc` — UI identical, cart add/update/clear now dispatch `CartOnlineSynced`/`CartOnlineUpdated`/`CartCleared`. Added read-only `getCartId`/`cartQuantity`/`cartVariant`/`isExistInCart` getters to `CartState`. Legacy controllers/services/interfaces/old repositories/old screens+widgets deleted + removed from get_di; registered in `injection.dart`, provided app-wide in `main.dart`; route_helper repointed. Cross-feature consumers of `Get.find<ItemController>()`/`CampaignController` (store, search, home) break until retargeted to `ItemBloc`/`CampaignBloc`/`ItemHelper` on their turns. |
| language | Done — single app-wide `LanguageBloc`; local data source + repo; save/update-header usecases; legacy controller deleted; apply side-effects in `main.dart` `BlocConsumer` |
| location | Done — app-wide `LocationBloc` (map/zone working state: position/pickPosition, geocoded address/pickAddress, zone status, loading/button flags, predictions) + stateless `LocationHelper` for all side-effects (navigation via GetX, Firebase topic (un)subscribe, cart reset, zone persistence, cross-feature calls through migrated blocs/repos). Raw data source (geocode/zone/search/place-details) + `Either<Failure,…>` repository + `ZoneResult` entity (reuses shared `ZoneData`/`Modules`/`Pivot` models, kept app-wide) + grouped usecases. Legacy `LocationController`/`LocationService(Interface)`/`LocationRepository(Interface)` deleted + removed from get_di; screens → `presentation/pages`, widgets → `presentation/widgets`; `access_location_screen` reads `AddressBloc`, `pick_map_screen`/`web_landing_page`/`location_search_dialog_widget` retargeted to `LocationBloc`/`LocationHelper`/`LocationRepository`; `flutter_typeahead` upgraded to v6 API (`builder`/`onSelected`) in the two location search fields. Registered in `injection.dart`; provided app-wide in `main.dart`; route_helper repointed. Still-GetX `store_registration`/`deliveryman_registration` repointed off the deleted `LocationServiceInterface` to `getIt<LocationRepository>()`. Cross-feature consumers of the deleted `LocationController` (web_menu_bar, address widgets, auth sign_in/social_login, dashboard, home, order, parcel, splash, store, taxi_booking, verification) break until retargeted on their turns. Pre-existing `flutter_typeahead` v6 break also affects taxi `rider_address_input_field` (unmigrated); `flutter_html` `onLinkTap` API error in `web_landing_page` is pre-existing and left as-is. |
| loyalty | Done — single screen-scoped `LoyaltyBloc` (factory, provided via `BlocProvider` at the loyalty screen; not cross-cutting). Pure `LoyaltyTransaction` entity + `LoyaltyTransactionPage` (list + totalSize); `data/models/loyalty_transaction_model.dart` maps the wire JSON into the entity. Raw data source (`getData`/`postData` with `handleError: false`, throws `Server/NetworkException`) + `Either<Failure,…>` repository + two usecases (`GetLoyaltyTransactionsUseCase`, `ConvertPointToWalletUseCase`). Bloc ports the legacy offset-dedup pagination (10/page, `totalSize`-driven page count, bottom loader) and the point-to-wallet convert with an `actionStatus` enum; convert success re-requests page 1. Snackbars + dialog-close + `ProfileController.getUserInfo()` refresh moved to a `BlocListener` in the bottom sheet (no side effects in the bloc). The convert dialog is opened via `Get.dialog` wrapped in `BlocProvider.value` so it sees the screen's bloc. Legacy controller/service(+interface)/repository(+interface)/old screen+3 widgets deleted + removed from get_di; screen under `presentation/pages`, widgets under `presentation/widgets`; route_helper repointed. The shared `common/models/transaction_model.dart` is KEPT (still consumed by the unmigrated wallet feature + the shared `HistoryItemWidget`); the history widget adapts entities back to that wire type for the shared item widget. No cross-feature consumers of the deleted `LoyaltyController` — clean migration, no new breakage. |
| menu | N/A — UI-only module (the dashboard bottom-nav "menu" tab). No controller/service/repository/API of its own; `MenuScreen` is a settings/links shell that reads still-GetX `ProfileController`/`SplashController` and navigates via `RouteHelper`. On its turn: removed the deleted-controller references the earlier migrations left dangling — logout now calls `getIt<AuthRepository>().clearSharedData()` (the old `socialLogout()` was a no-op delegating to `clearSharedData`, so dropped) and dispatches `FavouriteCleared` to the app-wide `FavouriteBloc` instead of `FavouriteController.removeFavourite()`; deleted the dead `menu_button_widget.dart` (unused, referenced deleted `Cart/Auth/FavouriteController`) and its now-orphaned trivial `menu_model.dart`. Moved `menu_screen.dart` → `presentation/pages`, `portion_widget.dart` → `presentation/widgets`; repointed the dashboard importer. Nothing of its own to migrate to a Bloc. |
| notification | Done — single app-wide `NotificationBloc` (list + unread-badge `hasNotification` read on home and the parcel/taxi app bars). Pure `AppNotification`/`NotificationData` entities; `data/models/notification_model.dart` maps the wire JSON → entity (`toEntity`); remote data source (`getData` with `handleError: false`, throws `Server/NetworkException`) + local data source (SharedPreferences seen-count) + `Either<Failure,…>` repository; one `GetNotificationsUseCase`. Bloc ports the legacy load-once/`reload` guard, `updatedAt` sort → newest-first, and `hasNotification = length != seenCount`; `NotificationCleared` + `NotificationMarkedSeen` events replace the controller's `clearNotification()`/`saveSeenNotificationCount()`; the screen marks-seen via a `BlocConsumer` listener on first load. Legacy controller/service(+interface)/repository(+interface)/old model deleted + removed from get_di; screen → `presentation/pages`, dialog/popup widgets → `presentation/widgets`; registered in `injection.dart`, provided app-wide in `main.dart`; `route_helper` repointed (by move) and shared `notification_helper.dart` retargeted off the deleted `NotificationController` to `getIt<NotificationBloc>()`. The separate `domain/models/notification_body_model.dart` (base64 deep-link payload consumed by route_helper/notification_helper) is KEPT — not part of this controller migration. Cross-feature: home (`home_screen`), parcel (`parcel_app_bar_widget`), taxi_booking (`rider_app_bar`) still reference the deleted `NotificationController` — fixed on their turns. Pre-existing `flutter_local_notifications` package-API errors in `notification_helper.dart` (initialize/show signatures) are unrelated to the migration and left as-is. |
| onboard | Done — single screen-scoped `OnboardBloc` (factory, provided per-screen via `BlocProvider`; not cross-cutting). Pure `OnBoarding` entity; the three slides are static localized content (not an API payload), so a local data source builds them (`Images.*` + `.tr`) and the `data/models/onboarding_model.dart` (`extends OnBoarding`, `toEntity`) carries them; `Either<Failure,…>` repository + one `GetOnBoardingListUseCase`. Bloc holds `onBoardingList` + `selectedIndex` (status enum; list survives index changes); `OnBoardingListRequested` + `OnBoardingIndexChanged` events replace the controller's `getOnBoardingList()`/`changeSelectIndex()`. Navigation (`SplashController.disableIntro()` + `Get.offNamed`) stays in the screen per §5 (splash still GetX). Legacy controller/service(+interface)/repository(+interface)/old model deleted + removed from get_di; screen → `presentation/pages`; registered in `injection.dart`; route_helper repointed (by move). No cross-feature consumers — clean migration, analyzer reports no issues. |
| online_payment | Removed — dead scaffolding. The `OnlinePaymentController` had no state/methods, `OnlinePaymentService(Interface)` was empty, and `OnlinePaymentRepo` held only `UnimplementedError` stubs; nothing (not even get_di) referenced any of it. No screen/model/API/behavior to migrate, so the whole `lib/features/online_payment/` directory was deleted. |
| order | Done — single app-wide `OrderBloc` (running/history lists, order details, tracked order, cancel/switch-to-COD/refund flows, running-order bottom-sheet toggles). Replaced the god-`OrderController` + `OrderService(Interface)` + `OrderRepository(Interface)`. Data source (`handleError:false`, throws `Server/NetworkException`) + `Either<Failure,…>` repository (shared `_guard` try/catch) + grouped `order_usecases.dart` (running/history/details/track/cancel-reasons/refund-reasons/cancel/switch-cod/refund-submit). Pure navigation side-effect logic (`paymentRedirect`) moved to a stateless `domain/helpers/order_helper.dart`; snackbars/navigation on cancel/switch-COD/refund-success moved to `BlocListener`s (none inside the bloc). Pagination merges pages into a fresh `PaginatedOrderModel` (immutable swap). `ImagePicker` for the refund image is dispatched via `RefundImagePicked`. Models (`OrderModel`/`PaginatedOrderModel`/`OrderDetailsModel`/`DeliveryMan`/`CancellationData`/`RefundModel`) are KEPT in `domain/models/` as the single shared surface (imported by 10+ still-GetX files: route_helper, checkout, payment, taxi, review, dashboard) — same precedent as `item`. Legacy controller/service(+interface)/repository-interface deleted + removed from get_di; all 5 screens → `presentation/pages`, ~15 widgets → `presentation/widgets`; constructor widgets (`order_info`/`order_calcuation`/`order_banner`/`order_shimmer`) changed to take plain data (`orderDetails`/`isDataNull`) instead of the controller. Shared `common/` dialogs (`confirmation`/`cancellation`/`payment_complete` read `isLoading`; `not_logged_in_screen` reads sheet state) retargeted to `OrderBloc`; `notification_helper` retargeted to `getIt<OrderBloc>()`. In-feature consumers of the deleted `LocationController`/`AuthController`/`LocalizationController` (order_tracking, traking_map, guest_input) retargeted to `LocationBloc`/`AuthRepository`/`LanguageBloc`. Registered in `injection.dart`, provided app-wide in `main.dart`; route_helper repointed (by move). Cross-feature: dashboard (`dashboard_screen`, `running_order_view_widget`), checkout (`order_successful_screen`, `offline_success_dialog`, `order_successfull_dialog`, `payment_failed_dialog`, `checkout_screen`), payment (`payment_screen`, `payment_webview_screen`), taxi_booking (`taxi_payment_button`, `trip_history_screen`) still reference the deleted `OrderController` — fixed on their turns. Pre-existing package-API errors left as-is: `DottedBorder`/`BorderType` (dotted_border) in `order_calcuation_widget`/`refund_request_screen` (same as checkout `top_section`), and `flutter_local_notifications` in `notification_helper`. |
| parcel | Done — single app-wide `ParcelBloc` (category list + pickup/destination `AddressModel`s + sender/receiver toggles + payer/payment indices + dm-tips + offline-method list + parcel instructions/custom-note + distance/extra-charge + place-order). Parcel-specific fetches (category, instruction, why-choose, video-content, place-details) go through `ParcelRepository`/usecases; offline-methods, dm-tip, distance+extra-charge and place-order are delegated to the migrated `CheckoutRepository` (same split the legacy `ParcelService` used); zone resolution uses the migrated `LocationRepository`. Pure `ParcelCategory` entity + unified `data/models/parcel_category_model.dart` (`fromJson/toJson/toEntity/fromEntity`); the display/transport models (`why_choose`, `video_content`, `parcel_instruction`, `place_details`) moved to `data/models/` as the single shared surface (place/video models are also consumed by taxi + location). Navigation side-effects of the old `parcelCallback` moved to a stateless `domain/helpers/parcel_helper.dart`; snackbars (zone errors, place-order failure) surfaced via `actionStatus`/`actionMessage` and shown in `BlocListener`s. Note `TextEditingController`s moved into screen/widget State (rule 4). Legacy `ParcelController`/`ParcelService(Interface)`/`ParcelRepository(Interface)`/old `domain/models/parcel_category_model.dart` deleted + removed from get_di; empty `controllers/` and `domain/services/` folders removed; registered in `injection.dart`, provided app-wide in `main.dart`. All 3 screens moved to `presentation/pages/` and all 11 widgets to `presentation/widgets/` (class names stable for `RouteHelper`); old `screens/` + `widgets/` folders removed; importers (`route_helper`, `home_screen`, order `order_info_widget`/`order_calcuation_widget`) repointed. The shared `payment/widgets/offline_payment_button.dart` was decoupled from both `CheckoutController` and `ParcelController` to take plain `selectedOfflineBankIndex` + `onBankSelected` callback (checkout caller updated to `CheckoutState`/`CheckoutOfflineBankSelected`). Location-feature `serach_location_widget`/`location_search_dialog_widget` retargeted off `ParcelController` to `ParcelBloc`. `order_model`/`route_helper`/`dashboard parcel_bottom_sheet` repointed to the new category-model path. Cross-feature: payment (`offline_payment_screen`), dashboard (`dashboard_screen`), home (`home_screen`) still reference the deleted `ParcelController` — fixed on their turns. Pre-existing package-API errors left as-is: `DottedBorder`/`BorderType` (dotted_border) in `parcel_request_screen` (same as checkout `top_section`/order), and the `route_helper`/`AuthController` debt (auth transitional notes). Per user instruction, NO `bloc_test` file was added (deviates from §10 step 10). |
| all others | Not migrated (still GetX); each is migrated whole, never half |

Order: alphabetical, one feature at a time. Next up: `payment`, then `profile`, …

### auth — transitional notes (resolve on the relevant feature's turn)
- The legacy `auth/domain/reposotories/auth_repository(_interface).dart` and the old
  `auth/domain/models/{signup_body_model,social_log_in_body}.dart` are KEPT for now
  because the still-GetX `verification` and `deliveryman/store registration` features
  (and `route_helper`) consume them via `get_di`. Delete them when those migrate.
- `deliveryman_registration` and `store_registration` are separate GetX controllers under
  `auth/` — NOT migrated yet. Treat them as their own units later.
- Expected cross-feature breakage from deleting `AuthController` (fix on each turn):
  verification, splash, profile, parcel, order, menu, location, dashboard, route_helper,
  web_landing_page, pick_map_screen still reference `Get.find<AuthController>()`.
- Pre-existing (NOT migration-caused) errors remain in `social_login_widget.dart` from
  google_sign_in 7.x / flutter_facebook_auth 7.x API changes (`GoogleSignIn()` ctor,
  `signIn()`, `AccessToken.token/userId`). These belong to a dependency-upgrade task.
- Auth screens stay under `auth/screens/` (not moved to `presentation/pages`) to avoid
  rippling import changes into the many unmigrated features that reference them; move
  them once their consumers are migrated.

`core/` is complete and reusable — the next agent does NOT recreate failure/exceptions/
usecase/DI; just add the new feature's registrations to `lib/core/di/injection.dart`.

## 11. Address feature
data/datasources/address_remote_data_source.dart
data/models/address_model.dart
data/repositories/address_repository_impl.dart
domain/entities/address.dart
domain/repositories/address_repository.dart
domain/usecases/{get,add,update,delete}_address(es)_usecase.dart
presentation/bloc/{address_bloc, address_event, address_state}.dart
presentation/pages/{address_screen, add_address_screen}.dart
presentation/widgets/address_confirmation_dialogue.dart

DI: registered in `lib/core/di/injection.dart`; `AddressBloc` provided app-wide via
`MultiBlocProvider` in `main.dart`. All 42 imports of the old
`domain/models/address_model.dart` were repointed to `data/models/address_model.dart`.

**Known intentional breakage (fix on each feature's own turn):** deleting
`AddressController` left dangling `Get.find<AddressController>()` /
`GetBuilder<AddressController>` references in still-GetX features — splash, home,
dashboard, location, parcel, taxi_booking, checkout. These are NOT yet migrated; they
will read the app-wide `AddressBloc` (via `context.read<AddressBloc>()` / `BlocBuilder`)
when their own alphabetical turn comes. Do not patch them early.

## 12. Known cleanup debt
- Delete the scratch/fix/refactor files at the repo root (not part of the build).
- `web_cart_items_widget.dart`, `cart_item_widget.dart`, `item_bottom_sheet.dart`
  and checkout `BottomSection` reference `CartBloc`/`CheckoutBloc` that do not
  exist yet. Migrate `cart` and `checkout` whole, or revert those files to GetX.
- Those files also call methods directly on a Bloc (`addToCartOnline(...)`);
  convert to events during the cart migration.