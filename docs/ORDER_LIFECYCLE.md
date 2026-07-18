# Order Lifecycle and Stock Safety

## State flow

```text
draft → held/saved → completed → refunded
   └──────────────→ cancelled
```

- `draft` exists only in the cashier cart and never changes stock.
- `held` and `saved` are persisted, resumable, and do not reserve or decrement stock.
- `completed` is produced only by `PosRepository.completeSale`; stock is validated and decremented exactly once.
- `cancelled` is available only from an open order and never changes stock.
- `refunded` is available only from a completed, stock-applied order. Returned stock is restored once and the reason and timestamp are retained.

Cancellation requires a reason and actor and applies only to open orders. Soft delete is a visibility/audit action, not a lifecycle status. Refund remains a stock reconciliation action for completed sales only.

Completed or refunded transactions remain history. No transaction can be permanently deleted in public demo mode. An Owner may move a record to Trash and restore it without replaying stock.

## Atomic Hive strategy

`LocalHiveRepository` loads products and orders, validates them, calculates every changed record in memory, captures snapshots, then writes product and transaction collections in a controlled sequence. Any failure restores both snapshots. Operation IDs and lifecycle flags prevent repeated completion and refund.

Receipt state is stored in the order record. A completed sale is first persisted with a receipt state, and the PDF printer result updates only that receipt state; a printer failure never reverses a valid sale.
