import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/app_config.dart';
import '../../../../repositories/local_hive_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../routes/browser_route_sync.dart';
import '../../../shared/forms/form_validators.dart';
import '../../../shared/widgets/malprax_form_field.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';

class DemoLoginView extends StatefulWidget {
  const DemoLoginView({super.key});
  @override
  State<DemoLoginView> createState() => _DemoLoginViewState();
}

class _DemoLoginViewState extends State<DemoLoginView> {
  final email = TextEditingController(text: AppConfig.demoEmail);
  final password = TextEditingController(text: AppConfig.demoPassword);
  final formKey = GlobalKey<FormState>();
  bool busy = false;
  bool obscurePassword = true;

  void togglePasswordVisibility() =>
      setState(() => obscurePassword = !obscurePassword);

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (busy) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    setState(() => busy = true);
    try {
      await Get.find<LocalHiveRepository>().login(
        email: email.text.trim(),
        password: password.text,
      );
      Get.offAllNamed(AppRoutes.cashier);
      publishBrowserRoute(AppRoutes.cashier, replace: true);
    } catch (error) {
      Get.snackbar(
        'Local demo login failed',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> loginAsOwner() async {
    email.text = AppConfig.ownerEmail;
    password.text = AppConfig.ownerPassword;
    await login();
  }

  Future<void> loginAsStaff() async {
    email.text = AppConfig.staffEmail;
    password.text = AppConfig.staffPassword;
    await login();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ink,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-.7, -.75),
              radius: 1.35,
              colors: [Color(0xFF173B69), AppColors.ink, Color(0xFF030A12)],
            ),
          ),
          child: Stack(children: [
            const Positioned(
                top: -120,
                left: -80,
                child: _GlowOrb(size: 360, color: AppColors.primary)),
            const Positioned(
                bottom: -170,
                right: -80,
                child: _GlowOrb(size: 430, color: Color(0xFF7A4DFF))),
            SafeArea(
              child: LayoutBuilder(builder: (context, constraints) {
                final wide = constraints.maxWidth >= 920;
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                  const Expanded(child: _BrandPanel()),
                                  const SizedBox(width: 56),
                                  SizedBox(
                                      width: 420,
                                      child: _LoginPanel(state: this)),
                                ])
                          : Column(mainAxisSize: MainAxisSize.min, children: [
                              const _CompactBrand(),
                              const SizedBox(height: AppSpacing.xl),
                              ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 440),
                                  child: _LoginPanel(state: this)),
                            ]),
                    ),
                  ),
                );
              }),
            ),
          ]),
        ),
      );
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Logo(),
        const SizedBox(height: 42),
        const Text('Retail operations,\nreimagined.',
            style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                height: 1.05,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5)),
        const SizedBox(height: AppSpacing.lg),
        const SizedBox(
            width: 520,
            child: Text(
                'A fast, secure, offline-first point of sale built for modern stores. Your products, transactions, and reports stay available without an internet connection.',
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 16, height: 1.6))),
        const SizedBox(height: 36),
        const Wrap(spacing: 12, runSpacing: 12, children: [
          _FeatureChip(
              icon: Icons.offline_bolt_outlined, label: '100% Offline'),
          _FeatureChip(icon: Icons.lock_outline, label: 'Local & Private'),
          _FeatureChip(icon: Icons.bolt, label: 'Instant Checkout'),
        ]),
        const SizedBox(height: 42),
        Row(children: [
          Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.success, blurRadius: 10)
                  ])),
          const SizedBox(width: 10),
          const Text('Local database ready',
              style: TextStyle(
                  color: AppColors.success, fontWeight: FontWeight.w700)),
          const SizedBox(width: 12),
          Text('· ${AppConfig.versionLabel}',
              style: const TextStyle(color: AppColors.textMuted)),
        ]),
      ]);
}

class _CompactBrand extends StatelessWidget {
  const _CompactBrand();
  @override
  Widget build(BuildContext context) => const Column(children: [
        _Logo(),
        SizedBox(height: AppSpacing.lg),
        Text('Offline retail. Future ready.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900)),
        SizedBox(height: 6),
        Text('Secure local cashier access',
            style: TextStyle(color: AppColors.textMuted)),
      ]);
}

class _Logo extends StatelessWidget {
  const _Logo();
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF6C63FF)]),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withValues(alpha: .4),
                      blurRadius: 24)
                ]),
            child:
                const Icon(Icons.point_of_sale_rounded, color: Colors.white)),
        const SizedBox(width: 12),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('MALPRAX',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.6)),
          Text('RETAIL SYSTEM',
              style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.2)),
        ]),
      ]);
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({required this.state});
  final _DemoLoginViewState state;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: .92),
          borderRadius: BorderRadius.circular(AppRadius.lg * 1.5),
          border: Border.all(color: Colors.white.withValues(alpha: .1)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x66000000), blurRadius: 48, offset: Offset(0, 24))
          ],
        ),
        child: Theme(
          data: ThemeData.dark(useMaterial3: true).copyWith(
            colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary, brightness: Brightness.dark),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppColors.surfaceHigh,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),
          child: Form(
            key: state.formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Welcome back',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 27,
                                  fontWeight: FontWeight.w900)),
                          SizedBox(height: 6),
                          Text('Sign in to open the local cashier',
                              style: TextStyle(color: AppColors.textMuted)),
                        ])),
                    _OfflineBadge(),
                  ]),
                  const SizedBox(height: 28),
                  MalpraxFormField(
                      key: const ValueKey('login-email-field'),
                      controller: state.email,
                      label: 'Email',
                      hint: 'Example: owner@demo.local',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      icon: Icons.alternate_email_rounded,
                      validator: FormValidators.email),
                  const SizedBox(height: AppSpacing.lg),
                  MalpraxFormField(
                    key: const ValueKey('login-password-field'),
                    controller: state.password,
                    label: 'Password',
                    hint: 'Example: demo123',
                    obscureText: state.obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => state.login(),
                    icon: Icons.lock_outline_rounded,
                    validator: (value) =>
                        FormValidators.required(value, 'Password'),
                    suffixIcon: IconButton(
                        onPressed: state.togglePasswordVisibility,
                        icon: Icon(state.obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined)),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: .22))),
                    child: const Row(children: [
                      Icon(Icons.key_rounded,
                          color: AppColors.primary, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                          child: Text(
                              'Owner: owner@demo.local · owner123\nStaff: staff@demo.local · staff123',
                              style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                  height: 1.5))),
                    ]),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const ValueKey('login-as-owner'),
                        onPressed: state.busy ? null : state.loginAsOwner,
                        icon: const Icon(Icons.admin_panel_settings_outlined),
                        label: const Text('Owner Demo'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const ValueKey('login-as-staff'),
                        onPressed: state.busy ? null : state.loginAsStaff,
                        icon: const Icon(Icons.badge_outlined),
                        label: const Text('Staff Demo'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md))),
                      onPressed: state.busy ? null : state.login,
                      icon: state.busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.arrow_forward_rounded),
                      label: Text(
                          state.busy ? 'Opening cashier…' : 'Enter Cashier',
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_outlined,
                            color: AppColors.textMuted, size: 15),
                        SizedBox(width: 6),
                        Flexible(
                            child: Text(
                                'No cloud connection · Data stays on this device',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 10))),
                      ]),
                ]),
          ),
        ),
      );
}

class _OfflineBadge extends StatelessWidget {
  const _OfflineBadge();
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.success.withValues(alpha: .25))),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.circle, size: 7, color: AppColors.success),
        SizedBox(width: 6),
        Text('OFFLINE',
            style: TextStyle(
                color: AppColors.success,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1))
      ]));
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .055),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: Colors.white.withValues(alpha: .09))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: AppColors.primary, size: 17),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))
      ]));
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => IgnorePointer(
      child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                color.withValues(alpha: .19),
                color.withValues(alpha: 0)
              ]))));
}
