# Smart Cashier Product Blueprint

## Status dokumen

Dokumen ini adalah rujukan utama visi produk Smart Cashier di bawah Playkit
Media Pustaka. Ia mengunci keputusan produk yang harus dibaca sebelum membuat
fitur, paket komersial, landing page, dokumentasi pengguna, atau vertikal usaha
baru.

Dokumen ini menjelaskan **mengapa** dan **untuk siapa** fitur dibuat.
`ARCHITECTURE.md` tetap menjadi rujukan **bagaimana** aplikasi diimplementasikan.
Jika implementasi yang diusulkan bertentangan dengan prinsip di dokumen ini,
pekerjaan harus dihentikan untuk meninjau kembali ruang lingkup produk.

Taksonomi 14 arketipe usaha, kelompok modul lintas-industri, preset **Mulai
Cepat**, komposisi add-on, serta posisi KYC didokumentasikan dalam
[`BUSINESS_ARCHETYPES_AND_ADDONS.md`](BUSINESS_ARCHETYPES_AND_ADDONS.md).

## 1. Identitas produk

Smart Cashier bukan sekadar aplikasi pencatat pembayaran. Produk ini adalah
sistem operasional offline-first yang membantu usaha:

- melakukan transaksi dengan cepat;
- menjaga stok dan harga modal;
- membedakan omzet, modal, dan keuntungan yang aman digunakan;
- mempertahankan pelanggan melalui loyalty;
- mengendalikan aktivitas yang berbeda sesuai tipe usaha;
- meningkatkan kedalaman kontrol tanpa memaksa usaha kecil memakai proses rumit.

Motto produk:

> **Smart Cashier, Smart Stock & Customer Loyalty.**

Prinsip komunikasi modal:

> **Omzet bukan uang yang boleh dihabiskan.**

Prinsip offline-first:

> **Internet mati, bisnis tetap berjalan. Internet hidup, bisnis menjadi lebih
> pintar.**

## 2. Arsitektur merek dan website

| Properti | Tanggung jawab | Kedalaman pembahasan |
| --- | --- | --- |
| `auliasabril.com` | Portofolio dan kredibilitas profesional Aulia Sabril | Ringkas, berbentuk studi kasus |
| `playkitmediapustaka.com` | Induk perusahaan, katalog seluruh produk, dan kanal komersial | Katalog, solusi, dan penghubung produk |
| `kasir.playkitmediapustaka.com` | Website khusus keluarga produk Smart Cashier | Mendalam: fitur, versi, solusi, demo, harga, dokumentasi |

`auliasabril.com` tidak menjadi dokumentasi produk. Halaman portofolio cukup
menjelaskan masalah, peran, teknologi, hasil, dan beberapa visual, kemudian
mengarahkan pengunjung ke `kasir.playkitmediapustaka.com`.

Struktur konten Smart Cashier yang disepakati:

```text
kasir.playkitmediapustaka.com
├── fitur
├── versi
│   ├── micro
│   ├── retail
│   ├── advanced
│   └── network
├── retail
│   ├── warung
│   ├── minimarket
│   ├── fashion
│   ├── elektronik
│   └── apotek
├── restoran
│   ├── warung-makan
│   ├── cafe
│   ├── restoran
│   ├── fast-food
│   └── food-court
├── catering
│   ├── nasi-box
│   ├── tumpeng
│   ├── event
│   └── produksi-massal
├── jasa
├── rental
├── grosir
├── demo
├── harga
├── dokumentasi
└── dukungan
```

## 3. Tiga dimensi klasifikasi

Smart Cashier tidak boleh diklasifikasikan hanya berdasarkan harga paket.
Produk ditentukan oleh kombinasi:

```text
skala usaha × jenis usaha × aktivitas operasional
```

### 3.1 Skala usaha

| Kelas | Profil | Pengguna/perangkat | Fokus |
| --- | --- | --- | --- |
| Micro | Warung, kios, usaha rumahan | 1–2 pengguna, 1 perangkat | Transaksi, stok sederhana, dan perlindungan modal |
| Retail | Toko kecil dengan pegawai | 2–5 pengguna, 1–3 perangkat | Purchasing, supplier, utang, shift, audit |
| Advanced | Toko/restoran/catering menengah | 5–30 pengguna, multi-perangkat | Batch, station, SOP, approval, LAN |
| Network | Banyak cabang/lokasi | Banyak pengguna dan cabang | Sinkronisasi, kontrol pusat, transfer antar-lokasi |

### 3.2 Jenis usaha

| Vertikal | Contoh | Mesin operasional khusus |
| --- | --- | --- |
| Retail umum | Warung, minimarket, ATK, kosmetik | Barcode, inventory, purchasing |
| Fashion | Pakaian, sepatu | Matriks warna, ukuran, model |
| Barang bernilai tinggi | HP, elektronik, perhiasan | Serial, IMEI, garansi, audit unit |
| Expiry-sensitive | Apotek, kosmetik, pangan tertentu | Batch, kedaluwarsa, FEFO, recall |
| Material/multi-unit | Bangunan, kain, kabel, grosir | Dus–pcs, roll–meter, kg–gram |
| Restaurant | Warung makan, cafe, restoran | Menu, resep, antrean dapur, meja, waiter |
| Catering | Nasi box, tumpeng, event | Production batch, assembly, checklist, QC |
| Jasa | Laundry, salon, servis | Job order dan status pekerjaan |
| Hybrid | Bengkel, toko komputer | Produk, spare part, jasa, histori servis |
| Rental | Sewa alat/barang | Deposit, durasi, kondisi, pengembalian |

### 3.3 Aktivitas operasional

Aktivitas menentukan workflow, bukan sekadar nama layar. Retail memakai alur
`ambil → scan → bayar`; restoran memakai `pesan → produksi → sajikan`; catering
memakai `pesan → rencanakan → produksi massal → assembly → QC → kirim`.

## 4. Kelas produk komersial

| Versi | Target | Kedalaman operasi |
| --- | --- | --- |
| Smart Cashier Micro | Usaha mikro | POS, stok kuantitas, harga modal, capital protection dasar |
| Smart Cashier Retail | Toko kecil | Supplier, purchasing, utang, loyalty, shift, audit |
| Smart Cashier Advanced | Usaha menengah | Batch, expiry, lokasi, station, approval, LAN |
| Smart Cashier Network | Multi-cabang | Kontrol pusat, transfer, cloud sync opsional |

`—` dalam matriks paket berarti fitur disembunyikan dari pengalaman pengguna,
bukan dihapus dari fondasi arsitektur. Upgrade tidak boleh memaksa pengguna
mengganti database atau aplikasi.

Posisi aplikasi `postgetx` saat dokumen ini dibuat adalah:

> **Smart Cashier Retail dengan pengalaman awal sesederhana Micro Mode.**

## 5. Prinsip fondasi teknologi dan produk

1. **Offline-first** — operasi inti tidak bergantung pada internet.
2. **Progressive complexity** — fitur rumit hanya muncul saat mode diaktifkan.
3. **Capital protection** — modal, margin, reserve, dan dana aman dibedakan.
4. **Traceability proportional** — detail mengikuti nilai dan risiko barang.
5. **Immutable audit** — perubahan penting menambah event, bukan menghapus jejak.
6. **Atomic operation** — order, stok, loyalty, dan modal berhasil/gagal bersama.
7. **Role-based control** — hak akses mengikuti tanggung jawab.
8. **MVD simplicity** — default harus dapat dipahami usaha mikro.
9. **Upgrade without migration pain** — bisnis dapat naik kelas tanpa restart.
10. **Physical truth** — aplikasi tidak boleh mengklaim identitas yang tidak dapat
    dibuktikan pada barang fisik.
11. **Customer promise as data** — personalisasi dan kelengkapan yang dijanjikan
    menjadi data wajib, bukan catatan bebas yang mudah terlupa.

## 6. Retail traceability

Barcode pabrik mengidentifikasi SKU, bukan unit. Semua bungkus produk seperti
Indomie dapat memiliki barcode pabrik yang sama. Karena itu aplikasi mendukung
tiga mode:

| Mode | Identitas | Penggunaan |
| --- | --- | --- |
| Simple | Produk + jumlah | Produk murah dan cepat bergerak |
| Batch | Produk + purchase batch + expiry | Pangan, kosmetik, obat |
| Serial | Identitas unik setiap unit | HP, elektronik, barang bergaransi |

### 6.1 Simple Stock

Default untuk usaha mikro. Satu dus dapat diinput sebagai `1 dus × 40 pcs`.
Supplier, tanggal pembelian, harga modal, dan konversi unit tetap disimpan,
tetapi aplikasi tidak mengklaim dapat membedakan bungkus fisik yang identik.

### 6.2 Batch Tracking

Batch menyimpan purchase, supplier, tanggal masuk, expiry, harga modal,
penerima, jumlah awal, dan jumlah tersisa. Pengeluaran memakai FIFO/FEFO secara
logis. Batch berbeda tidak boleh dicampur dalam satu slot fisik tanpa divider,
tray, label warna, atau penanda lain.

Untuk toko menengah dapat digunakan status:

```text
LOCKED / JANGAN DIBUKA
ACTIVE / HABISKAN DAHULU
DEPLETED
```

Refill rak dapat memakai scan QR dus dan lokasi. Override FEFO harus mencatat
petugas, alasan, waktu, dan persetujuan supervisor. Fitur ini opsional dan tidak
boleh membebani warung kecil.

### 6.3 Serial Tracking

Unit fisik wajib memiliki identifier unik (serial pabrik atau label internal).
Tanpa label unik, aplikasi tidak dapat secara terpercaya menyatakan bungkus
mana yang rusak, hilang, atau terjual ketika semua barcode pabrik sama.

### 6.4 Stock event

Jejak minimum:

```text
Supplier → Purchase → Batch → Warehouse/Shelf → Sale/Return/Damage/Loss
```

Setiap event menyimpan siapa, kapan, lokasi asal, lokasi tujuan, jumlah/unit,
alasan, dan referensi dokumen.

## 7. Restaurant Operations

Restaurant POS adalah vertikal tersendiri, bukan Retail POS yang sekadar diberi
nama menu.

```text
Kasir menerima order
→ tiket produksi
→ kitchen station
→ quality check
→ ready
→ served/picked up/delivered
```

Status dasar:

```text
NEW → CONFIRMED → IN_PREPARATION → QUALITY_CHECK → READY
→ SERVED / PICKED_UP / HANDED_TO_COURIER → DELIVERED
```

Station dapat meliputi dapur panas, minuman, garnish, packing, dan QC. Kitchen
Display hanya menampilkan informasi produksi yang relevan, bukan informasi
keuangan internal.

Recipe/BOM dan fulfillment checklist tidak boleh disatukan:

- **Recipe/BOM** mengurangi bahan baku dan menghitung biaya.
- **Fulfillment checklist** memastikan semua komponen yang dijanjikan telah
  disajikan atau dimasukkan ke paket.

## 8. Catering Operations

Catering Standard dan Catering Pro adalah target penting: bisnis sudah memiliki
banyak order, menu, dan pegawai, tetapi masih bergantung pada WhatsApp, ingatan,
kertas, dan instruksi lisan.

Masalah yang diselesaikan:

- topping/pelengkap terlupa;
- jumlah komponen berlebih atau kurang;
- personalisasi salah ketik;
- produksi massal tidak terukur;
- tidak ada QC final;
- biaya kecil tidak dihitung;
- modal dan laba terlihat lebih besar dari kenyataan.

### 8.1 Empat lapisan produk catering

1. **Menu jual** — nama, harga, porsi, varian.
2. **Recipe/BOM** — bahan dan yield produksi.
3. **Assembly specification** — jumlah komponen yang harus ditata.
4. **Personalization specification** — nama, ucapan, tema, label, dan aset.

Produk seperti tumpeng/dimsum platter dapat berisi siomay, pangsit, telur,
sayur, garnish, jeruk, saus terpisah, tray, label, dan kartu ucapan. Kartu ucapan
adalah deliverable wajib dan bagian dari nilai emosional produk, bukan catatan
tambahan.

### 8.2 Workflow catering

```text
Permintaan pelanggan
→ quotation
→ spesifikasi menu dan personalisasi
→ DP
→ production order
→ kebutuhan bahan
→ produksi komponen
→ assembly
→ packing checklist
→ QC + foto bukti
→ dispatch
→ pelunasan
```

### 8.3 Production planning

Sistem menggabungkan kebutuhan lintas order dan membandingkan rencana dengan
aktual:

```text
Direncanakan: 195 siomay
Diproduksi:   200
Dipakai:      185
Rusak:          3
Sisa:          12
```

Buffer produksi harus terlihat sebagai buffer/waste, bukan keuntungan.

### 8.4 Checklist berbasis jumlah

Checklist bukan boolean semata:

```text
Air mineral: 18/20  BELUM LENGKAP
Kerupuk:      20/20 LENGKAP
Sambal:       20/20 LENGKAP
Kartu ucapan:  0/1  BELUM LENGKAP
```

Order tidak boleh menjadi `READY` ketika komponen wajib belum lengkap. Override
harus menyimpan alasan dan supervisor.

### 8.5 Station dan audit

| Station | Tanggung jawab |
| --- | --- |
| Preparation | Menimbang dan menyiapkan bahan |
| Production | Memasak komponen |
| Garnish | Dekorasi dan pelengkap visual |
| Personalization | Kartu dan label |
| Assembly | Menata produk |
| Packing | Pelengkap dan kemasan |
| QC | Pemeriksaan akhir dan foto |
| Dispatch | Penyerahan ke kurir/pelanggan |

Audit dapat menjawab siapa menerima order, memasak, packing, melakukan QC, dan
menyerahkan produk. Tujuannya memperbaiki SOP, bukan sekadar menghukum pegawai.

## 9. Customer Personalization Studio

Untuk mengurangi salah ketik, pelanggan harus dapat mengisi personalisasi
sendiri melalui link/QR bertoken.

```text
Order dibuat
→ link personalisasi
→ pelanggan mengisi
→ preview
→ pelanggan menyetujui
→ versi dikunci
→ dicetak
→ dipasang
→ QC verified
```

Status:

```text
WAITING_CUSTOMER → DRAFT → PREVIEWED → CUSTOMER_APPROVED
→ LOCKED → PRINTED → ATTACHED → QC_VERIFIED
```

Data mencakup nama penerima, judul acara, isi ucapan, pengirim, tema, warna,
orientasi, gambar/logo, dan catatan. Pelanggan wajib menyetujui ejaan dan
preview. Revisi setelah lock membuat versi baru; perubahan setelah cetak dapat
menimbulkan biaya reprint.

Link hanya boleh membuka personalisasi order terkait. Harga modal, margin,
supplier, data pegawai, dan order lain tidak boleh terlihat. Token harus acak,
memiliki masa berlaku, dapat dicabut, dan menjadi read-only setelah approval.

Modul ini membutuhkan internet untuk akses pelanggan, tetapi operasi catering
tetap offline-first. Fallback: pelanggan mengisi pada tablet toko atau jaringan
lokal. Salinan final selalu disimpan lokal setelah sinkronisasi.

Personalization Studio dapat digunakan lintas produk: tumpeng, nasi box,
hampers, kue, buket, parcel, merchandise, engraving, dan custom printing.

## 10. Costing dan Capital Protection

Harga modal catering tidak boleh hanya menghitung bahan utama. Standard cost
mencakup:

- bahan utama;
- bumbu dan saus;
- garnish;
- kemasan;
- kartu/label/personalisasi;
- consumable;
- gas dan listrik;
- tenaga kerja;
- delivery;
- waste allowance;
- overhead dan penyusutan.

Sistem membandingkan standard cost dengan actual cost dan menjelaskan selisih,
misalnya sayur berlebih, saus berlebih, cetak ulang kartu, atau kurir tambahan.

Capital Protection Engine yang sudah dibangun menjadi fondasi lintas vertikal:

- trusted cost snapshot;
- protected restock capital;
- operational reserve;
- owner withdrawal;
- protected-capital leakage;
- sale/refund ledger atomic;
- health summary dan audit history.

## 11. Batas offline dan online

Tetap offline:

- transaksi;
- stok;
- purchasing;
- kitchen/production queue melalui LAN;
- checklist;
- costing;
- QC;
- ledger modal;
- backup lokal.

Opsional online:

- personalization link pelanggan;
- cloud backup;
- monitoring jarak jauh;
- multi-cabang;
- supplier promo inbox;
- notifikasi eksternal.

Kegagalan internet tidak boleh menghentikan transaksi dan produksi lokal.

## 12. Peta domain jangka panjang

```text
Smart Cashier Core
├── Transaction & Payment
├── Customer & Loyalty
├── Capital Protection
├── User, Role & Audit
├── Backup & Restore
│
├── Retail Operations
│   ├── Inventory
│   ├── Supplier & Purchasing
│   ├── Batch / Expiry / FEFO
│   └── Serial Tracking
│
├── Restaurant Operations
│   ├── Menu & Recipe
│   ├── Table & Waiter
│   ├── Kitchen Queue / KDS
│   └── Fulfillment
│
├── Catering Operations
│   ├── Quotation & DP
│   ├── Production Planning
│   ├── Assembly & Packing
│   ├── QC & Dispatch
│   └── Personalization Studio
│
└── Network Operations
    ├── LAN
    ├── Multi-branch
    ├── Transfer
    └── Optional Cloud Sync
```

## 13. Keputusan yang dikunci sebelum Supplier & Purchasing

1. Supplier/Purchasing dibangun untuk Retail terlebih dahulu, tetapi modelnya
   harus dapat mendukung bahan baku Restaurant/Catering.
2. UI awal memakai Simple Stock; batch dan serial bersifat opsional.
3. Purchase menyimpan supplier, tanggal, unit, conversion, cost, pembayaran,
   outstanding debt, due date, reminder, penerima, dan audit.
4. Pembelian yang belum lunas wajib memiliki jatuh tempo.
5. Stock receipt, cost basis, supplier debt, dan capital impact harus atomic.
6. Purchase batch menjadi fondasi expiry/FEFO tanpa memaksa tracking per unit.
7. Tidak boleh membuat Kitchen/Catering sebagai kumpulan flag acak di Retail;
   masing-masing adalah vertical operations module di atas Smart Cashier Core.
8. Personalization Studio bukan bagian Supplier MVP, tetapi domain dan kontrak
   masa depannya harus dijaga.

## 14. Urutan roadmap

### Selesai

- canonical offline-first architecture;
- Customer Loyalty, redemption, configuration, tiers, receipt snapshot;
- Capital Protection Foundation dan Operations;
- architecture guard, BDD enforcement, full tests, HTML coverage.

### Berikutnya

1. Supplier master.
2. Purchase dan stock receipt.
3. Tunai, utang, dan pembayaran sebagian.
4. Supplier debt ledger.
5. Due date dan reminder lokal.
6. Multi-unit conversion.
7. Batch/expiry opsional.
8. Waste, damage, loss, dan supplier return.

### Vertikal lanjutan

- Restaurant Operations;
- Catering Operations;
- Customer Personalization Studio;
- Advanced retail traceability;
- LAN dan Network Operations.

## 15. Checklist keputusan fitur baru

Sebelum mengimplementasikan fitur, jawab:

1. Masuk Smart Cashier Core atau vertical operations?
2. Ditujukan untuk Micro, Retail, Advanced, atau Network?
3. Default sederhana atau opt-in?
4. Dapat bekerja tanpa internet?
5. Apa bukti fisik/data yang membuat tracking dapat dipercaya?
6. Apakah perubahan harus atomic?
7. Siapa yang boleh melakukan dan siapa yang mengaudit?
8. Bagaimana dampaknya terhadap stok, utang, dan capital protection?
9. Apa skenario Given–When–Then yang melindungi perilaku?
10. Apakah fitur membuat usaha kecil lebih rumit tanpa manfaat sebanding?

Dokumen ini harus diperbarui ketika keputusan produk besar berubah. Detail
implementasi, nama class, dan struktur source tetap mengikuti `ARCHITECTURE.md`,
`AGENTS.md`, serta pengujian arsitektur repository.
