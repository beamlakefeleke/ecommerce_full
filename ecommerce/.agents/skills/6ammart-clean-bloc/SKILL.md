---
name: 6ammart-clean-bloc
description: Use this skill whenever writing, editing, reviewing, or migrating code in the 6amMart Flutter app (or any feature inside it). Applies to new features, GetX-to-BLoC migrations, refactors of existing controllers/repositories, adding API endpoints, adding routes, or writing tests. Ensures all code follows feature-based Clean Architecture with BLoC state management instead of the legacy GetX pattern.
---

# 6amMart — Clean Architecture (Feature-based) + BLoC

## When this skill applies
- Any task touching `lib/features/**`
- Any task touching `lib/core/**` (DI, routing, networking, theme)
- Any request to "add a feature", "add a screen", "fix a bug in X", "migrate X off GetX",
  or "refactor X" in this project
- Writing or updating tests for any of the above

## What to do first
1. Read `RULES.md` at the project root in full before writing any code — it is the
   authoritative spec for folder structure, naming, DI, routing, and state management
   in this repo. Do not improvise conventions that conflict with it.
2. Check whether the target feature already has a `data/domain/presentation` split.
   - If yes: follow the existing pattern in that feature exactly.
   - If no (still GetX): follow the "Migration checklist" in `RULES.md` §10 rather than
     patching the old controller — new code should not be added to a `GetxController`.
3. Identify which layer the task actually belongs to before writing anything:
   - New API call or field → `data/`
   - New business rule (validation, calculation, orchestration) → `domain/usecases`
   - New screen state or user interaction → `presentation/bloc`
   - New widget/screen → `presentation/pages` or `presentation/widgets`

## Non-negotiables
- No `Get.find`, `Get.put`, `Get.lazyPut`, `.obs`, `GetBuilder`, `Obx`, `Get.to*`,
  `Get.back` in any file this skill touches.
- `domain/` never imports `flutter/*`, `dio`, `http`, `shared_preferences`, or anything
  from `data/`.
- Every repository method returns `Either<Failure, T>`; usecases and blocs propagate
  that, never a raw throw across a layer boundary.
- One Bloc/Cubit per screen-scoped concern; no god-blocs.

## Quick reference — where things go
```
lib/features/<feature>/data/datasources     → raw API/local storage calls
lib/features/<feature>/data/models          → DTOs with fromJson/toJson
lib/features/<feature>/data/repositories    → RepositoryImpl, converts exceptions→Failure
lib/features/<feature>/domain/entities      → pure Dart business objects
lib/features/<feature>/domain/repositories  → abstract contracts
lib/features/<feature>/domain/usecases      → one class, one call(), one action
lib/features/<feature>/presentation/bloc    → Bloc/Cubit + Event + State
lib/features/<feature>/presentation/pages   → route-level screens
lib/features/<feature>/presentation/widgets → feature-local widgets
lib/core/di                                 → get_it + injectable registration
lib/core/network                            → ApiClient, interceptors, Failure types
lib/core/router                             → go_router route definitions
```

## Output expectations
- When asked to implement a feature end-to-end, produce all four layers (or reuse
  existing ones), not just the widget.
- When asked to migrate a GetX feature, migrate one feature fully rather than partially
  touching several — see priority order in `RULES.md` §10 (`auth`, `cart`, `home` first).
- When unsure whether something is cross-cutting (belongs in `lib/core/`) or
  feature-local, default to feature-local; only promote to `core/` once a second feature
  needs the same thing.
- Flag, but don't silently "fix", any place where the existing 6amMart web deep-link
  behavior (base64-encoded query params) would break under a routing change — that
  behavior is intentional for SEO/shareable URLs and needs an explicit decision, not an
  assumption.
