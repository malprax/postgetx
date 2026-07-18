# Retail POS Offline Demo

Flutter and GetX retail point-of-sale demo with local Hive persistence.

The application has no cloud backend and runs offline on Android and Web. Demo
Owner credentials are `owner@demo.local` / `owner123`; Staff credentials are
`staff@demo.local` / `staff123`. Products, categories, customers, transactions,
notifications, and lifecycle examples are seeded automatically on first launch.

Data access is defined by repository interfaces in `lib/app/data/repositories`, allowing a
future PocketBase adapter without coupling controllers to a backend SDK.

Tahap 1 — Kunci struktur target
Tahap 2 — Identifikasi folder duplikat
Tahap 3 — Pilih source of truth
Tahap 4 — Pindahkan satu domain per tahap
Tahap 5 — Perbarui import
Tahap 6 — Analyze dan test
Tahap 7 — Hapus folder lama setelah terbukti aman
Tahap 8 — Dokumentasikan di Developer Handbook

ChatGPT
├── menjaga arsitektur
├── menentukan struktur folder
├── menentukan batas antar-layer
├── menentukan standar reusable source
├── meninjau dampak lintasproject
└── menyetujui refactor besar

Codex
├── mengimplementasikan file
├── memindahkan file sesuai peta
├── memperbarui import
├── memperbaiki compile error
├── menjalankan analyze dan test
└── tidak mengubah fondasi tanpa instruksi eksplisit
