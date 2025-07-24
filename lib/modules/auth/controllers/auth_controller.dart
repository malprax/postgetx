// lib/modules/auth/controllers/auth_controller.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final currentUser = Rxn<User>();
  final firebaseUser = Rxn<User>();
  final currentUserModel = Rxn<UserModel>();
  final emailVerified = false.obs;

  // TextEditingControllers for login/register/forgot password
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  @override
  void onInit() {
    _auth.authStateChanges().listen((user) async {
      currentUser.value = user;
      firebaseUser.value = user;

      if (user != null) {
        await loadUserModel(user.uid);
        emailVerified.value = user.emailVerified;
      } else {
        currentUserModel.value = null;
        emailVerified.value = false;
      }
    });
    super.onInit();
  }

  Future<void> loadUserModel(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      currentUserModel.value =
          UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
  }

  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> reloadEmailStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      final refreshedUser = _auth.currentUser!;
      firebaseUser.value = refreshedUser;
      emailVerified.value = refreshedUser.emailVerified;
    }
  }

  Future<void> forgotPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar('Error', 'Email harus diisi');
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar('Terkirim', 'Link reset password telah dikirim.');
    } catch (e) {
      Get.snackbar('Gagal', 'Terjadi kesalahan: $e');
    }
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Email dan Password harus diisi');
      return;
    }
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Get.snackbar('Login Gagal', 'Terjadi kesalahan: $e');
    }
  }

  Future<void> register({required String role}) async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Semua field wajib diisi');
      return;
    }
    try {
      final result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      final uid = result.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'role': role,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('roles').doc(uid).set({
        'role': role,
      });

      await sendVerificationEmail();
      Get.snackbar('Berhasil', 'Registrasi berhasil. Verifikasi email Anda.');
      await logout();
    } catch (e) {
      Get.snackbar('Gagal Registrasi', 'Terjadi kesalahan: $e');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    currentUser.value = null;
    firebaseUser.value = null;
    currentUserModel.value = null;
    emailVerified.value = false;
    emailController.clear();
    passwordController.clear();
    nameController.clear();
  }
}
