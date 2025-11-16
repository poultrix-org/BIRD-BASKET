// controllers/role_selection_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';


import '../setup_account/views/setup_account_common_view.dart';

class RoleSelectionController extends GetxController {
  final List<String> roles = [
    'Farmer',
    'Veterinarian',
    'Company',
    // 'Feed Supplier', // Removed
    'Chicks Delivery',
  ];

  final List<IconData> roleIcons = [
    Icons.agriculture,
    Icons.medical_services,
    Icons.business,
    // Icons.shopping_bag, // Removed
    Icons.delivery_dining,
  ];

  void selectRole(String role) {
    // Navigate to the common setup screen, passing the selected role
    Get.to(() => SetupAccountCommonView(), arguments: role);
  }
}