# Payment Workflow

## Authoritative order

1. Sum cart lines into whole-rupiah subtotal.
2. Apply fixed or percentage discount, capped at subtotal.
3. Produce the non-negative taxable amount.
4. Apply tax: None, 0–100 percent, or a non-negative fixed rupiah amount.
5. Produce grand total, paid amount, and non-negative change.

`WorkspaceController` exposes the configuration and live result. `PosTotalCalculator` owns the formula. `LocalHiveRepository.completeSale` calculates the same result independently and rejects malformed tax, insufficient payment, mismatched totals, or insufficient stock. A completed transaction stores `taxType`, `taxValue`, and `taxAmount`.

Receipts receive a persisted `OrderModel` through `ReceiptData.fromOrder`. They display stored values only, so later configuration changes cannot alter historical receipts.

Legacy transactions without `taxType` remain readable. A legacy non-zero `tax` is preserved as a fixed amount; a missing or zero legacy tax becomes None.
## Cash collection workflow

`Cart → Pay → Cash Payment dialog → Confirm Payment → completeSale → receipt` is the only enabled payment flow in the offline demo.

- The dialog displays Total Due, accepts Amount Received, offers Exact Amount and practical denomination chips, and calculates Change live.
- Confirmation remains disabled until a finite amount at least equal to Total Due is entered. `processingOrder` prevents duplicate submission.
- The repository recalculates all totals and rejects malformed, insufficient, mismatched, or non-cash payments.
- Completed orders persist `paymentMethod`, `amountReceived`, `amountApplied`, `change`, and `paidAt`.
- `ReceiptData.fromOrder` and order detail views read those persisted values; neither recomputes payment history.
- Card and digital methods remain visibly unavailable because no cloud or payment SDK is installed.
