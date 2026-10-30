# 6amMart Flutter — Architecture & Coding Rules
### Target stack: Feature-based Clean Architecture + BLoC (migrating off GetX)

These rules govern how every feature in this codebase must be structured, named, and
implemented. They apply to new code and to any GetX code being migrated.

---

## 1. Layering (per feature)

Every feature lives in its own folder under `lib/features/<feature_name>/` and is split
into exactly three layers. Nothing skips a layer — presentation never talks to data
directly, and data never talks to presentation.

```
lib/features/<feature_name>/
├── data/
│   ├── datasources/
│   │   ├── <feature>_remote_data_source.dart
│   │   └── <feature>_local_data_source.dart      # only if local caching is needed
│   ├── models/
│   │   └── <entity>_model.dart                   # extends the domain entity, adds fromJson/toJson
│   └── repositories/
│       └── <feature>_repository_impl.dart        # implements the domain interface
├── domain/
│   ├── entities/
│   │   └── <entity>.dart                          # plain Dart, no json, no flutter imports
│   ├── repositories/
│   │   └── <feature>_repository.dart              # abstract class (the contract)
│   └── usecases/
│       └── <verb_noun>_usecase.dart               # one usecase = one class = one `call()`
└── presentation/
    ├── bloc/
    │   ├── <feature>_bloc.dart
    │   ├── <feature>_event.dart
    │   └── <feature>_state.dart
    ├── pages/
    │   └── <feature>_page.dart                    # route-level widgets only
    └── widgets/
        └── <feature>_<thing>.dart                 # feature-local reusable widgets
```

**Rule:** `domain/` has zero dependencies on Flutter, `data/`, or `presentation/`. It is
pure Dart. This is what makes the business logic testable and framework-independent.

---

## 2. Dependency direction

```
presentation  →  domain  ←  data
```

- `presentation` depends on `domain` (entities, usecases, repository interfaces).
- `data` depends on `domain` (implements the repository interface, returns entities).
- `domain` depends on **nothing** inside the feature or app.
- Cross-feature access only happens through `domain` (e.g. Cart feature may depend on
  Auth feature's `domain/entities/user.dart`, never on Auth's bloc or data layer).

---

## 3. State management — BLoC (event-driven), not GetX

- Replace every `GetxController` with a **`Bloc`** (event → state). Prefer `Bloc` over
  `Cubit` across this codebase so input is uniform. Input to a Bloc is ONLY via
  `add(Event)` — a Bloc exposes **no public methods**.
- No `Get.find<>()`, `Get.put()`, `Get.lazyPut()`, `.obs`, `GetBuilder`, `Obx`, or
  `update()` anywhere in a migrated feature's own code. (`Get.toNamed/back` for
  navigation only is still allowed until go_router lands — see §5.)
- UI reads state via `BlocBuilder` / `BlocConsumer` / `BlocSelector`. UI dispatches
  intent via `context.read<XBloc>().add(...)`.
- States are immutable (`equatable`). Two accepted shapes:
  - **One state class + status enums** when data (e.g. a loaded list) must survive across
    multiple actions. Add a second `*ActionStatus` enum for mutations so the list isn't
    cleared while an add/update/delete runs. This is the DEFAULT — see `AddressState`.
  - **`sealed` state hierarchy** only when states are genuinely mutually exclusive and no
    data needs to carry across them.
- One Bloc per feature concern, not one giant app-wide Bloc.
- Surface one-shot outcomes (snackbar, navigate after save) via `BlocListener` keyed on
  an `actionStatus` transition. Never put navigation or snackbars inside the Bloc.

**Reference naming (from the migrated `address` feature):**
```dart
// events — sealed, imperative verb + noun
sealed class AddressEvent extends Equatable { const AddressEvent(); }
class AddressListRequested extends AddressEvent {}
class AddressAdded extends AddressEvent { final Address address; }
class AddressDeleted extends AddressEvent { final int? id; final int index; }

// state — single class, status enums, list survives across actions
enum AddressStatus { initial, loading, loaded, error }
enum AddressActionStatus { none, inProgress, success, failure }
class AddressState extends Equatable {
  final AddressStatus status;
  final List<Address> addresses;
  final AddressActionStatus actionStatus;
  final String? actionMessage;
  // copyWith(...), props [...]
}
```

---

## 4. Dependency Injection — manual `get_it` (no codegen), coexisting with GetX

- Use **`get_it`, registered MANUALLY** in `lib/core/di/injection.dart`
  (`configureDependencies()`), called once in `main.dart` AFTER the legacy `di.init()`.
  **`injectable` codegen is NOT used** — do not add `@injectable`/`@lazySingleton`
  annotations or run build_runner for DI.
- The get_it locator **coexists** with the legacy GetX locator (`lib/helper/get_di.dart`)
  during migration. It reuses the single `ApiClient` the GetX locator already created:
  ```dart
  if (!getIt.isRegistered<ApiClient>()) {
    getIt.registerLazySingleton<ApiClient>(() => getx.Get.find<ApiClient>());
  }
  ```
- Register per feature:
  - Data source + repository impl: `registerLazySingleton`.
  - Usecases: `registerFactory`.
  - Bloc: `registerFactory` (new instance per screen) — provided via
    `BlocProvider(create: (_) => getIt<FeatureBloc>())`, EXCEPT genuinely cross-cutting
    state (e.g. the address list) which is provided app-wide (see §4a).
- When migrating a feature, also DELETE that feature's `Get.lazyPut(...)` lines and
  imports from `lib/helper/get_di.dart`.

## 4a. App-wide (cross-cutting) blocs

Cross-cutting state consumed by many screens (address list, and later theme / auth
session / cart badge) is provided once via `MultiBlocProvider` wrapping `GetMaterialApp`
in `main.dart`:
```dart
MultiBlocProvider(
  providers: [
    BlocProvider<AddressBloc>(create: (_) => clean_di.getIt<AddressBloc>()),
  ],
  child: GetMaterialApp(...),
)
```
Because the provider wraps `GetMaterialApp`, all GetX-routed pages are descendants and
can `context.read<AddressBloc>()`.

---

## 5. Routing — GetX for now (go_router is a later, separate migration)

- `go_router` is **not introduced yet**. `RouteHelper` + `GetMaterialApp` named routes
  remain the routing mechanism during the feature-by-feature state migration.
- Inside migrated presentation code, `Get.toNamed()`, `Get.offNamed()`, `Get.back()`,
  `Get.dialog()` are **allowed for navigation/dialogs only** — never for state or DI.
  (Compare `address` pages, which still navigate via `RouteHelper`.)
- Do not rename migrated page classes/constructors (e.g. keep `AddressScreen`,
  `AddAddressScreen`) because `RouteHelper.routes` references them. Moving a page file
  into `presentation/pages` is fine as long as you update the two importers
  (`route_helper.dart` and any embedding screen).
- When go_router is eventually introduced it gets its own `lib/core/router/app_router.dart`
  and its own migration pass. The base64-encoded web deep-link params (e.g.
  `getItemImagesRoute`) are intentional for SEO/shareable URLs — preserve them.

---

## 6. Networking & error handling

- The single `ApiClient` stays at **`lib/api/api_client.dart`** (it is still a
  `GetxService`). Do NOT move it to `lib/core/network`. It is passed to data sources via
  constructor (resolved from get_it, which bridges to the GetX-created instance).
- Data sources are the ONLY layer that calls `ApiClient`. Call it with
  `handleError: false` and inspect `response.statusCode`. On non-200 (or the client's
  `0`/`1` no-internet sentinels) throw `ServerException` / `NetworkException` from
  `lib/core/error/exceptions.dart`. No GetX `Response` type leaks above the data source.
- Repository impls catch those exceptions and convert them to a `Failure`
  (`lib/core/error/failure.dart`: `ServerFailure`, `NetworkFailure`, `CacheFailure`,
  `UnexpectedFailure`), returning `Either<Failure, T>` (`fpdart`).
- Usecases extend `UseCase<Type, Params>` from `lib/core/usecase/usecase.dart` and return
  the repository's `Either`. Use `NoParams` when there is no input.
- Blocs `fold` the `Either` and emit an error/action-failure state with a user-facing
  message; raw exceptions never reach the UI layer.
- Preserve any special legacy message mapping (e.g. `'Out of coverage!'` →
  `'service_not_available_in_this_area'.tr`) inside the repository impl.

---

## 7. Models vs entities

- `domain/entities/*.dart` — plain immutable Dart (`equatable`), no `fromJson`/`toJson`,
  no transport-only fields (strip things like `zoneData` that exist only for the wire).
- `data/models/*.dart` — the ONE serializable representation. It provides
  `fromJson`/`toJson`/`toEntity()` and `fromEntity()`.
  - Preferred: `extends <Entity>` with immutable fields.
  - Allowed exception: a **standalone mutable class** (own fields, not `extends Entity`)
    when still-unmigrated GetX code mutates the model's fields in place. `AddressModel`
    is mutable for exactly this reason (location/parcel/taxi mutate zone fields). Convert
    to the entity via `toEntity()` before it reaches domain/presentation.
- There is exactly ONE model per concept, living in `data/models/`. When migrating, DELETE
  the old `domain/models/<x>.dart` and repoint every import to `data/models/<x>.dart`.
- API responses are parsed **only** inside `data/`. `presentation/` and `domain/` never
  see a `Map<String, dynamic>` or a raw HTTP response.

---

## 8. Naming conventions

| Thing | Convention | Example |
|---|---|---|
| Feature folder | `snake_case`, singular | `cart`, `order`, `taxi_booking` |
| Bloc/Cubit class | `<Feature>Bloc` / `<Feature>Cubit` | `CartBloc`, `ThemeCubit` |
| Usecase class | verb + noun + `UseCase` | `GetCartItemsUseCase`, `PlaceOrderUseCase` |
| Repository interface | `<Feature>Repository` | `CartRepository` |
| Repository impl | `<Feature>RepositoryImpl` | `CartRepositoryImpl` |
| Page widget | keep existing name during migration | `AddressScreen`, `CartScreen` |
| Model | `<Entity>Model` | `CartItemModel`, `AddressModel` |
| Event | imperative verb + noun | `AddressListRequested`, `AddressDeleted` |
| State | `<Feature>State` (+ status enums) | `AddressState` / `AddressStatus` |

> Page classes keep their current `<Feature>Screen` names (not `<Feature>Page`) so the
> GetX `RouteHelper.routes` references keep compiling until go_router lands.

---

## 9. The `address` feature is the reference implementation

Before migrating any feature, read `lib/features/address/**` end to end and mirror it:
```
address/
├── data/
│   ├── datasources/address_remote_data_source.dart   # throws Server/NetworkException
│   ├── models/address_model.dart                      # mutable; fromJson/toJson/toEntity/fromEntity
│   └── repositories/address_repository_impl.dart      # Either<Failure,T>, maps legacy messages
├── domain/
│   ├── entities/address.dart                          # pure, immutable, no zoneData
│   ├── repositories/address_repository.dart           # abstract contract
│   └── usecases/{get_addresses, add_address, update_address, delete_address}_usecase.dart
└── presentation/
    ├── bloc/{address_bloc, address_event, address_state}.dart
    ├── pages/{address_screen, add_address_screen}.dart
    └── widgets/address_confirmation_dialogue.dart
```
Registered in `lib/core/di/injection.dart`; provided app-wide in `main.dart` via
`MultiBlocProvider`. Legacy `AddressController`, `AddressService(Interface)`,
`AddressRepository(Interface)` and the old `domain/models/address_model.dart` were
DELETED, and all 42 import sites were repointed to `data/models/address_model.dart`.

---


## 10. Migration checklist (per feature, GetX → BLoC/Clean)

Order: **strictly alphabetical, one feature at a time.** `address` is DONE. See
`PROJECT_DOCUMENT.md` §10 for the current feature. Do not big-bang.

Each feature migration is a SINGLE change that produces the new stack AND deletes the
legacy files. Steps:

1. **Entity** — create `domain/entities/<entity>.dart` (pure, immutable, no json, no
   transport-only fields).
2. **Model** — create the single `data/models/<entity>_model.dart`
   (`fromJson/toJson/toEntity/fromEntity`). DELETE the old `domain/models/<entity>.dart`
   and repoint every import across `lib/` to the new path.
3. **Data source** — `data/datasources/<feature>_remote_data_source.dart` wrapping the
   old repository's `ApiClient` calls; throw `ServerException`/`NetworkException`.
4. **Repository** — `domain/repositories/<feature>_repository.dart` (abstract, returns
   `Either<Failure,T>`) + `data/repositories/<feature>_repository_impl.dart` (try/catch →
   `Left(Failure)` / `Right(entity)`).
5. **Usecases** — one `domain/usecases/<verb>_<noun>_usecase.dart` per distinct action the
   old controller performed; each extends `UseCase<Type,Params>`.
6. **Bloc** — `presentation/bloc/<feature>_bloc.dart` + `_event.dart` + `_state.dart`
   (event-driven; state shape per §3). It calls usecases and `fold`s the `Either`.
7. **DI** — register data source / repo / usecases / bloc in
   `lib/core/di/injection.dart`; add the bloc to `MultiBlocProvider` in `main.dart` only
   if it is cross-cutting. DELETE the feature's `Get.lazyPut(...)` lines + imports from
   `lib/helper/get_di.dart`.
8. **UI** — move screens to `presentation/pages`, widgets to `presentation/widgets`;
   replace `GetBuilder`/`Obx` with `BlocBuilder`/`BlocConsumer`; replace controller calls
   with `context.read<XBloc>().add(...)`; use `BlocListener` for snackbars/navigation.
   Keep page class names stable so `RouteHelper` keeps compiling.
9. **Delete legacy** — remove the GetX controller, `domain/services/*`,
   `domain/repositories/*` (interface + old impl), and old `domain/models/*`. Remove now
   -empty legacy folders.
10. **Test** — add at least one `bloc_test` (mock usecases with `mocktail`).
11. **Verify** — `getDiagnostics` clean on the migrated feature's files + `main.dart` +
    `get_di.dart` + `core/di/injection.dart`.

**Expect cross-feature breakage, and leave it.** Deleting a feature's controller breaks
imports in OTHER still-GetX features that referenced it (e.g. deleting `AddressController`
breaks parcel/location/home/taxi). That is acceptable and intended — those features are
fixed on their own alphabetical turn. Do NOT half-migrate them now just to make the whole
app compile.

---

## 11. What NOT to do

- Don't mix GetX and BLoC inside the SAME feature once its migration starts, and don't
  leave a "legacy" copy of a migrated file. One implementation per feature.
- Don't half-migrate OTHER features just to fix cross-feature breakage — leave them red
  for their own turn (§10).
- Don't add `injectable`/`@lazySingleton` annotations or build_runner for DI — DI is
  manual `get_it` (§4).
- Don't move `ApiClient` out of `lib/api/`, and don't introduce `go_router` as part of a
  state migration — those are separate, later passes (§5, §6).
- Don't put a public method on a Bloc; input is only via `add(Event)`. Don't put
  navigation or snackbars inside a Bloc — use `BlocListener`.
- Don't put business logic (API calls, calculations, validation) inside a widget — it
  belongs in a usecase.
- Don't let `data/models` leak into `presentation/` — convert to entity first.
- Don't rename migrated page classes/constructors referenced by `RouteHelper`.
- Don't create a monolithic `AppBloc` — scope blocs to features; only genuinely
  cross-cutting state is provided app-wide via `MultiBlocProvider` in `main.dart`.
