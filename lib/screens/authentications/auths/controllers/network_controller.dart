import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../views/no_network_view.dart';
import 'global_auth_controller.dart';
import '../../../farmers/vet/controllers/vet_bookings_controller.dart';
import '../../../farmers/home/controllers/farmers_home_controller.dart';

class NetworkController extends GetxController {
  bool isConnected = true;
  bool isDialogShowing = false;

  @override
  void onInit() {
    super.onInit();
    // Delay initialization so GetMaterialApp has time to mount its overlay
    Future.delayed(const Duration(seconds: 2), () {
      InternetConnection().onStatusChange.listen((InternetStatus status) {
        if (status == InternetStatus.connected) {
          if (!isConnected) {
            isConnected = true;
            
            if (isDialogShowing) {
              try {
                Get.back(); // close the NoNetworkView
              } catch (_) {}
              isDialogShowing = false;
            }
            
            Future.delayed(const Duration(milliseconds: 500), () {
              try {
                Get.snackbar(
                  'Back Online',
                  'Internet connection restored',
                  backgroundColor: const Color(0xFF4CAF50), // Green like Netflix/Google
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16), // Floating above bottom nav
                  borderRadius: 8,
                  duration: const Duration(seconds: 3),
                  icon: const Icon(Icons.wifi, color: Colors.white),
                  isDismissible: true,
                );
              } catch (e) {
                print('Snackbar render error: $e');
              }
            });
            
            _refreshData();
          }
        } else {
          if (isConnected) {
            isConnected = false;
            if (!isDialogShowing) {
              isDialogShowing = true;
              try {
                Get.to(() => const NoNetworkView(), transition: Transition.fadeIn, fullscreenDialog: true);
              } catch (e) {
                isDialogShowing = false;
              }
            }
          }
        }
      });
    });
  }

  void _refreshData() {
    // Attempt to refresh known active controllers
    if (Get.isRegistered<VetBookingsController>()) {
      Get.find<VetBookingsController>().fetchBookings();
    }
    
    if (Get.isRegistered<FarmersHomeController>()) {
      Get.find<FarmersHomeController>().fetchWeather();
    }
    
    // Refreshing other views globally by updating the current route slightly or forcing update
    // Force all active GetX controllers to update their observers if needed:
    // This is optional since specific fetch methods above already trigger reactivity.
  }
}
