// controllers/splash_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../role_selections/views/role_selection_view.dart';

class SplashController extends GetxController {
  final PageController pageController = PageController();
  var currentPage = 0.obs;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value == 2) {
      // Last page, navigate to Role Selection
      Get.off(() => RoleSelectionView());
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }
}