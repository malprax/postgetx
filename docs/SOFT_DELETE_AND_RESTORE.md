# Soft Delete and Restore

Soft delete sets `isDeleted`, `deletedAt`, `deletedBy`, and `deleteReason`. Active order queries exclude the record; Owner Trash uses `includeDeleted: true` and displays its audit metadata.

Restore is Owner-only. It clears deletion fields, records `restoredAt` and `restoredBy`, and returns the same record ID to active history. It does not create a new transaction, decrement stock, or restore stock again.

Cancel is separate: it closes a held/saved order with reason and actor while retaining it in history. Refund is separate: it reconciles a completed sale and restores stock at most once. Permanent delete is disabled in public demo mode.
