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
| **banner** | **NEXT (not started)** |
| all others | Not migrated (still GetX); each is migrated whole, never half |

Order: alphabetical, one feature at a time. Next up: `banner`, then `cart`, …

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