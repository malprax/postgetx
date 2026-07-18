# Data Integrity Architecture

The active mutation path is `View → WorkspaceController → PosRepository → LocalHiveRepository → Hive`. Controllers may assemble user intent and refresh state, but they must not coordinate product and transaction writes.

Atomic operations are `completeSale`, `saveOpenOrder`, `cancelOpenOrder`, `softDeleteOrder`, `restoreOrder`, and `refundSale`. Each returns a typed `PosOperationResult` with a stable error code and human-readable message. Permanent deletion is disabled. See [ORDER_LIFECYCLE.md](ORDER_LIFECYCLE.md).

Hive schema version 5 adds local Owner/Staff users, payment audit fields, cancellation actors, soft-delete/restore metadata, and local notifications. Earlier records migrate in place; user-created categories, products, and transactions are not wiped. Version 4 tax, icon, and image fields remain backward compatible.

## Roles and authoritative permissions

`RolePermissions` is the single permission matrix. Routes and widgets use it for presentation, while `LocalHiveRepository` repeats every mutation check as the authoritative boundary. The current user ID is stored locally and restored from the seeded users collection; logout removes the session key. See [ROLE_PERMISSION_GUIDE.md](ROLE_PERMISSION_GUIDE.md).

## Local notifications and Trash

`NotificationRepository` keeps notification operations behind the repository boundary. Successful business mutations append actor snapshots to Hive; notification failure is intentionally secondary and never reverses a successful sale. Active order queries exclude `isDeleted` records, while Owner Trash explicitly requests them. Restore clears deletion metadata and never replays stock. See [NOTIFICATION_GUIDE.md](NOTIFICATION_GUIDE.md) and [SOFT_DELETE_AND_RESTORE.md](SOFT_DELETE_AND_RESTORE.md).

## Checkout totals

`PosTotalCalculator` is the only checkout formula. It computes subtotal, discount, taxable amount, tax, grand total, paid amount, and change in that order. `LocalHiveRepository` recalculates the result before accepting a sale. Transactions persist `taxType`, `taxValue`, and `taxAmount`; receipt generation reads those persisted fields and never applies a new formula.

## Local product media

`ProductImageService` owns picking, validation, decoding, resizing, and JPEG optimization. `MenuItemModel` persists only `imageBase64`, `imageMimeType`, and `imageName`. Widgets and controllers never persist `XFile`, absolute paths, or browser Blob URLs. `ProductVisual` is the one image decoder and uses the associated category's stable icon when image data is absent or corrupt.

## Category icons

`CategoryModel.iconName` is a stable string. `CategoryIconRegistry` is the sole mapping from stored names to Flutter `IconData`; raw icon data is never stored in Hive.
