// // lib/modules/pos/views/pos_dashboard.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class POSDashboard extends StatelessWidget {
//   final List<Map<String, dynamic>> products = [
//     {'name': 'Ayam Rempah', 'price': 25000},
//     {'name': 'Ikan Bakar', 'price': 30000},
//     {'name': 'Nasi Kuning', 'price': 15000},
//     {'name': 'Lalapan', 'price': 10000},
//     {'name': 'Es Teh', 'price': 5000},
//   ];

//   final cart = <Map<String, dynamic>>[].obs;
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;

//   void addToCart(Map<String, dynamic> product) {
//     final index = cart.indexWhere((e) => e['name'] == product['name']);
//     if (index == -1) {
//       cart.add({'name': product['name'], 'price': product['price'], 'qty': 1});
//     } else {
//       cart[index]['qty'] += 1;
//       cart.refresh();
//     }
//   }

//   void clearCart() {
//     cart.clear();
//   }

//   int getTotal() =>
//       cart.fold(0, (sum, item) => sum + (item['price'] * item['qty']));

//   void processTransaction() async {
//     if (cart.isEmpty) return;

//     final transaction = {
//       'timestamp': FieldValue.serverTimestamp(),
//       'total': getTotal(),
//       'items': cart
//           .map((e) => {
//                 'name': e['name'],
//                 'price': e['price'],
//                 'qty': e['qty'],
//                 'subtotal': e['price'] * e['qty']
//               })
//           .toList(),
//     };

//     await firestore.collection('transactions').add(transaction);
//     Get.snackbar('Transaksi', 'Pembayaran berhasil disimpan');
//     clearCart();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Point of Sales'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.delete),
//             onPressed: clearCart,
//           )
//         ],
//       ),
//       body: Row(
//         children: [
//           Expanded(
//             flex: 2,
//             child: GridView.builder(
//               padding: const EdgeInsets.all(12),
//               itemCount: products.length,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//                 childAspectRatio: 1.4,
//               ),
//               itemBuilder: (context, index) {
//                 final item = products[index];
//                 return GestureDetector(
//                   onTap: () => addToCart(item),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.orange.shade100,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: EdgeInsets.all(12),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(item['name'],
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.bold)),
//                         SizedBox(height: 8),
//                         Text('Rp ${item['price']}'),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Container(
//               padding: EdgeInsets.all(12),
//               color: Colors.grey.shade100,
//               child: Obx(() => Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Keranjang',
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold)),
//                       Divider(),
//                       Expanded(
//                         child: ListView(
//                           children: cart
//                               .map((e) => ListTile(
//                                     title: Text(e['name']),
//                                     subtitle: Text('Qty: ${e['qty']}'),
//                                     trailing:
//                                         Text('Rp ${e['price'] * e['qty']}'),
//                                   ))
//                               .toList(),
//                         ),
//                       ),
//                       Divider(),
//                       Text('Total: Rp ${getTotal()}',
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                       SizedBox(height: 10),
//                       ElevatedButton(
//                         onPressed: processTransaction,
//                         child: Center(child: Text('Bayar')),
//                       )
//                     ],
//                   )),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
