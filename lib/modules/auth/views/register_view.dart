import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:postgetx/modules/auth/controllers/auth_controller.dart';

class RegisterView extends StatelessWidget {
  final bool enableRoleSelection;

  RegisterView({super.key, this.enableRoleSelection = true});

  final AuthController authController = Get.put(AuthController());

  final RxString selectedRole = 'customer'.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 213, 248),
      body: Stack(
        children: [
          Center(
            child: Container(
              width: 800,
              height: 550,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                children: [
                  /// Illustration
                  Expanded(
                    child: Image.asset(
                      'assets/login_amico.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const VerticalDivider(width: 32),

                  /// Form Section
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Register",
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        TextField(
                          controller: authController.nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: authController.emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(() => TextField(
                              controller: authController.passwordController,
                              obscureText:
                                  !authController.isPasswordVisible.value,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    authController.isPasswordVisible.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    authController.isPasswordVisible.toggle();
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            )),
                        const SizedBox(height: 16),

                        /// Role dropdown (optional)
                        if (enableRoleSelection)
                          Obx(
                            () => DropdownButtonFormField<String>(
                              value: selectedRole.value,
                              onChanged: (val) =>
                                  selectedRole.value = val ?? 'customer',
                              decoration: InputDecoration(
                                labelText: 'Select Role',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'admin', child: Text('Admin')),
                                DropdownMenuItem(
                                    value: 'staff', child: Text('Staff')),
                                DropdownMenuItem(
                                    value: 'customer', child: Text('Customer')),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              authController.register(role: selectedRole.value);
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
                            child: const Text("Register"),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Get.back(); // back to login
                          },
                          child: const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: "Already have an account? "),
                                TextSpan(
                                  text: "Log In",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
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
