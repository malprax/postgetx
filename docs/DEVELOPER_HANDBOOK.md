# Data Mutation Rules

1. Never call Hive from a controller or widget.
2. Never decrement or restore stock in a controller.
3. Complete checkout with one `PosRepository.completeSale` call.
4. Persist held/saved orders through `saveOpenOrder`; they do not affect stock.
5. Cancel or delete only open orders through their repository operations.
6. Never delete a completed transaction; refund it with a required reason.
7. Await repository persistence before clearing a cart, refreshing UI, printing, or notifying the user.
8. Treat `stockApplied` and `stockRestored` as repository-owned idempotency fields.
9. Add a rollback/failure test whenever an atomic write sequence changes.
10. Add or change totals only through `PosTotalCalculator`; repeat the validation in `LocalHiveRepository`.
11. Store category icons by a name registered in `CategoryIconRegistry`, never a code point or `IconData`.
12. Send product media through `ProductImageService`; never write file paths, Blob URLs, or `XFile` objects to models or Hive.
13. Preserve image fields on edit unless the user explicitly chooses Remove Image.
14. Run `bash tools/check_all.sh` before release builds.

## Sprint 2 verification

- Exercise None, Percentage, and Fixed Amount tax modes and compare the pay amount with the saved receipt.
- Create and edit a category, refresh the app, and confirm the icon remains selected.
- Create a product with no image, with an image, replace it, refresh, and remove it.
- Test at 1440, 1024, 820, and 390 logical pixels in Light, Dark, and Auto theme modes.
- Android uses the gallery picker; Web persists optimized Base64 through Hive/IndexedDB. Neither flow requires internet access.
## Roles and notification workflow

## Demo access

- Owner: `owner@demo.local` / `owner123`
- Staff: `staff@demo.local` / `staff123`

Passwords are salted SHA-256 demo fixtures, not a production credential system. Never reuse this representation for a real deployment.

## Mutation checklist

1. Add intent to `PosRepository` (or `NotificationRepository`).
2. Enforce `AppPermission` inside `LocalHiveRepository`; hiding a button is insufficient.
3. Write the primary records first, then create a non-blocking local notification.
4. Preserve order actors and stock idempotency.
5. Add repository and widget coverage, then run `bash tools/check_all.sh`.

Session, notifications, roles, orders, and products remain local Hive data. No network is required.
