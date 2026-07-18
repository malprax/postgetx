# 1. QA Environment

- Browser method: Codex In-app Browser (`iab`) controlled through its Playwright-compatible accessibility API.
- Application URL: `http://localhost:8080`, serving `build/web` with `python3 -m http.server`.
- Browser version: not exposed by the In-app Browser metadata; browser name and type were exposed, but no engine/version field was available.
- Viewports exercised: `1440x900`, `1024x768`, `820x1180`, and `390x844`.
- Data profile: existing local Hive/IndexedDB demo database. Seeded credentials were confirmed from source: Owner `owner@demo.local / owner123`, Staff `staff@demo.local / staff123`.
- Build under test: release Web build produced after the verified runtime fix.
- Browser session was finalized and the local HTTP server was stopped after testing.

# 2. Runtime Defects Found

One verified runtime defect was found and fixed.

- Exact defect: after a successful cash sale, the transaction persisted and the cart emptied, but the Cash Payment dialog could remain visible while browser receipt preview was still pending.
- Root cause: the dialog awaited `saveOrder`, and `saveOrder` awaited `Printing.layoutPdf`. Browser print preview can remain unresolved, so a successful persistence result could not close the dialog promptly.
- Fix: `saveOrder` now returns the persisted `OrderModel`; cash checkout persists with `print: false`, closes the dialog immediately after a successful result, and starts `printReceipt` asynchronously. Existing callers using `print: true` retain their prior behavior.
- Regression test: `successful sale can return before browser receipt preview completes` in `test/cashier_lifecycle_controller_test.dart` uses a blocking printer and proves the successful sale returns independently of preview completion.
- Revalidation: exact cash for `Rp7.425` persisted as `T-1519756`; within 900 ms the dialog was closed, Cart was `0`, and the new order appeared. Affected tests passed: 23 tests across `cashier_lifecycle_controller_test.dart` and `workspace_correction_widget_test.dart`.

# 3. Manual Validation Matrix

| Flow | Account | Steps | Expected | Actual | Result |
|---|---|---|---|---|---|
| Owner login/session | Owner | Entered seeded Owner demo session | Owner identity and administrative navigation visible | `Demo Owner / Owner`; Products, Inventory, Reports, Expenses, Settings, Notifications, and Trash visible | PASS |
| Staff login/session | Staff | Signed out Owner, selected Staff Demo | Staff identity and cashier navigation visible | `Demo Staff / Staff`; Checkout, Orders, Customers, Notifications visible | PASS |
| Owner permissions | Owner | Opened Orders, Trash, refund and restore actions | Owner-only actions available | Refund, Move to Trash, Restore, and administrative navigation were available | PASS |
| Staff UI restrictions | Staff | Opened Orders and inspected actions/navigation | No refund, trash, restore, or administrative modules | Completed rows exposed only detail/print; open rows exposed resume/cancel; owner-only navigation absent | PASS |
| Staff direct-route restriction | Staff | Navigated directly to `#/cashier/trash` | Restricted route rejected | Redirected to `#/cashier`; Trash page did not render | PASS |
| Repository authorization | Staff | Reviewed repository permission checks and existing repository regression coverage | Unauthorized calls rejected below UI layer | `LocalHiveRepository` guards privileged operations; targeted repository tests previously passed | PASS |
| Exact cash | Owner | Added Water Bottle, Pay, Exact Amount, Confirm | Change `Rp0`, transaction persists, dialog closes | Total `Rp7.425`, Change `Rp0`, order `T-1519756`, Cart `0`, dialog closed after fix | PASS |
| Cash overpayment | Owner | Added Water Bottle and entered `10000` | Live positive change and matching persisted values | Total `Rp7.425`, received `Rp10.000`, Change `Rp2.575`; order detail retained those values | PASS |
| Insufficient cash | Owner | Entered `7000` for `Rp7.425` total | Confirm disabled and no mutation | Validation said amount was insufficient; confirmation remained unavailable; no transaction completed | PASS |
| Receipt/print preview value match | Owner | Completed overpayment and invoked production print path | Preview must show total, received, applied, and change from persisted order | Persisted order detail matched, but the required rendered receipt screenshot could not be produced after SDK/browser access became unavailable | FAIL |
| Hold | Owner | Opened Held filter, resumed `DEMO-HELD`, then held it again | Held state visible; cart restored once; stock unchanged | One Water Bottle restored once, no duplicate line, Cart returned to `0` after re-hold | PASS |
| Save as Order | Owner | Saved Cola with note `QA pickup after 5 PM` | Saved order with pending payment and note | `T-1705045` appeared as SAVED with correct note and pending payment | PASS |
| Resume without duplication | Owner | Resumed an open order | Items restored exactly once | Browser cart showed the expected single line only; repository lifecycle coverage also passed | PASS |
| Cancellation dialog | Owner | Opened Cancel on saved order | Reason, Back, Confirm Cancellation; no Delete | All required controls present; no Delete option | PASS |
| Cancel/history | Owner | Cancelled `T-1705045` with a reason | Status Cancelled and record remains in history | Record remained under Cancelled with reason-driven notification | PASS |
| Soft delete separation | Owner | Used Move to Trash with reason | Separate dialog and no hard deletion | Separate Move to Trash flow used reason `QA soft-delete verification`; active record disappeared | PASS |
| Trash audit | Owner | Opened Trash | `deletedAt`, `deletedBy`, and reason visible | `T-1705045`, deletion time, `demo-owner`, reason, and Restore were displayed | PASS |
| Restore | Owner | Restored `T-1705045` | Record returns without replaying stock; notification created | Record returned to Cancelled history and an `Order restored` notification appeared | PASS |
| Refund | Owner | Recorded Water Bottle stock, refunded `T-1519756` with reason | Refunded status; stock restored exactly once | Stock changed `36 -> 37`; order status became REFUNDED | PASS |
| Duplicate refund | Owner/Staff | Inspected post-refund actions and repository guard coverage | Second refund rejected | Refund action disappeared after REFUNDED; repository tests cover direct duplicate rejection | PASS |
| Staff refund restriction | Staff | Opened Orders | No refund action | No `Refund sale` action was present | PASS |
| Bell unread count | Owner | Generated lifecycle events and opened bell | Badge reflects unread count | Badge increased with events and decreased immediately `9 -> 8` after reading one | PASS |
| Latest five/newest first | Owner | Opened notification dropdown | Exactly five newest, newest first | Restore, Trash, Cancel, Save, Hold shown in that order | PASS |
| Unread highlight | Owner | Inspected dropdown and full list | Unread visually distinct | Unread entries used highlighted backgrounds; read entry used normal state | PASS |
| Mark read/navigation | Owner | Clicked `Order restored` notification | Mark read, badge update, relevant navigation | Badge decremented immediately and Orders route remained/opened | PASS |
| View All / filters | Owner | Opened All Notifications and selected Unread | Complete list and working All/Unread filters | Full list rendered; read restored item was absent from Unread | PASS |
| Mark all read persistence | Owner | Marked all read and refreshed | Read state persists | After reload, no unread badge, Mark all read disabled, and every row offered Mark as unread | PASS |
| Responsive 1440x900 | Owner/Staff | Exercised cashier, orders, dialogs, notifications, Trash | No overflow or clipped controls | No overflow marker, RenderFlex text, or clipped primary dialog observed | PASS |
| Responsive 1024x768 | Staff | Resized active cashier and inspected semantics/render | Layout remains usable | Checkout remained accessible; no RenderFlex/overflow marker found | PASS |
| Responsive 820x1180 | Staff | Resized active cashier and inspected semantics/render | Layout remains usable | Checkout remained accessible; no RenderFlex/overflow marker found | PASS |
| Responsive 390x844 | Staff | Resized cashier, inspected drawer/catalog/cart, added Water Bottle | Mobile layout and cart usable without overflow | Drawer control, categories, products, dashboard panels, and Pay `Rp7.425` were accessible; no RenderFlex marker found | PASS |
| Light theme | Owner | Selected Light in Settings | Readable light palette | Light selection activated during the live session | PASS |
| Dark theme | Owner | Selected Dark in Settings | Readable dark palette | Dark selection activated during the live session | PASS |
| Auto theme persistence | Owner | Selected Auto and refreshed | Auto remains selected after refresh | Settings reloaded, but the accessibility tree did not expose an active selected segment after refresh; persistence could not be manually evidenced | FAIL |

# 4. Browser Console and Network Results

- Console inspection returned no browser error or warning entries before browser control was denied for further localhost interaction.
- Local server audit recorded only HTTP `200` and `304` responses for `/`, `flutter_bootstrap.js`, `main.dart.js`, `favicon.png`, `FontManifest.json`, Material Icons, and Cupertino Icons.
- No asset `404`, failed HTTP request, Hive/IndexedDB error, uncaught Flutter exception, routing exception, RenderFlex message, or hit-test exception was observed during the completed walkthrough.
- The browser control service later rejected further localhost actions. This was a QA-tool access restriction, not an application console/runtime error, and no workaround was attempted.

# 5. Screenshot Evidence

| File | Viewport | Account | Evidence | Status |
|---|---:|---|---|---|
| `artifacts/qa/01_owner_login.png` | 1440x900 | Owner | Owner cashier session and owner navigation | PASS / exists |
| `artifacts/qa/02_staff_login.png` | 1440x900 | Staff | Staff identity and restricted navigation | FAIL / missing |
| `artifacts/qa/03_cash_dialog_change.png` | 1440x900 | Owner | `Rp7.425` total and `Rp2.575` change | PASS / exists |
| `artifacts/qa/04_receipt_with_change.png` | 1440x900 target | Owner | Rendered receipt with persisted change | FAIL / missing |
| `artifacts/qa/05_held_orders.png` | 1440x900 | Owner | Held Orders state | PASS / exists |
| `artifacts/qa/06_saved_order_detail.png` | 1440x900 | Owner | Saved detail and note | PASS / exists |
| `artifacts/qa/07_cancellation_dialog.png` | 1440x900 | Owner | Cancellation reason/Back/Confirm; no Delete | PASS / exists |
| `artifacts/qa/08_trash_page.png` | 1440x900 | Owner | Trash audit fields and Restore | PASS / exists |
| `artifacts/qa/09_restored_order.png` | 1440x900 | Owner | Restored record in Cancelled history | PASS / exists |
| `artifacts/qa/10_notification_dropdown_unread.png` | 1440x900 | Owner | Badge, unread styling, latest five | PASS / exists |
| `artifacts/qa/11_all_notifications.png` | 1440x900 | Owner | Complete notification center | PASS / exists |
| `artifacts/qa/12_staff_restricted_actions.png` | 1440x900 | Staff | Staff order actions without owner-only controls | FAIL / missing |

Nine of the twelve mandatory screenshots exist. The missing files are not fabricated. Staff states were manually verified through the live accessibility tree, but their screenshot byte buffers were not persisted before browser access ended. A deterministic QA-only receipt generator was added at `tools/qa/generate_receipt_evidence.dart`, but it could not execute because Dart required an SDK-cache write outside the workspace and escalation could not be approved.

# 6. Automated Validation

| Command | Exact result |
|---|---|
| `flutter clean` | PASS during clean baseline |
| `flutter pub get` | PASS during clean baseline; final rerun BLOCKED by `/Users/auliasabril/Developer/flutter/bin/cache/engine.stamp: Operation not permitted` |
| `dart format lib test` | PASS during baseline, 0 files changed; final rerun BLOCKED by the same SDK-cache permission |
| `flutter analyze` | PASS after runtime fix: `No issues found!`; final full rerun unavailable |
| `flutter test` | Baseline PASS: 66 tests; post-fix affected suites PASS: 23 tests, including the new regression; final full-suite rerun unavailable |
| `flutter build web --release` | PASS after runtime fix; WASM dry-run warning only |
| `flutter build apk --release` | Final rerun unavailable because Flutter SDK cache access was denied |
| `bash tools/check_all.sh` | FAIL at the runtime boundary: routes, theme, Hive, assets, seed, data integrity, and offline-media checks all printed `ok`; then Dart failed on `engine.stamp` permission |
| `git diff --check` | PASS, exit code 0, no output |
| `bash tools/check_routes.sh` | PASS: `routes: ok` |
| `bash tools/check_theme.sh` | PASS: `theme: ok` |
| `bash tools/check_hive.sh` | PASS: `hive: ok` |
| `bash tools/check_assets.sh` | PASS: `assets: ok` |
| `bash tools/check_seed.sh` | PASS: `seed: ok` |
| `bash tools/check_data_integrity.sh` | PASS: `data integrity: ok` |
| `bash tools/check_offline_media.sh` | PASS: `offline media and payment dependencies: ok` |
| Production source scan | PASS: no `firebase`, `firestore`, `pocketbase`, or `supabase` matches in `pubspec.yaml`, `pubspec.lock`, `lib`, or platform source directories |
| Public-demo deletion review | PASS: `deleteOpenOrder` always returns `permanent_delete_disabled`; order removal uses audited soft-delete/restore fields |
| Repository role review | PASS: privileged repository methods enforce `AppPermission`; Staff permission set excludes refund, trash, restore, and administration |
| Commit | PASS: no commit created |

# 7. Remaining Issues

1. Mandatory screenshot evidence is incomplete: `02_staff_login.png`, `04_receipt_with_change.png`, and `12_staff_restricted_actions.png` do not exist. The live Staff states were verified, but the requirement explicitly demands persisted screenshots.
2. Receipt/print-preview equality is not visually proven. Persisted transaction detail contains the correct total, received amount, applied amount, and change, but the production PDF could not be rendered after Dart SDK-cache access was denied.
3. Auto theme persistence is covered by automated theme tests but was not conclusively exposed as selected by the browser accessibility tree after refresh.
4. Final post-fix `flutter pub get`, complete format/analyze/test sequence, Android release build, and `tools/check_all.sh` cannot be certified in this run because the Flutter/Dart launcher attempted to update an SDK cache outside the writable workspace. The required escalation was unavailable.

# 8. GO / NO-GO Recommendation

NO-GO — FIXES STILL REQUIRED
