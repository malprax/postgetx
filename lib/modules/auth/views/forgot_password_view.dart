import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:postgetx/modules/auth/controllers/auth_controller.dart';

class ForgotPasswordView extends StatelessWidget {
  ForgotPasswordView({super.key});

  final AuthController authController = Get.find<AuthController>();
  final RxBool isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 213, 248),
      body: Stack(
        children: [
          Center(
            child: Container(
              width: 600,
              height: 400,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Lupa Password',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: authController.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Masukkan Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(() => SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading.value
                              ? null
                              : () async {
                                  isLoading.value = true;
                                  await authController.forgotPassword();
                                  isLoading.value = false;
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 5, 82, 236),
                            foregroundColor:
                                const Color.fromARGB(237, 255, 255, 255),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text("Kirim Link Reset"),
                        ),
                      )),
                ],
              ),
            ),
          ),

          /// ⬅️ Back Button (pojok kiri atas)
          Positioned(
            top: 40,
            left: 24,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Colors.black87,
              tooltip: 'Kembali',
              onPressed: () {
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }
}
