import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../farmers/home/views/farmers_home_view.dart';
import '../../../vetnarians/home/views/vet_home_view.dart';
import '../../../company/home/views/company_home_view.dart';
import '../../../chicks/home/views/chicks_delivery_home_view.dart';
import '../../role_selections/models/user_models.dart';
import '../views/login_view.dart';

class GlobalAuthController extends GetxController {
  final supabase = Supabase.instance.client;
  late final StreamSubscription<AuthState> _authSubscription;

  static bool isRegistering = false;

  @override
  void onInit() {
    super.onInit();
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (isRegistering) return;

      if (event == AuthChangeEvent.initialSession ||
          event == AuthChangeEvent.signedIn) {
        if (session != null) {
          _checkAndRedirect(session.user);
        }
      } else if (event == AuthChangeEvent.signedOut) {
        if (Get.currentRoute != '/LoginView') {
          Get.offAll(() => LoginView());
        }
      }
    });
  }

  @override
  void onClose() {
    _authSubscription.cancel();
    super.onClose();
  }

  Future<void> _checkAndRedirect(User user) async {
    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null && data.isNotEmpty) {
        UserModel userModel = _mapDataToModel(data, user);
        _navigateToHome(userModel.role, userModel);
      } else {
        await supabase.auth.signOut();
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
      print("Global auth check error: $e");
      // Do not log out on network/temporary errors
      Get.snackbar(
        'Connection Error',
        'Unable to verify your profile at this time. Check your internet connection.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

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
}
