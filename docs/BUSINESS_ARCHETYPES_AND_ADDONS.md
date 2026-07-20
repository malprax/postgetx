# Business Archetypes, Presets, and Add-ons

## Status dokumen

Dokumen ini adalah rujukan produk untuk klasifikasi jenis usaha, komposisi
modul, preset **Mulai Cepat**, serta perilaku halaman **Setelan -> Modul &
Add-on** di keluarga produk Smart Cashier/CashierOS.

Dokumen ini melengkapi `SMART_CASHIER_PRODUCT_BLUEPRINT.md`:

- blueprint utama menetapkan visi, target pasar, dan prinsip produk;
- dokumen ini menetapkan taksonomi usaha serta cara fitur dikomposisikan;
- `ARCHITECTURE.md` tetap menetapkan batas dan arah implementasi aplikasi.

Semua kelompok di bawah merupakan arah produk. Keberadaannya dalam katalog
tidak berarti semuanya harus diimplementasikan sekaligus.

## 1. Prinsip klasifikasi

Jenis usaha di dunia dapat dibagi menjadi ribuan industri. CashierOS tidak
boleh membuat aplikasi terpisah untuk setiap nama industri. Sistem
menggeneralisasikan usaha berdasarkan:

```text
skala usaha x arketipe transaksi x aktivitas operasional x vertical pack
```

Satu bisnis dapat mengaktifkan lebih dari satu arketipe. Contoh:

- toko game dan barang koleksi: Retail + Resale + Marketplace;
- bengkel: Service + Retail;
- hotel dengan restoran: Hospitality + Food & Beverage;
- distributor dengan toko: Wholesale + Retail;
- tempat rental console: Rental + Retail + Membership.

Core menangani kemampuan lintas-industri. Vertical pack hanya menambahkan
atribut, aturan, istilah, dan workflow yang benar-benar khusus.

## 2. Empat belas arketipe usaha

| No. | Arketipe | Contoh | Mesin operasional utama |
| ---: | --- | --- | --- |
| 1 | Retail | Minimarket, fashion, toko game | POS, stok, purchasing |
| 2 | Resale & Collectibles | Barang bekas, TCG, diecast | Grading, trade-in, konsinyasi |
| 3 | Food & Beverage | Restoran, kafe, bakery | Menu, meja, resep, dapur |
| 4 | Service | Salon, bengkel, laundry | Booking, job order, teknisi |
| 5 | Professional Service | Konsultan, pengacara, agensi | Proyek, waktu, retainer |
| 6 | Rental | Kendaraan, console, alat | Kalender aset, deposit, denda |
| 7 | Hospitality | Hotel, vila, kos | Kamar, reservasi, check-in |
| 8 | Property & Vehicle Brokerage | Tanah, apartemen, mobil | Listing, lead, agen, komisi |
| 9 | Marketplace & Auction | Marketplace niche, lelang | Seller, escrow, bid, settlement |
| 10 | Wholesale & Distribution | Distributor, grosir | Harga bertingkat, PO, piutang |
| 11 | Manufacturing | Pabrik, konveksi, produksi | BOM, work order, QC |
| 12 | Subscription & Membership | Gym, klub, SaaS | Paket, periode, recurring billing |
| 13 | Education & Events | Kursus, seminar, turnamen | Kelas, peserta, tiket |
| 14 | Healthcare & Care Service | Klinik, apotek, home care | Pasien, appointment, rekam layanan |

Organisasi nirlaba dapat menjadi arketipe tambahan di masa depan, tetapi
sebagian besar kebutuhannya merupakan kombinasi Membership, Event, Donation,
CRM, dan Accounting.

### 2.1 Retail

Subjenis mencakup general retail, fashion, elektronik, game dan hobby,
apotek retail, supermarket, furniture, bahan bangunan, dan online shop.

Fitur pembeda: POS, barcode, variasi, inventory, supplier, purchase order,
retur, promosi, loyalty, multi-cabang, pengiriman, dan e-commerce.

### 2.2 Resale & Collectibles

Subjenis mencakup game bekas, console, TCG, diecast, action figure, barang
antik, thrift, elektronik bekas, dan barang mewah bekas.

Fitur pembeda: condition grading, inspeksi, autentikasi, nomor seri, trade-in,
konsinyasi, pembagian hasil, riwayat harga, lelang, sertifikat pemeriksaan,
dan garansi barang bekas.

### 2.3 Food & Beverage

Subjenis mencakup restoran, kafe, warung, bakery, catering, cloud kitchen,
dan food truck.

Fitur pembeda: menu dan modifier, meja, kitchen display, resep, bahan baku,
dine-in/takeaway/delivery, split bill, service charge, tip, expiry, dan waste.

### 2.4 Service

Subjenis mencakup salon, barbershop, spa, bengkel, laundry, cleaning service,
reparasi elektronik, dan percetakan.

Fitur pembeda: booking, kalender staf, work order, estimasi, status pekerjaan,
suku cadang, foto sebelum/sesudah, teknisi, komisi, pickup, dan garansi jasa.

### 2.5 Professional Service

Subjenis mencakup konsultan, pengacara, akuntan, agensi, software house,
arsitek, dan freelancer.

Fitur pembeda: CRM, proposal, kontrak, proyek, milestone, timesheet, retainer,
invoice berkala, approval klien, dokumen, dan profitabilitas proyek.

### 2.6 Rental

Subjenis mencakup rental kendaraan, console, kamera, alat berat, pakaian,
dan venue.

Fitur pembeda: ketersediaan aset, kalender sewa, booking, deposit,
check-in/check-out, kondisi, denda, biaya kerusakan, pemakaian, maintenance,
dan perpanjangan.

### 2.7 Hospitality

Subjenis mencakup hotel, vila, hostel, kos, homestay, dan camping ground.

Fitur pembeda: tipe kamar, kalender ketersediaan, harga per tanggal,
reservasi, deposit, check-in/check-out, housekeeping, identitas tamu,
layanan tambahan, dan channel booking.

### 2.8 Property & Vehicle Brokerage

Subjenis mencakup tanah, rumah, apartemen, properti komersial, mobil, motor,
dan alat berat.

Fitur pembeda: listing, pemilik aset, agen, lead pipeline, survei, test drive,
inspeksi, dokumen, booking/DP, negosiasi, komisi, dan featured listing.

### 2.9 Marketplace & Auction

Marketplace adalah model bisnis yang dapat dipasang pada arketipe lain.

Fitur pembeda: seller onboarding, verifikasi seller, moderasi listing,
komisi, escrow, split settlement, saldo seller, pencairan, sengketa, rating,
auction engine, dan fraud monitoring.

### 2.10 Wholesale & Distribution

Subjenis mencakup distributor, importir, grosir, supplier restoran,
distributor farmasi, dan B2B commerce.

Fitur pembeda: minimum order, harga bertingkat, sales order, purchase order,
piutang, termin, kredit limit, sales representative, rute pengiriman, batch,
expiry, multi-gudang, picking, dan packing.

### 2.11 Manufacturing

Subjenis mencakup pabrik, konveksi, furniture, produksi makanan, kerajinan,
dan perakitan elektronik.

Fitur pembeda: bill of materials, bahan baku, work order produksi, kapasitas,
waste, quality control, batch, serial, harga pokok produksi, dan maintenance.

### 2.12 Subscription & Membership

Subjenis mencakup gym, klub, coworking, komunitas, membership toko, SaaS,
dan langganan produk.

Fitur pembeda: paket, periode, recurring billing, auto-renewal, pause,
upgrade/downgrade, kuota, check-in anggota, benefit, grace period, dan churn.

### 2.13 Education & Events

Subjenis mencakup kursus, bimbingan belajar, workshop, seminar, turnamen,
event organizer, dan penjualan tiket.

Fitur pembeda: kelas, sesi, jadwal, pengajar, peserta, kapasitas, tiket,
QR check-in, sertifikat, pembayaran bertahap, kehadiran, dan venue.

### 2.14 Healthcare & Care Service

Subjenis mencakup klinik, dokter, dokter gigi, apotek, laboratorium,
perawatan hewan, dan home care.

Fitur pembeda: pasien, appointment, tenaga kesehatan, rekam layanan, resep,
batch dan expiry obat, persetujuan tindakan, billing, dan asuransi.

Vertical ini memiliki kebutuhan regulasi dan perlindungan data tinggi. Ia
bukan prioritas awal dan tidak boleh diaktifkan hanya dengan mengganti label
modul umum.

## 3. Kelompok modul lintas-industri

| Kelompok | Kemampuan |
| --- | --- |
| Identity | Pengguna, login, sesi, dan pemulihan akun |
| Organization | Bisnis, cabang, outlet, dan konfigurasi tenant |
| Roles & Permissions | Role, kapabilitas, approval, dan audit akses |
| Customer & CRM | Pelanggan, member, lead, segmentasi, dan pipeline |
| Catalog | Produk, layanan, aset, listing, kategori, dan atribut |
| POS & Transactions | Keranjang, order, booking, kontrak, dan deal |
| Inventory | Stok, batch, serial, gudang, dan pergerakan barang |
| Supplier & Partner | Supplier, penitip, pemilik aset, dan mitra |
| Invoice | Quotation, invoice, DP, pelunasan, pajak, dan refund document |
| Payment | Tunai, QRIS, transfer, gateway, escrow, dan settlement |
| Fulfillment | Pickup, kurir, tracking, reservasi, survei, dan test drive |
| Marketing | Promo, voucher, loyalty, referral, dan automation |
| Analytics | Dashboard, margin, conversion, funnel, dan laporan |
| HR | Pegawai, agen, shift, target, komisi, dan kehadiran |
| Trust, Safety & Compliance | KYC/KYB, moderasi, sengketa, dan fraud control |
| Tools & Integration | Import/export, API, webhook, backup, dan integrasi |

Istilah layar boleh berubah sesuai vertical, tetapi domain inti tidak boleh
digandakan. Contoh pemetaan istilah:

| Core | Collectibles | Property & Vehicle |
| --- | --- | --- |
| Product | Produk/koleksi | Listing/aset |
| Inventory | Stok | Listing aktif |
| Supplier/Partner | Supplier/penitip | Pemilik aset |
| Customer | Pembeli | Calon pembeli/lead |
| Staff | Kasir/admin | Agen/admin |
| Checkout | Checkout | Ajukan minat/booking |
| Fulfillment | Pengiriman | Survei/test drive |
| Sale | Penjualan | Deal |
| Commission | Komisi penitip | Komisi agen |

## 4. Status dan tingkat modul

Halaman **Setelan -> Modul & Add-on** menggunakan status berikut:

| Status | Makna |
| --- | --- |
| Aktif | Fitur sedang digunakan |
| Nonaktif | Fitur tersedia tetapi belum digunakan |
| Dasar | Kemampuan minimum untuk operasi sederhana |
| Lanjutan | Kemampuan penuh untuk operasi lebih kompleks |
| Premium | Membutuhkan paket atau biaya tambahan |
| Terkunci | Membutuhkan dependensi yang belum aktif |
| Tidak relevan | Disembunyikan untuk preset tersebut |
| Bersyarat | Aktif berdasarkan kategori yang dipilih |

Kontrol boleh digeser, diketuk, atau dioperasikan dengan tombol/keyboard.
Drag bukan satu-satunya mekanisme karena aksesibilitas dan kenyamanan mobile.

Pola posisi umum:

```text
Nonaktif <- Fitur Dasar <- Fitur Lanjutan
```

Sebelum menyimpan perubahan, sistem wajib menampilkan:

1. fitur yang ditambahkan atau dikurangi;
2. dependensi yang ikut aktif;
3. perubahan biaya;
4. data atau transaksi aktif yang terdampak;
5. waktu mulai berlakunya perubahan.

Menonaktifkan modul tidak menghapus data. Modul yang memiliki transaksi aktif,
saldo, sengketa, atau proses belum selesai tidak boleh dinonaktifkan sebelum
ketergantungannya diselesaikan.

## 5. Preset Mulai Cepat

Onboarding tidak menampilkan matriks add-on. Pengguna memilih jenis bisnis,
kategori, lalu memakai preset rekomendasi.

```text
Buat Bisnis
-> Pilih jenis usaha
-> Pilih kategori
-> Mulai Cepat
-> Sistem mengaktifkan preset
-> Pengguna dapat menyesuaikan melalui Modul & Add-on
```

Pilihan **Sesuaikan Modul** tersedia sebagai jalur sekunder.

## 6. Preset Toko Hobi & Koleksi

### 6.1 Kategori

```text
Hobi & Koleksi
|-- Game
|   |-- Game fisik
|   |-- Console
|   |-- Handheld
|   `-- Aksesori
|-- Trading Card Game
|-- Diecast
|-- Action Figure
|-- Model Kit
|-- Toys
|-- Retro
`-- Merchandise
```

### 6.2 Posisi awal modul

| Kelompok | Posisi awal |
| --- | --- |
| POS | Dasar |
| Catalog & Inventory | Lanjutan |
| Invoice | Dasar |
| Payment | Pembayaran lokal |
| Website | Katalog + checkout |
| Supplier & Consignor | Dasar |
| Warehouse | Satu lokasi |
| Courier | Pengiriman domestik |
| Marketing | Dasar |
| Customer & CRM | Data pelanggan |
| Analytics | Laporan bisnis |
| HR | Role dasar |
| Inspection | Aktif |
| Trade-in | Aktif |
| Consignment | Aktif |
| Auction | Nonaktif |
| Escrow | Nonaktif |
| Multi-seller Marketplace | Nonaktif |

### 6.3 Feature pack Collectibles

| Kelompok | Fitur |
| --- | --- |
| Catalog | Platform, region, bahasa, edition, rarity, series, scale |
| Condition | Baru/sealed, opened, Grade A/B/C, untested, junk |
| Inspection | Checklist, foto/video, autentikasi, sertifikat, garansi |
| Game & Console | Region Guard, DLC compatibility, serial, controller test |
| TCG | Set, card number, rarity, centering, grading company |
| Diecast/Figure | Scale, box, paint, joint, accessories, authenticity |
| Trade-in | Estimasi, appraisal final, store credit, cash payout |
| Consignment | Kontrak, komisi, masa titip, payout, return |
| Auction | Open bid, increment, timer, injury time, auto-bid, winner invoice |
| Commerce | Preorder, wishlist, bundling, shipping, review |

Workflow utama:

```text
Beli -> Mainkan/Koleksi -> Jual kembali / Trade-in / Titip-jual / Lelang
```

## 7. Preset Properti & Kendaraan

### 7.1 Kategori

```text
Properti & Kendaraan
|-- Properti
|   |-- Tanah
|   |-- Rumah
|   |-- Apartemen
|   |-- Ruko
|   |-- Gudang
|   `-- Properti komersial
`-- Kendaraan
    |-- Mobil
    |-- Motor
    `-- Kendaraan komersial
```

### 7.2 Posisi awal modul

| Kelompok | Posisi awal |
| --- | --- |
| POS | Tidak relevan |
| Catalog | Mode listing lanjutan |
| Invoice | Booking + komisi |
| Payment | Transfer + booking/DP |
| Website | Listing + lead form |
| Supplier & Partner | Mode pemilik aset |
| Warehouse | Tidak relevan; gunakan lokasi aset |
| Courier | Tidak relevan; gunakan survei/test drive |
| Marketing | Listing promotion |
| Customer & CRM | Pipeline lead |
| Analytics | Lead & deal analytics |
| HR | Agen + permission |
| Schedule | Survei aktif; test drive bersyarat |
| Asset Documents | Aktif |
| Inspection | Nonaktif |
| Auction | Nonaktif |
| Escrow | Nonaktif |
| External Multi-agent | Nonaktif |

### 7.3 Feature pack Properti

| Kelompok | Fitur |
| --- | --- |
| Identity | Jenis aset, jual/sewa, pemilik, agen |
| Specification | Luas tanah/bangunan, kamar, fasilitas, furnished |
| Location | Alamat, koordinat, area publik tersamar, akses jalan |
| Documents | Jenis sertifikat, status verifikasi, masa berlaku |
| Commercial | Harga total, harga per meter, service charge, nego |
| Media | Foto, video, virtual tour, denah |
| Workflow | Lead, follow-up, survei, negosiasi, booking, deal |

### 7.4 Feature pack Kendaraan

| Kelompok | Fitur |
| --- | --- |
| Identity | Jenis, merek, model, varian, tahun |
| Specification | Kilometer, transmisi, bahan bakar, warna |
| Documents | Pajak, STNK, BPKB, kepemilikan |
| Privacy | Nomor polisi dan nomor rangka tersamar |
| Condition | Riwayat servis/kecelakaan, mesin, bodi, interior |
| Workflow | Lead, test drive, inspeksi, negosiasi, booking, deal |
| Optional | Trade-in dan simulasi pembiayaan melalui mitra |

Pipeline default:

```text
LEAD_BARU
-> DIHUBUNGI
-> TERTARIK
-> SURVEI_ATAU_TEST_DRIVE
-> NEGOSIASI
-> BOOKING_ATAU_DP
-> DEAL / BATAL
```

## 8. Matriks kelompok modul untuk dua preset awal

| Kelompok | Hobi & Koleksi | Properti & Kendaraan |
| --- | --- | --- |
| POS | Penjualan langsung, hold, retur, struk | Disembunyikan |
| Inventory/Listing | SKU, barcode, stok, serial, kondisi | Listing, status, masa tayang, lokasi |
| Invoice | Invoice penjualan/refund | Quotation, booking, DP, komisi |
| Payment | Tunai, QRIS, transfer, gateway | Transfer, gateway, DP |
| Marketing | Promo, bundling, voucher, loyalty | Featured listing, campaign, referral |
| Analytics | Penjualan, margin, stok, repeat buyer | Lead, funnel, agen, deal, komisi |
| Supplier/Partner | Supplier dan penitip | Pemilik aset |
| Warehouse/Location | Stok, rak, transfer | Lokasi aset dan wilayah agen |
| Courier/Fulfillment | Ongkir, label, tracking, asuransi | Survei dan test drive |
| HR | Kasir, admin stok, inspector | Agen, admin, inspector |
| Tools | Barcode, import, label, API | Import listing, maps, documents, API |
| Trust & Safety | Seller, autentikasi, sengketa | Owner/agent, dokumen, sengketa |

## 9. Dependensi penting

| Fitur yang diaktifkan | Dependensi minimum |
| --- | --- |
| Checkout online | Catalog, Order, Invoice, Payment |
| Courier integration | Order, alamat, berat/dimensi produk |
| Trade-in | Catalog, Condition, Inspection, Payment/Store Credit |
| Consignment | Partner, Contract, Catalog, Order, Split Settlement |
| Auction | Catalog, Identity, Notification, Invoice, Payment |
| Escrow | KYC/KYB, Payment, Settlement, Dispute, Audit |
| Multi-seller | Seller onboarding, KYC/KYB, Moderation, Settlement |
| Property listing | Owner, Location, Documents, Lead CRM |
| Vehicle test drive | Identity, Lead CRM, Schedule, KYC, SIM verification |
| Agent commission | HR/Agent, Deal, Commission Rule, Invoice/Settlement |

## 10. Trust, Safety & Compliance serta KYC

Istilah **KNY** yang muncul dalam diskusi sementara diasumsikan sebagai salah
ketik dari **KYC (Know Your Customer)**. Jika KNY memiliki definisi produk lain,
dokumen ini harus diperbarui sebelum implementasi.

KYC tidak ditempatkan hanya di Payment atau HR. Ia merupakan kemampuan lintas
platform dalam kelompok:

```text
Trust, Safety & Compliance
|-- Verifikasi email
|-- Verifikasi nomor telepon
|-- KYC individu
|-- KYB bisnis
|-- Verifikasi rekening
|-- Verifikasi dokumen
|-- Risk scoring
|-- Fraud monitoring
|-- Blacklist
|-- Audit log
|-- Moderasi
`-- Sengketa
```

### 10.1 Tingkat verifikasi

| Level | Pemeriksaan | Kemampuan umum |
| --- | --- | --- |
| 0 | Email atau telepon | Menjelajah dan menyimpan item |
| 1 | Identitas dasar | Membeli atau booking risiko rendah |
| 2 | Dokumen identitas + selfie/liveness | Menjual dan menerima pencairan |
| 3 | KYB dan dokumen bisnis | Menjadi merchant/agen bisnis |
| Enhanced Due Diligence | Pemeriksaan berbasis risiko | Transaksi bernilai/risiko tinggi |

KYC diterapkan secara proporsional, bukan dipaksakan kepada setiap pengunjung.

| Aktivitas | Verifikasi minimum yang disarankan |
| --- | --- |
| Membeli produk biasa | Nomor telepon |
| Mengikuti lelang | Telepon; KYC jika nilai/risiko tinggi |
| Menjadi seller | KYC |
| Menerima pencairan | KYC + rekening |
| Menjadi merchant | KYB |
| Titip barang bernilai tinggi | KYC |
| Memasang properti | KYC pemilik dan agen |
| Mengunggah dokumen aset | KYC/KYB |
| Booking kendaraan | KYC berdasarkan risiko |
| Test drive | KYC + verifikasi SIM |

## 11. Aturan produk dan implementasi

1. Preset adalah konfigurasi, bukan aplikasi atau database terpisah.
2. Vertical pack tidak boleh menduplikasi Order, Payment, Invoice, Inventory,
   Identity, atau sistem route yang sudah dimiliki core.
3. Modul vertical boleh menambahkan atribut, validasi, workflow, dan istilah.
4. Satu tenant dapat menggabungkan beberapa arketipe.
5. Fitur yang tidak relevan disembunyikan, bukan dipaksakan ke pengguna.
6. Upgrade tidak boleh memerlukan restart bisnis atau migrasi manual pengguna.
7. Menonaktifkan fitur tidak menghapus data historis.
8. Perubahan konfigurasi penting wajib masuk audit log.
9. Dependensi dan perubahan harga harus terlihat sebelum pengguna menyimpan.
10. Fitur berisiko tinggi seperti escrow, KYC, healthcare, dan pembiayaan
    memerlukan tinjauan hukum, keamanan, dan operasional sebelum dirilis.

## 12. Prioritas produk saat ini

Peta 14 arketipe adalah arah jangka panjang. Implementasi awal tetap dibatasi
pada dua kerja sama nyata:

1. **Collectibles Commerce** — Retail + Resale + Marketplace;
2. **Property & Vehicle Listings** — Brokerage + CRM + Booking.

Urutan yang disarankan:

```text
Collectibles MVP
-> Property & Vehicle Listing MVP
-> validasi penggunaan nyata
-> ekstraksi core bersama
-> perluasan vertical berikutnya
```

Toko mitra pertama menjadi design partner dan tempat validasi operasional.
CashierOS Core tumbuh dari kebutuhan yang terbukti, bukan dari upaya membangun
seluruh arketipe sekaligus.
