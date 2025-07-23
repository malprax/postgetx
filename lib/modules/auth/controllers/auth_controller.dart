import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:postgetx/models/user_model.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  Rxn<User> firebaseUser = Rxn<User>();
  final Rxn<UserModel> currentUserModel = Rxn<UserModel>();

  @override
  void onInit() {
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _handleUserChanged);
    super.onInit();
  }

  void _handleUserChanged(User? user) async {
    if (user != null) {
      print("User logged in: ${user.uid}");
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        currentUserModel.value = UserModel.fromMap(doc.id, doc.data()!);
      }
    } else {
      print("User is null (logged out)");
      currentUserModel.value = null;
    }
  }

  Future<void> fetchUserModel(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        currentUserModel.value = UserModel.fromMap(doc.id, doc.data()!);
        print("UserModel loaded for: ${doc.id}");
      } else {
        print("No user data found for UID: $uid");
      }
    } catch (e) {
      print("Error fetching user model: $e");
      Get.snackbar('Error', 'Failed to fetch user data');
    }
  }

  Future<void> register({required String role}) async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      Get.snackbar('Error', 'All fields are required');
      return;
    }

    try {
      print("[Register] Creating user for $email");
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("[Register] Firebase Auth success. Saving user data to Firestore");

      await _firestore.collection('users').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'photoUrl': '',
      });
      print("[Register] User registered and data saved.");

      Get.offAllNamed('/dashboard');
    } catch (e) {
      print("[Register] Error: $e");
      Get.snackbar('Register Failed', e.toString());
    }
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Email and password are required');
      return;
    }

    try {
      print("[Login] Attempting login for $email");
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      print("[Login] Firebase login successful. UID: ${result.user?.uid}");

      final uid = result.user?.uid;
      if (uid != null) {
        await fetchUserModel(uid);
      }

      print("[Login] Navigating to dashboard");

      Get.offAllNamed('/dashboard');
    } catch (e) {
      print("[Login] Failed: $e");
      Get.snackbar('Login Failed', e.toString());
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    Get.offAllNamed('/login');
  }

  Future<String> getUserRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 'customer';

    final doc = await _firestore.collection('roles').doc(uid).get();
    return doc.data()?['role'] ?? 'customer';
  }
}
