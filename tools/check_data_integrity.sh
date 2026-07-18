#!/usr/bin/env bash
set -euo pipefail

CONTROLLERS=$(find lib/app/modules lib/modules -path '*controller*.dart' -o -path '*/controllers/*.dart')

if rg -n 'Hive\.|openBox' $CONTROLLERS; then
  echo 'controllers must not access Hive directly' >&2
  exit 1
fi

if rg -n 'adjustStock|saveTransaction|deleteTransaction' $CONTROLLERS; then
  echo 'controllers must use lifecycle repository operations instead of coordinating stock/order writes' >&2
  exit 1
fi

if rg -n "['\"](draft|held|saved|completed|cancelled|refunded)['\"]" lib --glob '*.dart' --glob '!**/order_lifecycle.dart'; then
  echo 'order lifecycle strings must be centralized in order_lifecycle.dart' >&2
  exit 1
fi

rg -q 'completeSale' lib/repositories/pos_repository.dart
rg -q 'refundSale' lib/repositories/pos_repository.dart
rg -q 'permanent_delete_disabled' lib/repositories/local_hive_repository.dart
rg -q 'softDeleteOrder' lib/repositories/pos_repository.dart
rg -q 'restoreOrder' lib/repositories/pos_repository.dart
rg -q 'AppPermission' lib/repositories/local_hive_repository.dart
rg -q 'NotificationRepository' lib/repositories/pos_repository.dart
rg -q 'atomic_write_failed' lib/repositories/local_hive_repository.dart

echo 'data integrity: ok'
