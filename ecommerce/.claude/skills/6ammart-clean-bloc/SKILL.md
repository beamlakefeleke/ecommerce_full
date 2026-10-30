---
name: 6ammart-clean-bloc
description: Use this skill whenever writing, editing, reviewing, or migrating code in the 6amMart Flutter app (or any feature inside it). Applies to new features, GetX-to-BLoC migrations, refactors of existing controllers/repositories, adding API endpoints, adding routes, or writing tests. Ensures all code follows feature-based Clean Architecture with BLoC state management instead of the legacy GetX pattern.
---

# 6amMart — Clean Architecture (Feature-based) + BLoC

## When this skill applies
- Any task touching `lib/features/**`
- Any task touching `lib/core/**` (DI, errors, usecase base, networking)
- Any request to "add a feature", "add a screen", "fix a bug in X", "migrate X off GetX",
  or "refactor X" in this project
- Writing or updating tests for any of the above

## What to do first
1. Read `RULES.md` and `PROJECT_DOCUMENT.md` at the project root in full before writing
   any code. They are the authoritative spec. Do not improvise conventions that conflict.
2. The migration is **one feature at a time, alphabetically**. `address` is DONE and is
   the reference implementation — copy its structure exactly. Check `PROJECT_DOCUMENT.md`
   §10 for the current in-progress feature.
3. When you migrate a feature, migrate it **whole and delete its legacy files in the same
   change** (controller, domain/services, domain/repositories, old domain/models). There
   is exactly ONE implementation per feature — never leave a GetX copy behind, never add
   a parallel "legacy" file.
4. Cross-feature references WILL break when you delete a feature's controller (other
   still-GetX features import it). That is expected. Do NOT half-migrate those other
   features to make them compile — they are fixed when their own alphabetical turn comes.
   Leave them; the build for unmigrated features is allowed to be red mid-migration.

## Non-negotiables
- No `Get.find`, `Get.put`, `Get.lazyPut`, `.obs`, `GetBuilder`, `Obx`, `update()` inside
  a migrated feature's own code.
- `domain/` never imports `flutter/*`, `http`, `shared_preferences`, `get`, or anything
  from `data/` or `presentation/`.
- Every repository method returns `Either<Failure, T>` (`fpdart`). Data sources throw
  `ServerException` / `NetworkException`; the repository impl converts them to `Failure`.
- Entities are pure and immutable (`equatable`), with no json and no transport-only
  fields (e.g. no `ZoneData`).
- One Bloc per feature concern; no god-blocs. Input to a Bloc is ONLY via `add(Event)`.

## Pragmatic exceptions already in force (do not "fix" these)
These were decided during the `address` migration and apply repo-wide until the stack is
fully off GetX:
- **DI is manual `get_it`**, registered in `lib/core/di/injection.dart`
  (`configureDependencies()`). `injectable` codegen is NOT used. The get_it locator
  COEXISTS with the legacy GetX locator (`lib/helper/get_di.dart`) and reuses the single
  `ApiClient` the GetX locator creates.
- **`ApiClient` stays in `lib/api/api_client.dart`** (a `GetxService`). Do not move it to
  `lib/core/network`. Data sources receive it via constructor and call it with
  `handleError: false` so the repository can map the response to a `Failure`.
- **Routing stays GetX for now.** `go_router` is not introduced yet. Inside migrated
  presentation code you may still use `RouteHelper` + `Get.toNamed/offNamed/back` for
  navigation (navigation only — never for state or DI). Flag base64 web deep-links; don't
  change them.
- **Models may be standalone mutable classes** (not `extends Entity`) when unmigrated
  GetX code still mutates the model's fields in place (e.g. zone resolution). The model
  owns `fromJson/toJson/toEntity/fromEntity`. Convert to the entity before it reaches
  domain/presentation.

## Quick reference — where things go
```
lib/features/<feature>/data/datasources     → raw ApiClient calls; throw exceptions
lib/features/<feature>/data/models          → the single serializable model: fromJson/toJson/toEntity/fromEntity
lib/features/<feature>/data/repositories    → RepositoryImpl: try/catch → Left(Failure) / Right(entity)
lib/features/<feature>/domain/entities      → pure immutable Dart (equatable), no json
lib/features/<feature>/domain/repositories  → abstract contract returning Either<Failure,T>
lib/features/<feature>/domain/usecases      → one class, one call(Params), one action
lib/features/<feature>/presentation/bloc    → <feature>_bloc.dart + _event.dart + _state.dart
lib/features/<feature>/presentation/pages   → route-level screens (BlocBuilder/BlocConsumer)
lib/features/<feature>/presentation/widgets → feature-local widgets
lib/core/di/injection.dart                  → get_it registration (manual)
lib/core/error/{failure.dart, exceptions.dart}
lib/core/usecase/usecase.dart               → UseCase<Type,Params> + NoParams
```

## Reference implementation: `address`
Study `lib/features/address/**` before migrating anything else. It demonstrates:
- Pure `domain/entities/address.dart` (no json, no `ZoneData`).
- Mutable standalone `data/models/address_model.dart` with `toEntity`/`fromEntity`
  (mutable because unmigrated location/parcel/taxi code still mutates it).
- `AddressRemoteDataSource(Impl)` throwing exceptions; `AddressRepositoryImpl` mapping to
  `Either<Failure,T>`.
- Four usecases (get/add/update/delete), each a single `call()`.
- `AddressBloc` (event-driven) + `AddressEvent` (sealed) + `AddressState`
  (single class with `AddressStatus` + `AddressActionStatus` enums, because the loaded
  list must survive across add/update/delete).
- Registered in `core/di/injection.dart`; provided app-wide via `MultiBlocProvider`
  wrapping `GetMaterialApp` in `main.dart` (address list is cross-cutting state).
- Pages under `presentation/pages`, dialog under `presentation/widgets`.

## State modelling rule of thumb
- Use ONE immutable state class with a `status` enum (+ an `actionStatus` enum for
  mutations) when data such as a list must persist across multiple actions — see
  `AddressState`.
- Use a `sealed` state hierarchy only when the states are genuinely mutually exclusive
  and no data needs to carry across them.
- Surface one-shot outcomes (snackbars, navigation after save) via `BlocListener` keyed
  on `actionStatus` transitions, not by putting navigation inside the Bloc.

## Output expectations
- Migrating a feature means producing all three layers AND deleting the legacy GetX
  files AND removing the feature's registrations from `lib/helper/get_di.dart` AND adding
  the get_it registrations in `lib/core/di/injection.dart`.
- Add at least one `bloc_test` for the new Bloc (`mocktail` for usecase mocks).
- Run `getDiagnostics` on the migrated feature's files and on `main.dart` /
  `get_di.dart` / `core/di/injection.dart` before declaring done. Pre-existing errors in
  OTHER unmigrated features are acceptable.
