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

## 3. State management — BLoC, not GetX

- Replace every `GetxController` with a `Bloc` or `Cubit`:
  - **Cubit** for simple state (loading/success/error, single-purpose screens, toggles).
  - **Bloc** (event → state) when there are multiple distinct user actions/triggers, or
    when you need to react to streams (e.g. live order tracking, chat).
- No `Get.find<>()`, `Get.put()`, `Get.lazyPut()`, `.obs`, `GetBuilder`, `Obx`, or
  `update()` anywhere in new code.
- UI reads state via `BlocBuilder` / `BlocConsumer` / `BlocSelector`. UI dispatches
  intent via `context.read<XBloc>().add(...)` or `context.read<XCubit>().doThing()`.
- States are immutable, modeled with `sealed class` / `freezed` (preferred) — no mutable
  fields, no side effects inside a state class.
- One Bloc/Cubit per feature-page, not one giant app-wide Bloc.

**Example event/state naming:**
```dart
// events (imperative verb + noun)
class FetchCartRequested extends CartEvent {}
class CartItemRemoved extends CartEvent { final String itemId; }

// states (past-tense / descriptive)
sealed class CartState {}
class CartInitial extends CartState {}
class CartLoading extends CartState {}
class CartLoaded extends CartState { final List<CartItem> items; }
class CartError extends CartState { final String message; }
```

---

## 4. Dependency Injection

- Replace `get_di.dart` (GetX service locator) with **`get_it` + `injectable`**.
- Registration lives in `lib/core/di/injection.dart` (`configureDependencies()` called
  once in `main.dart`).
- Register:
  - Data sources and repositories as `@lazySingleton`.
  - Usecases as `@injectable` (cheap, stateless, created per use).
  - Blocs/Cubits as `@injectable` (new instance per screen) — injected via
    `BlocProvider(create: (_) => getIt<FeatureBloc>())`, never as app-wide singletons
    unless the state is genuinely global (theme, auth session, cart badge count).

---

## 5. Routing

- Replace `RouteHelper` (GetX named routes) with **`go_router`**.
- One `AppRouter` in `lib/core/router/app_router.dart` with typed route definitions.
- Route params passed as typed objects (via `extra:`) for mobile; web deep-links still
  use encoded query params where needed for shareable URLs — keep that behavior, just
  implement it through go_router's `GoRouteData` / query param parsing instead of GetX's
  base64 URL trick where a cleaner alternative exists.
- No `Get.to()`, `Get.toNamed()`, `Get.back()` — use `context.go()`, `context.push()`,
  `context.pop()`.

---

## 6. Networking & error handling

- Keep a single `ApiClient` (can still wrap `http` or migrate to `dio`), but it lives in
  `lib/core/network/api_client.dart` and is injected, not a `GetxService` singleton
  reached via `Get.find()`.
- Repository implementations catch exceptions from the data source and convert them to
  a `Failure` (sealed class: `ServerFailure`, `NetworkFailure`, `CacheFailure`, etc.)
- Usecases and repository interfaces return `Either<Failure, T>` (via `dartz` or
  `fpdart`) — no throwing exceptions across the domain boundary.
- Blocs catch the `Either` and emit an error state with a user-facing message; raw
  exceptions never reach the UI layer.

---

## 7. Models vs entities

- `domain/entities/*.dart` — plain immutable Dart classes, no `fromJson`/`toJson`.
- `data/models/*.dart` — extends or wraps the entity, adds `fromJson`/`toJson`/`toEntity()`.
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
| Page widget | `<Feature>Page` | `CartPage`, `CheckoutPage` |
| Model | `<Entity>Model` | `CartItemModel` |

---


## 10. Migration checklist (per feature, GetX → BLoC/Clean)

1. Extract the feature's models into `domain/entities` (strip json logic) +
   `data/models` (keep json logic).
2. Wrap existing API calls into a `<feature>_remote_data_source.dart`.
3. Write the `domain/repositories/<feature>_repository.dart` interface, then
   `data/repositories/<feature>_repository_impl.dart` implementing it.
4. Write one usecase per distinct action the old controller performed.
5. Replace the `GetxController` with a `Bloc`/`Cubit` that calls the usecases and emits
   states equivalent to the old `.obs` fields.
6. Replace `GetBuilder`/`Obx` in the screen with `BlocBuilder`/`BlocConsumer`.
7. Replace `Get.find<Controller>()` registrations in `get_di.dart` with `@injectable`
   annotations, then delete the old registration.
8. Delete the old controller once the page is fully switched over and tested.

Do features one at a time — this app is large (35+ features); do not attempt a
big-bang rewrite. `auth`, `cart`, and `home` are the highest-value/highest-risk features
to migrate first since most other features depend on them.

---

## 11. What NOT to do

- Don't mix GetX and BLoC inside the same feature once migration of that feature starts.
- Don't put business logic (API calls, calculations, validation) inside a widget or a
  Bloc's `build`-adjacent code — it belongs in a usecase.
- Don't let `data/models` leak into `presentation/` — always convert to entity first.
- Don't create a single monolithic `AppBloc` — keep blocs scoped to features, with only
  genuinely cross-cutting state (auth session, theme, cart badge) elevated to
  `lib/core/` and provided app-wide via `MultiBlocProvider` in `main.dart`.
