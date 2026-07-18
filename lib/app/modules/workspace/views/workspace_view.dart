import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:postgetx/app/core/config/app_config.dart';
import 'package:postgetx/app/data/models/role_permission.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';
import 'package:postgetx/app/modules/settings/controllers/theme_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../routes/browser_route_sync.dart';
import '../../../routes/workspace_route_metadata.dart';
import '../../../shared/widgets/malprax_panel.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_layout.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../controllers/workspace_controller.dart';
import '../widgets/crud_sections.dart';
import '../widgets/workspace_sections.dart';

class WorkspaceView extends GetView<WorkspaceController> {
  const WorkspaceView({super.key});

  @override
  Widget build(BuildContext context) {
    final desktopNavigation = MediaQuery.sizeOf(context).width >= 1280;
    return Scaffold(
      drawer: desktopNavigation
          ? null
          : const Drawer(
              child: SafeArea(
                  child: _Navigation(compact: false, collapsed: false))),
      body: SafeArea(
        child: Obx(
          () => controller.loading.value
              ? const Center(child: CircularProgressIndicator())
              : Stack(children: [
                  Row(children: [
                    if (desktopNavigation)
                      SizedBox(
                        width: controller.sidebarCollapsed.value
                            ? AppLayout.collapsedSidebarWidth
                            : AppLayout.expandedSidebarWidth,
                        child: _Navigation(
                          compact: true,
                          collapsed: controller.sidebarCollapsed.value,
                        ),
                      ),
                    Expanded(
                      child: Column(children: [
                        const _TopBar(),
                        Expanded(
                          child: controller.activeDestination.value ==
                                  WorkspaceRouteMetadata.checkout
                              ? const _CheckoutWorkspace()
                              : _ModuleContent(
                                  section: controller.activePageTitle),
                        ),
                      ]),
                    ),
                  ]),
                  Positioned(
                    key: const ValueKey('shell-top-divider'),
                    top: AppLayout.topBarHeight - 1,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: SizedBox(
                        height: 1,
                        child:
                            ColoredBox(color: Theme.of(context).dividerColor),
                      ),
                    ),
                  ),
                ]),
        ),
      ),
    );
  }
}

class _Navigation extends GetView<WorkspaceController> {
  const _Navigation({required this.compact, required this.collapsed});
  final bool compact;
  final bool collapsed;

  @override
  Widget build(BuildContext context) => ColoredBox(
        key: const ValueKey('cashier-sidebar'),
        color: AppColors.ink,
        child: Column(children: [
          SizedBox(
            height: AppLayout.topBarHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: collapsed ? 7 : AppSpacing.md),
              child: Row(children: [
                IconButton(
                  key: const ValueKey('sidebar-toggle'),
                  tooltip: compact ? 'Malprax POS' : 'Close menu',
                  onPressed: compact
                      ? controller.toggleSidebar
                      : () => Navigator.maybePop(context),
                  icon: const Icon(Icons.menu_rounded,
                      size: 20, color: AppColors.text),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: AppSpacing.xs),
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('POS',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 17,
                                fontWeight: FontWeight.w800)),
                        Text('MALPRAX',
                            style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 7,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2)),
                      ],
                    ),
                  ),
                ],
              ]),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(7, 10, 7, 6),
              children: controller.visibleDestinations.map((destination) {
                return Obx(() {
                  final selected =
                      controller.activeDestination.value == destination;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: selected
                          ? AppColors.primaryStrong
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: InkWell(
                        key: ValueKey('nav-${destination.title.toLowerCase()}'),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        onTap: () {
                          controller.selectSection(destination.title);
                          if (!compact) Navigator.maybePop(context);
                        },
                        child: SizedBox(
                          height: 42,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: collapsed ? 9 : 11),
                            child: Row(children: [
                              Icon(destination.icon,
                                  size: 18,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textMuted),
                              if (!collapsed) ...[
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(destination.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: selected
                                              ? Colors.white
                                              : AppColors.text,
                                          fontSize: 11,
                                          fontWeight: selected
                                              ? FontWeight.w700
                                              : FontWeight.w500)),
                                ),
                              ],
                            ]),
                          ),
                        ),
                      ),
                    ),
                  );
                });
              }).toList(),
            ),
          ),
          _TerminalClock(collapsed: collapsed),
        ]),
      );
}

class _TerminalClock extends StatefulWidget {
  const _TerminalClock({required this.collapsed});
  final bool collapsed;

  @override
  State<_TerminalClock> createState() => _TerminalClockState();
}

class _TerminalClockState extends State<_TerminalClock> {
  late Timer timer;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => now = DateTime.now());
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: widget.collapsed
            ? const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Column(children: [
                  Icon(Icons.receipt_long_outlined,
                      color: AppColors.textMuted, size: 15),
                  SizedBox(height: 6),
                  Icon(Icons.circle, color: AppColors.success, size: 7),
                ]),
              )
            : Column(children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: .72),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.borderSoft),
                  ),
                  child: const Row(children: [
                    Icon(Icons.receipt_long_outlined,
                        color: AppColors.textMuted, size: 15),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Terminal',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 8)),
                          Text('T-01',
                              style: TextStyle(
                                  color: AppColors.text,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    Icon(Icons.circle, color: AppColors.success, size: 7),
                  ]),
                ),
                const SizedBox(height: 7),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: .72),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.borderSoft),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('h:mm a').format(now),
                            style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text(DateFormat('MMM d, yyyy').format(now),
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 8)),
                        Text(DateFormat('EEEE').format(now),
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 8)),
                      ]),
                ),
              ]),
      );
}

class _TopBar extends GetView<WorkspaceController> {
  const _TopBar();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final full = constraints.maxWidth >= 1080;
          final compact = constraints.maxWidth < 700;
          final theme = Get.isRegistered<ThemeController>()
              ? Get.find<ThemeController>()
              : null;
          final repository = Get.isRegistered<LocalHiveRepository>()
              ? Get.find<LocalHiveRepository>()
              : null;
          final cashier = repository?.currentUser;
          final cashierName = cashier?.name ?? 'Demo Admin';
          final cashierRole = cashier?.role ?? 'Cashier';
          final cashierInitials = cashierName
              .split(' ')
              .where((part) => part.isNotEmpty)
              .take(2)
              .map((part) => part[0].toUpperCase())
              .join();
          return Container(
            key: const ValueKey('cashier-topbar'),
            height: AppLayout.topBarHeight,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.ink
                : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(children: [
              if (!full)
                Builder(
                  builder: (context) => IconButton(
                    key: const ValueKey('open-navigation'),
                    tooltip: 'Open navigation',
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.menu_rounded),
                  ),
                ),
              SizedBox(
                  width: full
                      ? 205
                      : compact
                          ? 82
                          : 138,
                  child: Obx(() => Text(controller.activePageTitle,
                      key: const ValueKey('active-page-title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800)))),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                        maxWidth: AppLayout.maximumSearchWidth),
                    child: TextField(
                      key: const ValueKey('cashier-search'),
                      onChanged: controller.setSearch,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: compact
                            ? 'Search products or SKU'
                            : 'Search products by name, SKU, or barcode',
                        prefixIcon: const Icon(Icons.search_rounded, size: 19),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              if (!compact)
                OutlinedButton.icon(
                  key: const ValueKey('scan-barcode'),
                  onPressed: () => _showBarcodeDialog(context),
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 17),
                  label: Text(full ? 'Scan Barcode' : 'Scan'),
                ),
              const SizedBox(width: 7),
              IconButton(
                key: const ValueKey('theme-toggle'),
                tooltip: 'Toggle theme',
                onPressed: () {
                  final preference =
                      Theme.of(context).brightness == Brightness.dark
                          ? AppThemePreference.light
                          : AppThemePreference.dark;
                  if (theme == null) {
                    Get.changeThemeMode(preference == AppThemePreference.dark
                        ? ThemeMode.dark
                        : ThemeMode.light);
                  } else {
                    theme.select(preference);
                  }
                },
                icon: Icon(Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined),
              ),
              _NotificationBell(controller: controller),
              if (full) ...[
                const SizedBox(width: 7),
                Container(width: 1, height: 32, color: AppColors.border),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(cashierName,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700)),
                    Text(cashierRole.capitalizeFirst ?? cashierRole,
                        style: const TextStyle(
                            fontSize: 9, color: AppColors.textMuted)),
                  ],
                ),
              ],
              PopupMenuButton<String>(
                key: const ValueKey('cashier-menu'),
                tooltip: 'Cashier menu',
                onSelected: (value) async {
                  if (value == 'settings') {
                    controller.selectSection('Settings');
                  } else if (value == 'signout') {
                    await Get.find<LocalHiveRepository>().logout();
                    _openLogin();
                  }
                },
                itemBuilder: (_) => [
                  if (controller.can(AppPermission.manageSettings))
                    const PopupMenuItem(
                        value: 'settings', child: Text('Settings')),
                  const PopupMenuItem(
                      value: 'signout', child: Text('Sign out')),
                ],
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Row(children: [
                    CircleAvatar(
                        radius: 16,
                        child: Text(
                            cashierInitials.isEmpty ? 'DA' : cashierInitials)),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                  ]),
                ),
              ),
              if (full) ...[
                Container(width: 1, height: 32, color: AppColors.border),
                const SizedBox(width: 10),
                const Icon(Icons.circle, size: 8, color: AppColors.success),
                const SizedBox(width: 6),
                const Text('Offline',
                    style:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
              ],
            ]),
          );
        },
      );

  void _showBarcodeDialog(BuildContext context) => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Scan Barcode'),
          content: const Text(
              'Bluetooth or USB scanner input is ready. In demo mode, scan a code or search by SKU.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close')),
          ],
        ),
      );
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.controller});
  final WorkspaceController controller;

  @override
  Widget build(BuildContext context) => Obx(() => MenuAnchor(
        style: const MenuStyle(
            maximumSize: WidgetStatePropertyAll(Size(390, 520))),
        menuChildren: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text('Notifications',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
          ...controller.latestNotifications
              .map((notification) => MenuItemButton(
                    key: ValueKey('bell-notification-${notification.id}'),
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                          notification.isRead
                              ? Colors.transparent
                              : AppColors.primary.withValues(alpha: .10)),
                      padding: const WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                    ),
                    onPressed: () => controller.openNotification(notification),
                    leadingIcon: Icon(
                        notification.isRead
                            ? Icons.notifications_none_outlined
                            : Icons.notifications_active_outlined,
                        color: notification.isRead
                            ? AppColors.textMuted
                            : AppColors.primary),
                    child: SizedBox(
                      width: 260,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notification.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: notification.isRead
                                        ? FontWeight.w500
                                        : FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text(notification.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textMuted)),
                          ]),
                    ),
                  )),
          if (controller.latestNotifications.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No local notifications yet.'),
            ),
          const Divider(height: 1),
          MenuItemButton(
            key: const ValueKey('view-all-notifications'),
            onPressed: () => controller.selectSection('Notifications'),
            leadingIcon: const Icon(Icons.list_alt_outlined),
            child: const Text('View all notifications'),
          ),
        ],
        builder: (context, menu, _) => Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              key: const ValueKey('notifications'),
              tooltip: 'Open notification center',
              onPressed: () => menu.isOpen ? menu.close() : menu.open(),
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            if (controller.unreadNotificationCount > 0)
              Positioned(
                right: 3,
                top: 2,
                child: Container(
                  constraints:
                      const BoxConstraints(minWidth: 15, minHeight: 15),
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: AppColors.danger, shape: BoxShape.circle),
                  child: Text('${controller.unreadNotificationCount}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.w800)),
                ),
              ),
          ],
        ),
      ));
}

class _CheckoutWorkspace extends StatelessWidget {
  const _CheckoutWorkspace();

  // Padding (24) + catalog (520) + gaps (24) + cart (360) + insights (280).
  // Below this width the catalog drops to three columns, which needs four
  // product rows and cannot share a fixed-height workstation with the panels.
  static const _minimumWorkstationWidth = 1208.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= _minimumWorkstationWidth) {
            final cartWidth = constraints.maxWidth >= 1450
                ? 400.0
                : constraints.maxWidth >= 1250
                    ? 380.0
                    : 360.0;
            final insightWidth = constraints.maxWidth >= 1450
                ? 320.0
                : constraints.maxWidth >= 1250
                    ? 300.0
                    : 280.0;
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(children: [
                const Expanded(child: _CatalogColumn()),
                const SizedBox(width: AppSpacing.md),
                SizedBox(width: cartWidth, child: const CartPanel()),
                const SizedBox(width: AppSpacing.md),
                SizedBox(width: insightWidth, child: const _InsightColumn()),
              ]),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: const Column(children: [
              _CatalogColumn(),
              SizedBox(height: AppSpacing.md),
              CartPanel(),
              SizedBox(height: AppSpacing.md),
              _InsightColumn(),
            ]),
          );
        },
      );
}

class _CatalogColumn extends StatelessWidget {
  const _CatalogColumn();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final workstation =
              constraints.hasBoundedHeight && constraints.maxHeight.isFinite;
          final cardExtent = workstation
              ? ((constraints.maxHeight -
                          (constraints.maxHeight * .35).clamp(224.0, 296.0) -
                          108) /
                      2)
                  .clamp(148.0, 210.0)
              : 176.0;
          final wideSummary = workstation || constraints.maxWidth >= 700;
          final summaries = wideSummary
              ? Row(
                  crossAxisAlignment: workstation
                      ? CrossAxisAlignment.stretch
                      : CrossAxisAlignment.start,
                  children: const [
                    Expanded(child: RecentOrders()),
                    SizedBox(width: AppSpacing.md),
                    Expanded(child: TopSelling()),
                  ],
                )
              : const Column(children: [
                  RecentOrders(),
                  SizedBox(height: AppSpacing.md),
                  TopSelling(),
                ]);
          return Column(children: [
            const SizedBox(height: 40, child: CategoryBar()),
            const SizedBox(height: AppSpacing.md),
            ProductGrid(cardExtent: cardExtent),
            const SizedBox(height: AppSpacing.md),
            if (workstation) Expanded(child: summaries) else summaries,
          ]);
        },
      );
}

class _InsightColumn extends StatelessWidget {
  const _InsightColumn();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final bounded = constraints.hasBoundedHeight;
          if (!bounded) {
            return const Column(children: [
              InventoryAlerts(),
              SizedBox(height: AppSpacing.md),
              SalesStats(),
              SizedBox(height: AppSpacing.md),
              ReceiptStatus(),
            ]);
          }
          return const Column(children: [
            Expanded(flex: 11, child: InventoryAlerts()),
            SizedBox(height: AppSpacing.md),
            Expanded(flex: 12, child: SalesStats()),
            SizedBox(height: AppSpacing.md),
            Expanded(flex: 8, child: ReceiptStatus()),
          ]);
        },
      );
}

class _ModuleContent extends GetView<WorkspaceController> {
  const _ModuleContent({required this.section});
  final String section;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: KeyedSubtree(
          key: ValueKey('module-content-${section.toLowerCase()}'),
          child: const {
            'Orders',
            'Products',
            'Inventory',
            'Customers',
            'Expenses',
            'Notifications',
            'Trash'
          }.contains(section)
              ? CrudSection(section: section)
              : section == 'Reports'
                  ? LayoutBuilder(builder: (context, constraints) {
                      if (constraints.maxWidth < 700) {
                        return const Column(children: [
                          SalesStats(),
                          SizedBox(height: AppSpacing.md),
                          TopSelling(),
                        ]);
                      }
                      return const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: SalesStats()),
                            SizedBox(width: AppSpacing.md),
                            Expanded(child: TopSelling()),
                          ]);
                    })
                  : section == 'Settings'
                      ? _Settings(controller: controller)
                      : const SizedBox.shrink(),
        ),
      );
}

class _Settings extends StatelessWidget {
  const _Settings({required this.controller});
  final WorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeController>();
    return MalpraxPanel(
      title: 'Local Application Settings',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Obx(() => SegmentedButton<AppThemePreference>(
              segments: const [
                ButtonSegment(
                    value: AppThemePreference.light, label: Text('Light')),
                ButtonSegment(
                    value: AppThemePreference.dark, label: Text('Dark')),
                ButtonSegment(
                    value: AppThemePreference.auto, label: Text('Auto')),
              ],
              selected: {theme.preference.value},
              onSelectionChanged: (value) => theme.select(value.first),
            )),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: () async {
            await Get.find<LocalHiveRepository>().resetDemoData();
            await controller.refreshData();
          },
          icon: const Icon(Icons.restart_alt),
          label: const Text('Reset seeded demo data'),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () async {
            await Get.find<LocalHiveRepository>().logout();
            _openLogin();
          },
          icon: const Icon(Icons.logout),
          label: const Text('Sign out'),
        ),
        const SizedBox(height: 8),
        const Text(
            '${AppConfig.productName} · Hive local persistence · No cloud backend'),
      ]),
    );
  }
}

void _openLogin() {
  Get.offAllNamed(AppRoutes.login);
  publishBrowserRoute(AppRoutes.login, replace: true);
}
