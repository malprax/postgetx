class AppConfig {
  const AppConfig._();

  static const bool demoMode = true;
  static const String productName = 'Retail POS Demo';
  static const String subtitle =
      'Offline-First Point of Sale for Small Businesses';
  static const String versionLabel = 'Demo v1.0';
  static const String ownerEmail = 'owner@demo.local';
  static const String ownerPassword = 'owner123';
  static const String staffEmail = 'staff@demo.local';
  static const String staffPassword = 'staff123';
  static const String demoEmail = ownerEmail;
  static const String demoPassword = ownerPassword;
  static const int maxDemoTransactions = 100;
  static const int maxDemoProducts = 50;
}
