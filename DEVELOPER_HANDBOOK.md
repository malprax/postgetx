# Developer Handbook

## Daily workflow

1. Run `flutter pub get` after dependency changes.
2. Add features under `lib/app/modules/<module>` and keep views presentation-only.
3. Reuse design tokens and shared widgets; do not introduce literal spacing, repeated panels, or route-local service construction.
4. Extend `PosRepository` before adding persistence behavior.
5. Run `bash tools/check_all.sh` before handoff.

The offline demo login is defined in `AppConfig`. Demo data is deterministic in shape and regenerated when `seedVersion` changes. Never store secrets in seed data or backups.

Controllers must never coordinate transaction and stock writes. Use the lifecycle operations on `PosRepository`; completed history is immutable and refunds require a reason.

## Definition of done

Formatting, analysis, tests, APK release, Web release, project validators, and `git diff --check` must pass. Update `CHANGELOG.md` and relevant module documentation with architectural changes.
