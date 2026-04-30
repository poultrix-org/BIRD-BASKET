// controllers/splash_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auths/controllers/global_auth_controller.dart';
import '../../auths/views/login_view.dart';
import '../../role_selections/views/role_selection_view.dart';
import '../../role_selections/models/user_models.dart';

class SplashController extends GetxController {
  static bool get isRegistering => GlobalAuthController.isRegistering;
  static set isRegistering(bool val) =>
      GlobalAuthController.isRegistering = val;

  final PageController pageController = PageController();
  var currentPage = 0.obs;

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) => currentPage.value = index;

  void nextPage() {
    if (currentPage.value == 2) {
      Get.offAll(() => LoginView());
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }
}
