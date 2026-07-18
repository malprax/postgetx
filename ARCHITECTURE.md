# Malprax Application Architecture

Malprax follows a modular, offline-first architecture inspired by the Portfolio Platform's separation of composition, modules, shared UI, data boundaries, and developer tooling.

## Dependency flow

`View → WorkspaceController → PosRepository → LocalHiveRepository → Hive`

Views only render reactive state and send user intent. Controllers aggregate checkout and dashboard behavior. Repository interfaces are the stable boundary for a future backend, but this release contains no cloud provider. Models remain serialization-safe. Printer behavior stays behind `PrinterService`; the default adapter opens a PDF preview.

## Project map

- `lib/app`: composition, routes, bindings, modules, design system, shared UI.
- `lib/models`: domain records.
- `lib/repositories`: backend-agnostic contracts and Hive implementations.
- `lib/services`: printing and preserved business services.
- `lib/themes/theme_controller.dart`: persisted theme preference.
- `test`: repository, model, controller, and responsive journey coverage.
- `tools`: validation, backup, restore, and tree export scripts.

Hive boxes are initialized before `runApp`. `InitialBinding` maps abstractions to local implementations. No view or controller opens a Hive box directly.

Order and stock integrity rules are documented in [docs/ORDER_LIFECYCLE.md](docs/ORDER_LIFECYCLE.md). Checkout and refunds are application-level atomic repository operations with snapshot rollback and idempotency flags.
