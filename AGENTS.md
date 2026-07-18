# PostGetX Agent Contract

Read `ARCHITECTURE.md` before changing source structure.

## Non-negotiable architecture

- `lib/app/` is the canonical application root; `lib/main.dart` is the only
  application source allowed outside it after migration completes.
- Use `app/core` for cross-application foundations, `app/data` for models and
  data boundaries, `app/modules` for business features, `app/shared` for
  reusable presentation, `app/routes` for navigation, and `app/theme` for the
  design system.
- Do not create parallel `models`, `modules`, `repositories`, `services`,
  `routes`, `themes`, `widgets`, `utils`, `bindings`, or `config` roots.
- Preserve dependency direction: UI -> controller -> repository -> provider.
  Widgets and controllers must not access Hive or another backend directly.
- Do not move, rename, delete, duplicate, or replace architectural sources
  without an explicit migration map and user authorization.
- Migrate one domain at a time. Update imports, architecture guards, and tests
  in the same change. Delete legacy sources only after verification passes.
- Reuse existing abstractions and design-system components. Do not introduce a
  second result type, route system, theme system, repository, or shared widget
  serving the same responsibility.

## Mandatory verification

Before handoff, run:

```text
dart format lib test
flutter analyze
flutter test test/architecture_guard_test.dart
flutter test
git diff --check
```

Never weaken or bypass `test/architecture_guard_test.dart` merely to make a
structural change pass. If a requested change conflicts with this contract,
stop and report the current path, proposed path, dependencies, and risk.
