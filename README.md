# 🛍️ Retail Management System (Flutter + GetX)

A mobile app built using Flutter and GetX for managing catering business operations. The system supports multiple user roles (Admin, Staff, Courier, Customer), POS operations, stock management, order tracking, and more.

---

# 🚧 Upcoming Features

Daftar fitur yang direncanakan untuk pengembangan selanjutnya dalam aplikasi Retail Management System.

---

## 📦 Order Tracking System
- Melacak status pesanan secara real-time
- Tampilan timeline proses pemesanan (diproses → disiapkan → dikirim → selesai)
- Integrasi QR/barcode untuk kurir

---

## 🛒 Pre-Order Functionality
- Pengguna dapat memesan menu sebelum hari H
- Konfirmasi otomatis jika sudah mendekati hari pengiriman
- Manajemen kapasitas per hari

---

## 🎁 Loyalty Program
- Sistem poin untuk pelanggan berdasarkan total transaksi
- Penukaran poin dengan reward tertentu
- Statistik loyalitas pengguna

---

## 🔔 Low Stock Notification
- Notifikasi otomatis saat stok hampir habis
- Threshold dapat diatur oleh admin
- Email/notifikasi lokal untuk staff

---

## 🧾 Printable Checklist for Staff
- Cetak checklist kebutuhan pesanan (bukan hanya nota/invoice)
- Format ringkas untuk membantu proses persiapan

---

## 📊 Dashboard Analytics (Planned)
- Statistik penjualan per hari/minggu/bulan
- Data pelanggan aktif
- Grafik performa produk terlaris

---

## 📲 Push Notifications
- Firebase Cloud Messaging (FCM)
- Update status pesanan dan promo langsung ke pelanggan

---

## 🌐 Multi-language Support
- Dukungan multibahasa (Indonesia, Inggris)
- Pilihan bahasa di pengaturan aplikasi

---

_Updated: April 2025_


## 📁 Project Structure
lib/
│── main.dart
│
├── routes/
│   ├── app_pages.dart          # Definisi rute dan page GetX
│   ├── app_routes.dart         # Konstanta rute

├── bindings/
│   ├── initial_binding.dart    # Binding awal
│   ├── auth_binding.dart       # Binding auth (jika dipisah per modul)
│   ├── dashboard_binding.dart  # Binding dashboard (opsional)

├── modules/
│   ├── auth/
│   │   ├── controllers/
│   │   │   └── auth_controller.dart
│   │   ├── views/
│   │   │   ├── login_view.dart
│   │   │   └── register_view.dart
│   │   └── widgets/
│   │       └── custom_auth_field.dart (opsional UI reuse)
│
│   ├── dashboard/
│   │   ├── controllers/
│   │   │   └── dashboard_controller.dart (jika ada logic)
│   │   ├── views/
│   │   │   └── dashboard_view.dart
│   │   └── widgets/
│   │       └── dashboard_card.dart (opsional UI komponen)
│
│   ├── pos/
│   │   ├── controllers/
│   │   └── views/
│   │   └── widgets/
│
│   ├── stock/
│   │   ├── controllers/
│   │   └── views/
│   │   └── widgets/
│
│   ├── orders/
│   │   ├── controllers/
│   │   └── views/
│   │   └── widgets/
│
│   ├── tracking/               # Modul Pelacakan Pesanan (upcoming)
│   │   ├── controllers/
│   │   └── views/
│   │   └── widgets/
│
│   ├── preorder/               # Modul Pre-Order (upcoming)
│   │   ├── controllers/
│   │   └── views/
│   │   └── widgets/
│
│   ├── loyalty/                # Modul Loyalty Program (upcoming)
│   │   ├── controllers/
│   │   └── views/
│   │   └── widgets/

├── services/
│   ├── firebase_service.dart     # Integrasi Firebase
│   ├── user_role_service.dart    # Cek dan simpan role user (admin, kurir, dst)

├── models/
│   ├── user_model.dart           # Struktur data pengguna
│   ├── order_model.dart          # Struktur data pesanan
│   └── etc...

├── utils/
│   ├── constants.dart            # Warna, font, dll.
│   ├── helpers.dart              # Fungsi-fungsi pembantu umum

├── themes/
│   ├── app_theme.dart            # Tema umum aplikasi

├── widgets/
│   ├── custom_button.dart        # Widget reusable global
│   └── app_loader.dart           # Widget loading



Mahasiswa Aktif
Yuni fajriani
Muhammad Irsyad
Aidil
Rajas Wijaya

Iriana
Selvitasari


Iksan
Gideon
Amalia
nurmala
fransiskus
al muqarram
fahmi
sri adelita
mirnawati

Tatia
Marsa
Adhitya
Awal
Suci
Syarbina
Ahmad Fauzi