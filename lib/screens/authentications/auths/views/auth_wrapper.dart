import 'dart:convert';
import 'package:birdbasket/screens/authentications/splashscreens/views/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../farmers/home/views/farmers_home_view.dart';
import '../../../vetnarians/home/views/vet_home_view.dart';
import '../../../company/home/views/company_home_view.dart';
import '../../../chicks/home/views/chicks_delivery_home_view.dart';
import '../../role_selections/models/user_models.dart';
import '../../splashscreens/controllers/splash_controller.dart';
import 'login_view.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Check if user is currently logged in via Supabase
    final session = supabase.auth.currentSession;

    if (session != null && session.user != null) {
      // First try to load from faster SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        final String? localProfileStr = prefs.getString('user_profile');
        if (localProfileStr != null) {
          final Map<String, dynamic> localData = jsonDecode(localProfileStr);
          UserModel userModel = _mapDataToModel(localData, session.user);
          _navigateToHome(userModel.role, userModel);
          return;
        }
      } catch (e) {
        print("Error reading local profile: $e");
      }

      // If no local cache, fetch from Supabase
      try {
        final data = await supabase
            .from('profiles')
            .select()
            .eq('id', session.user.id)
            .maybeSingle();

        if (data != null && data.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_profile', jsonEncode(data));
          UserModel userModel = _mapDataToModel(data, session.user);
          _navigateToHome(userModel.role, userModel);
          return; // Stop here, navigation triggered
        }
      } catch (e) {
        print("Error fetching profile: $e");
      }
    }

    // If not logged in, or failed to fetch profile, go to SplashView (onboarding)
    if (mounted) {
      setState(() {
        isLoading = false;
      });
      // Delay navigation slightly to let initial render finish
      Future.delayed(Duration.zero, () {
        Get.offAll(() => SplashView());
      });
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
    // Make sure SplashController doesn't interrupt this transition
    SplashController.isRegistering = false;

    Future.microtask(() {
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
          Get.offAll(() => SplashView());
          Get.defaultDialog(
            title: "Welcome",
            middleText: "Meat Shop Dashboard coming soon",
          );
          break;
        default:
          Get.offAll(() => SplashView());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading screen while checking auth state
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.brown[700],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // You can replace this with your app logo
              Icon(Icons.egg_alt, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'Initializing...',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    // Fallback UI (though we usually Get.offAll before this)
    return const Scaffold();
  }
}
