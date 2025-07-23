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

  void _handleUserChanged(User? firebaseUser) async {
    try {
      if (firebaseUser != null && firebaseUser.emailVerified) {
        final String uid = firebaseUser.uid;
        print("[Auth] User logged in: $uid");

        final doc = await _firestore.collection('users').doc(uid).get();

        if (doc.exists && doc.data() != null) {
          currentUserModel.value = UserModel.fromMap(doc.id, doc.data()!);

          // Hanya arahkan ke dashboard jika belum di sana
          if (Get.currentRoute != '/dashboard') {
            Get.offAllNamed('/dashboard');
          }
        } else {
          print("[Auth] No user document found in Firestore for: $uid");
          Get.snackbar(
              "Login Error", "Data pengguna tidak ditemukan di database.");
        }
      } else {
        print("[Auth] User is null, logged out, or email belum diverifikasi");

        currentUserModel.value = null;

        // Hanya redirect ke login jika bukan sudah di login
        if (Get.currentRoute != '/login') {
          Get.offAllNamed('/login');
        }
      }
    } catch (e) {
      print("[Auth] Error in _handleUserChanged: $e");
      Get.snackbar("Auth Error", "Terjadi kesalahan saat memuat data user.");
    }
  }

  Future<void> fetchUserModel(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        currentUserModel.value = UserModel.fromMap(doc.id, doc.data()!);
      } else {}
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

      // Kirim email verifikasi
      await result.user!.sendEmailVerification();
      print("[Register] Email verification sent to $email");

      // Simpan data user di Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'photoUrl': '',
      });

      Get.dialog(
        AlertDialog(
          title: const Text("Verifikasi Email"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Link verifikasi telah dikirim ke email $email.\n"
                  "Silakan verifikasi email Anda sebelum login."),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Kirim Ulang Email Verifikasi"),
                onPressed: () {
                  resendVerificationEmail();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close dialog
                Get.offAllNamed('/login');
              },
              child: const Text("OK"),
            ),
          ],
        ),
        barrierDismissible: false,
      );
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
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (!(result.user?.emailVerified ?? false)) {
        await _auth.signOut(); // Jangan lanjutkan login
        Get.snackbar(
          'Email Belum Diverifikasi',
          'Silakan periksa email Anda dan klik link verifikasi sebelum login.',
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900],
        );
        return;
      }

      final uid = result.user?.uid;
      if (uid != null) {
        await fetchUserModel(uid);
      }

      Get.offAllNamed('/dashboard');
    } catch (e) {
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

  Future<void> forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar(
        'Error',
        'Please enter a valid email address.',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'Success',
        'Password reset link sent to $email',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        snackPosition: SnackPosition.TOP,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Reset Failed',
        e.message ?? 'Failed to send reset email.',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        Get.snackbar(
          'Terkirim',
          'Email verifikasi telah dikirim ulang ke ${user.email}',
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
        );
      } catch (e) {
        Get.snackbar(
          'Gagal',
          'Gagal mengirim ulang email verifikasi.',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      }
    } else {
      Get.snackbar(
        'Info',
        'Akun sudah diverifikasi atau belum login.',
        backgroundColor: Colors.blue[100],
        colorText: Colors.blue[900],
      );
    }
  }
}
