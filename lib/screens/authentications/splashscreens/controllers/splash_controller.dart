// controllers/splash_controller.dart
import 'dart:async';
import '../../../farmers/home/views/farmers_home_view.dart';
import '../../../vetnarians/home/views/vet_home_view.dart';
import '../../auths/views/login_view.dart';
import '../../role_selections/views/role_selection_view.dart';

import 'package:birdbasket/screens/company/home/views/company_home_view.dart';
import 'package:birdbasket/screens/chicks/home/views/chicks_delivery_home_view.dart';
// import 'package:birdbasket/screens/meat_shop/home/views/meat_shop_home_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashController extends GetxController {
  final PageController pageController = PageController();
  var currentPage = 0.obs;
  final supabase = Supabase.instance.client;

  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void onInit() {
    super.onInit();

    // Listen to all auth changes
    _authSubscription =
        supabase.auth.onAuthStateChange.listen((AuthState data) {
          final event = data.event;
          final session = data.session;

          if (event == AuthChangeEvent.initialSession) {
            // App has just started
            if (session != null) {
              _checkAndRedirect(session.user);
            } else {
              // User is logged out, let splash animation continue
            }
          } else if (event == AuthChangeEvent.signedIn) {
            // User has just logged in (Email, Google, etc.)
            _checkAndRedirect(session!.user);
          } else if (event == AuthChangeEvent.signedOut) {
            // User has just logged out
            Get.offAll(() => LoginView());
          }
        });
  }

  @override
  void onClose() {
    _authSubscription.cancel();
    pageController.dispose();
    super.onClose();
  }

  /// Checks for a profile and redirects.
  /// This is the core logic for routing a logged-in user.
  Future<void> _checkAndRedirect(User user) async {
    try {
      final profile = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null && profile.isNotEmpty) {
        // --- Profile EXISTS ---
        // User is a returning user, send to their home screen
        final String role = profile['role'];
        _navigateToHome(role);
      } else {
        // --- NO Profile ---
        // User signed up (e.g. with Google) but never finished setup.
        // Send them to role selection to create their profile.
        Get.offAll(() => RoleSelectionView());
      }
    } catch (e) {
      // On error, send to login
      Get.offAll(() => LoginView());
    }
  }

  /// Navigates to the correct home screen based on role.
  void _navigateToHome(String role) {
    switch (role) {
      case 'Farmer':
        Get.offAll(() => FarmersHomeView());
        break;
      case 'Veterinarian':
        Get.offAll(() => VetHomeView());
        break;
      case 'Company':
        Get.offAll(() => CompanyHomeView());
        break;
      case 'Chicks Delivery':
        Get.offAll(() => ChicksDeliveryHomeView());
        break;
      case 'Meat Shop':
      // Get.offAll(() => MeatShopHomeView());
        break; // Add MeatShopHomeView when created
      default:
      // Fallback
        Get.offAll(() => LoginView());
    }
  }

  // --- Lottie Animation PageView Logic ---
  void onPageChanged(int index) {
    currentPage.value = index;
  }

  /// Called when "Get Started" is pressed.
  void nextPage() {
    if (currentPage.value == 2) {
      // Last page, navigate to Login View
      Get.off(() => LoginView());
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }
}