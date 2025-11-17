// controllers/splash_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import Home Views
import '../../../farmers/home/views/farmers_home_view.dart';
import '../../../vetnarians/home/views/vet_home_view.dart';
import '../../../company/home/views/company_home_view.dart';
import '../../../chicks/home/views/chicks_delivery_home_view.dart';
// import '../../../meat_shop/home/views/meat_shop_home_view.dart';

import '../../auths/views/login_view.dart';
import '../../role_selections/views/role_selection_view.dart';
import '../../role_selections/models/user_models.dart';

class SplashController extends GetxController {
  // --- 1. STATIC FLAG FOR REGISTRATION ---
  // This flag tells the controller: "Don't kick the user out, we are currently building their profile"
  static bool isRegistering = false;

  final PageController pageController = PageController();
  var currentPage = 0.obs;
  final supabase = Supabase.instance.client;

  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void onInit() {
    super.onInit();

    // Listen to auth state changes
    _authSubscription = supabase.auth.onAuthStateChange.listen((AuthState data) {
      final event = data.event;
      final session = data.session;

      // If we are in the middle of a registration (SetupAccount), IGNORE auth events.
      // The SetupAccountController will handle navigation manually.
      if (isRegistering) return;

      if (event == AuthChangeEvent.initialSession || event == AuthChangeEvent.signedIn) {
        if (session != null) {
          _checkAndRedirect(session.user);
        }
      } else if (event == AuthChangeEvent.signedOut) {
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

  Future<void> _checkAndRedirect(User user) async {
    try {
      // Check if the profile exists in the database
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null && data.isNotEmpty) {
        // --- A. PROFILE FOUND (Valid User) ---
        // Map data to model (prevents crash)
        UserModel userModel = _mapDataToModel(data, user);
        _navigateToHome(userModel.role, userModel);
      } else {
        // --- B. PROFILE MISSING (Unauthorized "Sign Up" Attempt) ---
        // The user tried to login (e.g., via Google) but has no account.
        // We strictly BLOCK this and force them to Sign Up manually.

        await supabase.auth.signOut(); // <--- LOG THEM OUT IMMEDIATELY

        Get.offAll(() => LoginView());
        Get.snackbar(
          'Account Not Found',
          'You do not have an account. Please use the "Sign Up" button to create one.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // Safety net: Log out if error
      await supabase.auth.signOut();
      Get.offAll(() => LoginView());
    }
  }

  // --- Helper: Map JSON to UserModel ---
  UserModel _mapDataToModel(Map<String, dynamic> data, User authUser) {
    return UserModel(
      userId: authUser.id,
      email: authUser.email,
      phone: authUser.phone,
      createdAt: DateTime.tryParse(data['created_at'] ?? ''),
      role: data['role'] ?? '',
      fullName: data['full_name'],
      address: data['address'],
      idProofPath: data['id_proof_path'],
      farmAddress: data['farm_address'],
      farmGpsLat: data['farm_gps_lat'],
      farmGpsLong: data['farm_gps_long'],
      landSize: data['land_size'],
      numberOfHens: data['number_of_hens'],
      typeOfHens: data['type_of_hens'],
      farmProofPath: data['farm_proof_path'],
      clinicName: data['clinic_name'],
      experience: data['experience'],
      specialization: data['specialization'],
      companyName: data['company_name'],
      ownerName: data['owner_name'],
      companyAddress: data['company_address'],
      supplyType: data['supply_type'],
      deliveryRadius: data['delivery_radius'],
      businessProofPath: data['business_proof_path'],
      vehicleType: data['vehicle_type'],
      shopName: data['shop_name'],
      shopAddress: data['shop_address'],
      shopProofPath: data['shop_proof_path'],
    );
  }

  void _navigateToHome(String role, UserModel userModel) {
    switch (role) {
      case 'Farmer':
        Get.offAll(() => FarmersHomeView(), arguments: userModel);
        break;
      case 'Veterinarian':
        Get.offAll(() => VetHomeView(), arguments: userModel);
        break;
      case 'Company':
        Get.offAll(() => CompanyHomeView(), arguments: userModel);
        break;
      case 'Chicks Delivery':
        Get.offAll(() => ChicksDeliveryHomeView(), arguments: userModel);
        break;
      case 'Meat Shop':
        Get.snackbar("Welcome", "Meat Shop Dashboard coming soon");
        break;
      default:
        Get.offAll(() => LoginView());
    }
  }

  void onPageChanged(int index) => currentPage.value = index;

  void nextPage() {
    if (currentPage.value == 2) {
      Get.off(() => LoginView());
    } else {
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }
}