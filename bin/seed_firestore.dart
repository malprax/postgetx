import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:postgetx/firebase_options.dart';

Future<void> main() async {
  // Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firestore = FirebaseFirestore.instance;

  // Seeder Kategori
  final categories = [
    {"name": "Meals", "icon": "🍽️", "id": "meals"},
    {"name": "Soups", "icon": "🍲", "id": "soups"},
    {"name": "Beverages", "icon": "🧃", "id": "beverages"},
    {"name": "Appetizer", "icon": "🥗", "id": "appetizer"},
    {"name": "Dessert", "icon": "🍰", "id": "dessert"},
  ];

  for (final cat in categories) {
    await firestore.collection("menu_categories").doc(cat["id"]).set({
      "name": cat["name"],
      "icon": cat["icon"],
    });
  }

  // Seeder Menu
  final items = [
    {
      "name": "Cheese Burger",
      "category": "meals",
      "imageUrl": "https://source.unsplash.com/300x200/?burger",
      "variants": [
        {"size": "Regular", "price": 25000},
        {"size": "Large", "price": 30000}
      ]
    },
    {
      "name": "Orange Juice",
      "category": "beverages",
      "imageUrl": "https://source.unsplash.com/300x200/?juice",
      "variants": [
        {"size": "Medium", "price": 8000},
        {"size": "Large", "price": 12000}
      ]
    },
    {
      "name": "Curry Soup",
      "category": "soups",
      "imageUrl": "https://source.unsplash.com/300x200/?soup",
      "variants": [
        {"size": "Bowl", "price": 20000}
      ]
    },
    {
      "name": "Fruit Salad",
      "category": "appetizer",
      "imageUrl": "https://source.unsplash.com/300x200/?salad",
      "variants": [
        {"size": "Box", "price": 15000}
      ]
    },
    {
      "name": "Strawberries Ice Cream",
      "category": "dessert",
      "imageUrl": "https://source.unsplash.com/300x200/?icecream",
      "variants": [
        {"size": "Cup", "price": 10000}
      ]
    },
  ];

  for (final item in items) {
    await firestore.collection("menu_items").add(item);
  }

  print("Seeder berhasil dijalankan!");
}
