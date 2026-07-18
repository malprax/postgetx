# Malprax Application Architecture

Malprax follows a modular, offline-first architecture inspired by the Portfolio Platform's separation of composition, modules, shared UI, data boundaries, and developer tooling.

## Dependency flow

`View → WorkspaceController → PosRepository → LocalHiveRepository → Hive`

Views only render reactive state and send user intent. Controllers aggregate checkout and dashboard behavior. Repository interfaces are the stable boundary for a future backend, but this release contains no cloud provider. Models remain serialization-safe. Printer behavior stays behind `PrinterService`; the default adapter opens a PDF preview.

## Canonical project map

- `lib/app/core`: cross-application configuration, helpers, and services.
- `lib/app/data`: models, providers, and backend-agnostic repositories.
- `lib/app/modules`: business features with their bindings, controllers,
  views, and feature-local widgets.
- `lib/app/routes`: the only application navigation source.
- `lib/app/shared`: reusable layouts, forms, and presentation components.
- `lib/app/theme`: the only design system and theme source.
- `lib/main.dart`: application entry point.
- `test`: repository, model, controller, and responsive journey coverage.
- `tools`: validation, backup, restore, and tree export scripts.

Top-level source folders such as `lib/models`, `lib/modules`,
`lib/repositories`, `lib/services`, `lib/routes`, `lib/themes`, `lib/widgets`,
`lib/utils`, `lib/bindings`, and `lib/config` are forbidden. Production source
must remain under `lib/app`; only `lib/main.dart` is exempt. This boundary is
enforced by `test/architecture_guard_test.dart`.

Every completed domain migration must be recorded in
`test/architecture_guard_test.dart`. A structural change is incomplete until
the guard, analyzer, and complete test suite pass.

Business behavior is protected by native Flutter BDD scenarios under
`test/behavior/`. Every changed business rule must describe observable
Given–When–Then outcomes and pass `tools/check_bdd.sh`. BDD scenarios supplement
lower-level tests and remain independent of implementation details.

Hive boxes are initialized before `runApp`. `InitialBinding` maps abstractions to local implementations. No view or controller opens a Hive box directly.

Order and stock integrity rules are documented in [docs/ORDER_LIFECYCLE.md](docs/ORDER_LIFECYCLE.md). Checkout and refunds are application-level atomic repository operations with snapshot rollback and idempotency flags.
