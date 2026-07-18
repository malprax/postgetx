# Changelog

## Sprint 2 — Professional Payment Workflow

- Added None, Percentage, and Fixed Amount tax modes to the authoritative total calculator, repository validation, Hive transaction schema, and PDF receipt.
- Added schema version 4 in-place migration for tax, category icon names, and local product image fields.
- Added an 18-option responsive category icon picker backed by one stable-name registry.
- Added offline JPEG/PNG/WebP selection, validation, resizing, optimization, preview, replacement, removal, and corrupt-data fallback.
- Added reusable product visuals across cashier, product management, inventory, cart, and alert surfaces.
- Expanded repository, model, service, responsive widget, persistence, and receipt-consistency tests.

## Sprint 1 — Data Integrity

- Formalized draft, held, saved, completed, cancelled, and refunded order states.
- Added Hive schema version 3 migration with backward-compatible lifecycle defaults.
- Added atomic checkout and refund with snapshot rollback and idempotency protection.
- Prevented destructive deletion of completed/refunded transactions.
- Added open-order resume/cancel/delete controls and required refund reasons.
- Moved stock reconciliation out of controllers.
- Added repository failure injection plus lifecycle, rollback, migration, and controller tests.
## Roles, Notifications, Order Actions, and Cash Payment Correction

- Added seeded Owner and Staff local accounts with centralized route/action/repository permissions and persistent local sessions.
- Added professional cash collection, live change, persisted payment audit fields, and receipt consistency.
- Separated Hold, Save as Order, Cancel, Soft Delete, Restore, and Refund semantics.
- Added Owner Trash for orders and disabled permanent transaction deletion.
- Added Hive-backed notifications, bell latest-five menu, unread state, filters, and actor snapshots.
- Migrated Hive schema to version 5 and expanded automated role, payment, lifecycle, notification, route, and widget tests.
