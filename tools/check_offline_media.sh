#!/usr/bin/env bash
set -euo pipefail

if rg -n -i 'firebase|firestore|pocketbase|supabase|firebase_storage|stripe|midtrans|xendit' pubspec.yaml lib --glob '*.yaml' --glob '*.dart'; then
  echo 'cloud backend, cloud storage, or payment gateway reference detected' >&2
  exit 1
fi

if rg -n "['\"]imageUrl['\"]\s*:" lib --glob '*.dart'; then
  echo 'legacy URL image persistence detected' >&2
  exit 1
fi

if rg -n 'XFile\s+[^;]*(toMap|Hive|put)|BuildContext\s+[^;]*(model|controller)' lib --glob '*.dart'; then
  echo 'temporary picker or UI context persistence detected' >&2
  exit 1
fi

if rg -n 'Hive\.|openBox' lib/app/modules --glob '*view*.dart' --glob '*controller*.dart'; then
  echo 'UI or controller must not access Hive directly' >&2
  exit 1
fi

if rg -n 'switch \(product\.categoryName\)|base64Decode\(' lib/app --glob '*.dart' --glob '!**/product_visual.dart' --glob '!**/product_image_service.dart'; then
  echo 'duplicated category icon mapping or image decoding detected' >&2
  exit 1
fi

rg -q "'taxType'" lib/app/data/models/order_model.dart
rg -q "'taxValue'" lib/app/data/models/order_model.dart
rg -q "'taxAmount'" lib/app/data/models/order_model.dart
rg -q "'iconName'" lib/app/data/models/category_model.dart
rg -q "'imageBase64'" lib/app/data/models/menu_item_model.dart

while IFS= read -r asset; do
  size=$(wc -c < "$asset")
  if (( size > 5242880 )); then
    echo "oversized bundled image: $asset" >&2
    exit 1
  fi
done < <(find assets -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \))

echo 'offline media and payment dependencies: ok'
