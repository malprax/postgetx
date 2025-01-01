import 'package:get/get.dart';
import 'auth_controller.dart';

class DashboardController extends GetxController {
  // Current index for bottom navigation
  var currentIndex = 0.obs;

  // Titles for each page
  final pageTitles = [
    'Menu',
    'Orders',
    'Profile',
  ];

  // Function to update the selected index in the bottom navigation bar
  void updateIndex(int index) {
    currentIndex.value = index;
  }

  // Logout function
  void logout() {
    // Access the AuthController to handle logout
    Get.find<AuthController>().logout();
    // Navigate to the Login page after logout
    Get.offAllNamed('/login');
  }
}
