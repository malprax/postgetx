import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:postgetx/config/app_config.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});
  final auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: LayoutBuilder(builder: (context, constraints) {
                    final compact = constraints.maxWidth < 720;
                    final intro = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.point_of_sale_rounded,
                              size: 54, color: colors.primary),
                          const SizedBox(height: 20),
                          Text(AppConfig.productName,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(AppConfig.subtitle,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 20),
                          const Text(
                              'Explore a complete offline checkout flow in under three minutes. Everything stays in this browser.'),
                          const SizedBox(height: 16),
                          const Chip(
                              avatar: Icon(Icons.lock_outline, size: 18),
                              label: Text('Local demo data only')),
                          const SizedBox(height: 12),
                          const Text(AppConfig.versionLabel),
                        ]);
                    final form = Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Enter the demo',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text(
                              'Credentials are visible and pre-filled for public visitors.'),
                          const SizedBox(height: 20),
                          TextField(
                              controller: auth.emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                  labelText: 'Demo email',
                                  prefixIcon: Icon(Icons.email_outlined))),
                          const SizedBox(height: 12),
                          Obx(() => TextField(
                              controller: auth.passwordController,
                              obscureText: !auth.isPasswordVisible.value,
                              decoration: InputDecoration(
                                  labelText: 'Demo password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                      onPressed: auth.isPasswordVisible.toggle,
                                      icon: Icon(auth.isPasswordVisible.value
                                          ? Icons.visibility_off
                                          : Icons.visibility))))),
                          const SizedBox(height: 12),
                          SelectableText(
                              '${AppConfig.demoEmail}  •  ${AppConfig.demoPassword}',
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                              onPressed: auth.loginAsDemo,
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Text('Enter Demo'))),
                        ]);
                    if (compact) {
                      return Column(
                          children: [intro, const SizedBox(height: 32), form]);
                    }
                    return Row(children: [
                      Expanded(child: intro),
                      const SizedBox(width: 48),
                      Expanded(child: form)
                    ]);
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
