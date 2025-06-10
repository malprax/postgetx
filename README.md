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
- **lib/**
  - **main.dart**
  - **routes/**
    - *app_pages.dart*  <!-- Definisi rute dan page GetX -->
    - *app_routes.dart* <!-- Konstanta rute -->
  - **bindings/**
    - *initial_binding.dart*    <!-- Binding awal -->
    - *auth_binding.dart*       <!-- Binding auth (jika dipisah per modul) -->
    - *dashboard_binding.dart*  <!-- Binding dashboard (opsional) -->
  - **modules/**
    - **auth/**
      - **controllers/**
        - *auth_controller.dart*
      - **views/**
        - *login_view.dart*
        - *register_view.dart*
      - **widgets/**
        - *custom_auth_field.dart* <!-- (opsional UI reuse) -->
    - **dashboard/**
      - **controllers/**
        - *dashboard_controller.dart* <!-- (jika ada logic) -->
      - **views/**
        - *dashboard_view.dart*
      - **widgets/**
        - *dashboard_card.dart* <!-- (opsional UI komponen) -->
    - **pos/**
      - **controllers/**
      - **views/**
      - **widgets/**
    - **stock/**
      - **controllers/**
      - **views/**
      - **widgets/**
    - **orders/**
      - **controllers/**
      - **views/**
      - **widgets/**
    - **tracking/** <!-- Modul Pelacakan Pesanan (upcoming) -->
      - **controllers/**
      - **views/**
      - **widgets/**
    - **preorder/** <!-- Modul Pre-Order (upcoming) -->
      - **controllers/**
      - **views/**
      - **widgets/**
    - **loyalty/** <!-- Modul Loyalty Program (upcoming) -->
      - **controllers/**
      - **views/**
      - **widgets/**
  - **services/**
    - *firebase_service.dart*     <!-- Integrasi Firebase -->
    - *user_role_service.dart*    <!-- Cek dan simpan role user (admin, kurir, dst) -->
  - **models/**
    - *user_model.dart*           <!-- Struktur data pengguna -->
    - *order_model.dart*          <!-- Struktur data pesanan -->
    - *etc...*
  - **utils/**
    - *constants.dart*            <!-- Warna, font, dll. -->
    - *helpers.dart*              <!-- Fungsi-fungsi pembantu umum -->
  - **themes/**
    - *app_theme.dart*            <!-- Tema umum aplikasi -->
  - **widgets/**
    - *custom_button.dart*        <!-- Widget reusable global -->
    - *app_loader.dart*           <!-- Widget loading -->




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


awal
lili
fidia
marsa
nur adelia
agustina

📁 Project Structure

lib/
├── main.dart
├── routes/
│   ├── app_pages.dart        # Definisi rute dan page GetX
│   └── app_routes.dart       # Konstanta nama rute
├── bindings/
│   ├── initial_binding.dart  # Binding awal aplikasi
│   ├── auth_binding.dart     # Binding untuk modul auth
│   └── dashboard_binding.dart# Binding dashboard (opsional)
├── modules/
│   ├── auth/
│   │   ├── controllers/
│   │   │   └── auth_controller.dart
│   │   ├── views/
│   │   │   ├── login_view.dart
│   │   │   └── register_view.dart
│   │   └── widgets/
│   │       └── custom_auth_field.dart
│   ├── dashboard/
│   │   ├── controllers/
│   │   │   └── dashboard_controller.dart
│   │   ├── views/
│   │   │   └── dashboard_view.dart
│   │   └── widgets/
│   │       └── dashboard_card.dart
│   ├── pos/
│   │   ├── controllers/
│   │   ├── views/
│   │   └── widgets/
│   ├── stock/
│   │   ├── controllers/
│   │   ├── views/
│   │   └── widgets/
│   ├── orders/
│   │   ├── controllers/
│   │   ├── views/
│   │   └── widgets/
│   ├── tracking/              # Modul pelacakan pesanan (upcoming)
│   │   ├── controllers/
│   │   ├── views/
│   │   └── widgets/
│   ├── preorder/              # Modul pre-order (upcoming)
│   │   ├── controllers/
│   │   ├── views/
│   │   └── widgets/
│   └── loyalty/               # Modul loyalty program (upcoming)
│       ├── controllers/
│       ├── views/
│       └── widgets/
├── services/
│   ├── firebase_service.dart     # Integrasi Firebase
│   └── user_role_service.dart    # Cek dan simpan role user
├── models/
│   ├── user_model.dart           # Struktur data pengguna
│   └── order_model.dart          # Struktur data pesanan
├── utils/
│   ├── constants.dart            # Konstanta warna, ukuran font, dsb
│   └── helpers.dart              # Fungsi-fungsi pembantu
├── themes/
│   └── app_theme.dart            # Tema umum aplikasi
└── widgets/
    ├── custom_button.dart        # Komponen global reusable
    └── app_loader.dart           # Widget loader global


// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'routes/app_pages.dart';
import 'bindings/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Retail Management System',
      initialBinding: InitialBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}

// lib/bindings/initial_binding.dart
import 'package:get/get.dart';
import '../modules/auth/controllers/auth_controller.dart';
import '../modules/dashboard/controllers/dashboard_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(DashboardController());
  }
}

// lib/routes/app_routes.dart
abstract class Routes {
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const DASHBOARD = '/dashboard';
  static const INITIAL = LOGIN;
}


// lib/routes/app_pages.dart
import 'package:get/get.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.INITIAL;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginView(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => RegisterView(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => DashboardView(),
    ),
  ];
}


// lib/modules/auth/views/login_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class LoginView extends StatelessWidget {
  final authC = Get.find<AuthController>();
  final emailC = TextEditingController();
  final passC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailC,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passC,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            Obx(() => authC.isLoading.value
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => authC.login(emailC.text, passC.text),
                    child: Text('Login'),
                  )),
            TextButton(
              onPressed: () => Get.toNamed(Routes.REGISTER),
              child: Text('Belum punya akun? Daftar'),
            ),
            const Divider(height: 32),
            ElevatedButton.icon(
              onPressed: () => authC.loginWithGoogle(),
              icon: Icon(Icons.g_mobiledata),
              label: Text('Login dengan Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// lib/modules/auth/views/register_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class RegisterView extends StatelessWidget {
  final authC = Get.find<AuthController>();
  final emailC = TextEditingController();
  final passC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailC,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passC,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            Obx(() => authC.isLoading.value
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => authC.register(emailC.text, passC.text),
                    child: Text('Daftar'),
                  )),
            TextButton(
              onPressed: () => Get.offNamed(Routes.LOGIN),
              child: Text('Sudah punya akun? Login'),
            ),
          ],
        ),
      ),
    );
  }
}


// lib/modules/dashboard/views/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class DashboardView extends StatelessWidget {
  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => authC.logout(),
          )
        ],
      ),
      body: Center(
        child: Text('Selamat datang di Retail Management System!'),
      ),
    );
  }
}

// lib/modules/auth/controllers/auth_controller.dart
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  var isLoading = false.obs;

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.offAllNamed(Routes.DASHBOARD);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Login Gagal', e.message ?? 'Terjadi kesalahan');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      Get.offAllNamed(Routes.DASHBOARD);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Registrasi Gagal', e.message ?? 'Terjadi kesalahan');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return; // user cancelled
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      Get.offAllNamed(Routes.DASHBOARD);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Login Google Gagal', e.message ?? 'Terjadi kesalahan');
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
}

// lib/modules/dashboard/controllers/dashboard_controller.dart
import 'package:get/get.dart';

class DashboardController extends GetxController {
  var title = 'Dashboard'.obs;

  void updateTitle(String newTitle) {
    title.value = newTitle;
  }
}

// lib/modules/pos/controllers/pos_controller.dart
import 'package:get/get.dart';

class PosController extends GetxController {
  var itemCount = 0.obs;
  var totalPrice = 0.0.obs;

  void addItem(int qty, double price) {
    itemCount += qty;
    totalPrice += (qty * price);
  }

  void reset() {
    itemCount.value = 0;
    totalPrice.value = 0.0;
  }
}


// lib/modules/pos/views/pos_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pos_controller.dart';

class PosView extends StatelessWidget {
  final posC = Get.put(PosController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Point of Sale')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Text('Total Item: ${posC.itemCount.value}')),
            Obx(() => Text('Total Harga: Rp ${posC.totalPrice.value.toStringAsFixed(2)}')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => posC.addItem(1, 25000),
              child: Text('Tambah Item (Rp 25.000)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => posC.reset(),
              child: Text('Reset Transaksi'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/modules/stock/controllers/stock_controller.dart
import 'package:get/get.dart';

class StockController extends GetxController {
  var stockList = <Map<String, dynamic>>[].obs;

  void addStock(String name, int quantity) {
    stockList.add({'name': name, 'qty': quantity});
  }

  void clearStock() {
    stockList.clear();
  }
}

// lib/modules/stock/views/stock_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/stock_controller.dart';

class StockView extends StatelessWidget {
  final stockC = Get.put(StockController());
  final nameC = TextEditingController();
  final qtyC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manajemen Stok')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameC,
              decoration: InputDecoration(labelText: 'Nama Barang'),
            ),
            TextField(
              controller: qtyC,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Jumlah'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final name = nameC.text;
                final qty = int.tryParse(qtyC.text) ?? 0;
                if (name.isNotEmpty && qty > 0) {
                  stockC.addStock(name, qty);
                  nameC.clear();
                  qtyC.clear();
                }
              },
              child: Text('Tambah ke Stok'),
            ),
            const Divider(height: 20),
            Obx(() => Expanded(
                  child: ListView.builder(
                    itemCount: stockC.stockList.length,
                    itemBuilder: (context, index) {
                      final item = stockC.stockList[index];
                      return ListTile(
                        title: Text(item['name']),
                        trailing: Text('Qty: ${item['qty']}'),
                      );
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// lib/modules/orders/views/order_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';

class OrderView extends StatelessWidget {
  final orderC = Get.put(OrderController());
  final customerC = TextEditingController();
  final itemC = TextEditingController();
  final qtyC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manajemen Pesanan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: customerC,
              decoration: InputDecoration(labelText: 'Nama Pelanggan'),
            ),
            TextField(
              controller: itemC,
              decoration: InputDecoration(labelText: 'Nama Item'),
            ),
            TextField(
              controller: qtyC,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Jumlah'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final customer = customerC.text;
                final item = itemC.text;
                final qty = int.tryParse(qtyC.text) ?? 0;
                if (customer.isNotEmpty && item.isNotEmpty && qty > 0) {
                  orderC.addOrder(customer, item, qty);
                  customerC.clear();
                  itemC.clear();
                  qtyC.clear();
                }
              },
              child: Text('Tambah Pesanan'),
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => orderC.setSearchQuery(value),
                    decoration: InputDecoration(
                      hintText: 'Cari pelanggan atau item...'
                    ),
                  ),
                ),
                SizedBox(width: 8),
                DropdownButton<String>(
                  value: orderC.selectedStatus.value,
                  onChanged: (val) {
                    if (val != null) orderC.setSelectedStatus(val);
                  },
                  items: ['semua', 'diproses', 'dikirim', 'selesai']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: orderC.filteredList.length,
                    itemBuilder: (context, index) {
                      final order = orderC.filteredList[index];
                      return ListTile(
                        title: Text('${order['customer']} - ${order['item']}'),
                        subtitle: Text('Jumlah: ${order['quantity']}'),
                        trailing: DropdownButton<String>(
                          value: order['status'],
                          onChanged: (val) {
                            if (val != null) {
                              orderC.updateStatus(index, val);
                            }
                          },
                          items: ['diproses', 'dikirim', 'selesai']
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                        ),
                      );
                    },
                  )),
            )
          ],
        ),
      ),
    );
  }
}


// lib/modules/orders/controllers/order_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderController extends GetxController {
  var orderList = <Map<String, dynamic>>[].obs;
  var filteredList = <Map<String, dynamic>>[].obs;
  var searchQuery = ''.obs;
  var selectedStatus = 'semua'.obs;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
    debounce(searchQuery, (_) => applyFilters(), time: Duration(milliseconds: 300));
    ever(selectedStatus, (_) => applyFilters());
  }

  void fetchOrders() async {
    final snapshot = await firestore.collection('orders').get();
    orderList.value = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    applyFilters();
  }

  void addOrder(String customer, String item, int quantity) async {
    final order = {
      'customer': customer,
      'item': item,
      'quantity': quantity,
      'status': 'diproses',
      'timestamp': FieldValue.serverTimestamp(),
    };
    await firestore.collection('orders').add(order);
    fetchOrders();
  }

  void updateStatus(int index, String status) async {
    final docSnapshot = await firestore
        .collection('orders')
        .where('customer', isEqualTo: orderList[index]['customer'])
        .where('item', isEqualTo: orderList[index]['item'])
        .limit(1)
        .get();

    if (docSnapshot.docs.isNotEmpty) {
      final docId = docSnapshot.docs.first.id;
      await firestore.collection('orders').doc(docId).update({'status': status});
      fetchOrders();
    }
  }

  void applyFilters() {
    filteredList.value = orderList.where((order) {
      final matchesSearch = order['customer'].toString().toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                            order['item'].toString().toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesStatus = selectedStatus.value == 'semua' || order['status'] == selectedStatus.value;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setSelectedStatus(String status) {
    selectedStatus.value = status;
  }
}

// lib/modules/tracking/controllers/tracking_controller.dart
import 'package:get/get.dart';

class TrackingController extends GetxController {
  var trackingList = <Map<String, dynamic>>[].obs;

  void updateTracking(String orderId, String status) {
    final index = trackingList.indexWhere((e) => e['orderId'] == orderId);
    if (index != -1) {
      trackingList[index]['status'] = status;
      trackingList.refresh();
    }
  }

  void addTracking(String orderId, String status) {
    trackingList.add({'orderId': orderId, 'status': status});
  }
}

// lib/modules/tracking/views/tracking_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tracking_controller.dart';

class TrackingView extends StatelessWidget {
  final trackingC = Get.put(TrackingController());
  final orderIdC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pelacakan Pesanan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: orderIdC,
              decoration: InputDecoration(labelText: 'ID Pesanan'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final id = orderIdC.text;
                if (id.isNotEmpty) {
                  trackingC.addTracking(id, 'dalam perjalanan');
                  orderIdC.clear();
                }
              },
              child: Text('Tambahkan Pelacakan'),
            ),
            Divider(),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: trackingC.trackingList.length,
                    itemBuilder: (context, index) {
                      final track = trackingC.trackingList[index];
                      return ListTile(
                        title: Text('Pesanan: ${track['orderId']}'),
                        subtitle: Text('Status: ${track['status']}'),
                        trailing: DropdownButton<String>(
                          value: track['status'],
                          onChanged: (val) {
                            if (val != null) {
                              trackingC.updateTracking(track['orderId'], val);
                            }
                          },
                          items: [
                            'dalam perjalanan',
                            'sudah sampai',
                            'gagal kirim'
                          ]
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                        ),
                      );
                    },
                  )),
            )
          ],
        ),
      ),
    );
  }
}

// lib/modules/preorder/views/preorder_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/preorder_controller.dart';

class PreorderView extends StatelessWidget {
  final preorderC = Get.put(PreorderController());
  final customerC = TextEditingController();
  final itemC = TextEditingController();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pre-Order Barang')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: customerC,
              decoration: InputDecoration(labelText: 'Nama Pelanggan'),
            ),
            TextField(
              controller: itemC,
              decoration: InputDecoration(labelText: 'Nama Item'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  selectedDate = date;
                }
              },
              child: Text('Pilih Tanggal Pengambilan'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (customerC.text.isNotEmpty && itemC.text.isNotEmpty && selectedDate != null) {
                  preorderC.addPreorder(customerC.text, itemC.text, selectedDate!);
                  customerC.clear();
                  itemC.clear();
                  selectedDate = null;
                }
              },
              child: Text('Simpan Pre-Order'),
            ),
            const Divider(),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: preorderC.preorderList.length,
                    itemBuilder: (context, index) {
                      final order = preorderC.preorderList[index];
                      return ListTile(
                        title: Text('${order['customer']} - ${order['item']}'),
                        subtitle: Text('Ambil: ${order['pickupDate'].toString().split(' ')[0]}'),
                        trailing: DropdownButton<String>(
                          value: order['status'],
                          onChanged: (val) {
                            if (val != null) preorderC.updateStatus(index, val);
                          },
                          items: ['dipesan', 'siap diambil', 'selesai']
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                        ),
                      );
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/modules/loyalty/controllers/loyalty_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoyaltyController extends GetxController {
  var customerPoints = <String, int>{}.obs;
  final firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchPoints();
  }

  void fetchPoints() async {
    final snapshot = await firestore.collection('loyalty').get();
    for (var doc in snapshot.docs) {
      customerPoints[doc.id] = doc['points'];
    }
  }

  void addPoints(String customer, int points) async {
    final existing = customerPoints[customer] ?? 0;
    final newTotal = existing + points;
    customerPoints[customer] = newTotal;
    await firestore
        .collection('loyalty')
        .doc(customer)
        .set({'points': newTotal});
  }

  void resetPoints(String customer) async {
    customerPoints[customer] = 0;
    await firestore.collection('loyalty').doc(customer).set({'points': 0});
  }
}


// lib/modules/loyalty/views/loyalty_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/loyalty_controller.dart';

class LoyaltyView extends StatelessWidget {
  final loyaltyC = Get.put(LoyaltyController());
  final customerC = TextEditingController();
  final pointsC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Loyalty Program')), 
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: customerC,
              decoration: InputDecoration(labelText: 'Nama Pelanggan'),
            ),
            TextField(
              controller: pointsC,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Tambahkan Poin'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final name = customerC.text;
                final pts = int.tryParse(pointsC.text) ?? 0;
                if (name.isNotEmpty && pts > 0) {
                  loyaltyC.addPoints(name, pts);
                  customerC.clear();
                  pointsC.clear();
                }
              },
              child: Text('Tambah Poin'),
            ),
            const Divider(),
            Expanded(
              child: Obx(() => ListView(
                    children: loyaltyC.customerPoints.entries.map((entry) {
                      return ListTile(
                        title: Text(entry.key),
                        subtitle: Text('Poin: ${entry.value}'),
                        trailing: IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () => loyaltyC.resetPoints(entry.key),
                        ),
                      );
                    }).toList(),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}







