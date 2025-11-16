// controllers/role_selection_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auths/views/login_view.dart';
import '../../setup_account/views/setup_account_common_view.dart';

class RoleSelectionController extends GetxController {
  final List<String> roles = [
    'Farmer',
    'Veterinarian',
    'Company',
    'Chicks Delivery',
    'Meat Shop',
  ];

  final List<IconData> roleIcons = [
    Icons.agriculture,
    Icons.medical_services,
    Icons.business,
    Icons.delivery_dining,
    Icons.storefront,
  ];

  void selectRole(String role) {
    // Navigate to the setup screen, passing the selected role
    Get.to(() => SetupAccountCommonView(), arguments: role);
  }

  // --- NEW: Added this method back ---
  void navigateToLogin() {
    // Navigate to the LoginView
    Get.offAll(() => LoginView());
  }
}