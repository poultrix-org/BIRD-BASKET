import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrackVetController extends GetxController {
  var isVetAssigned = true.obs;
  var vetName = 'Dr. Sharma'.obs;
  var vetRating = '4.8'.obs;
  var vetPhone = '+91 9876543210'.obs;
  var vetETA = '15 mins'.obs;

  // Statuses: 0 = Booking Confirmed, 1 = Vet Assigned, 2 = On the Way, 3 = Arrived
  var currentStatus = 2.obs;

  void callVet() {
    // Implement phone call logic using url_launcher
    print('Calling vet at ${vetPhone.value}');
    Get.snackbar(
      'Calling Vet',
      'Dialing ${vetName.value}...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void cancelVisit() {
    Get.defaultDialog(
      title: 'Cancel Visit?',
      titleStyle: const TextStyle(
        fontFamily: 'Times New Roman',
        fontWeight: FontWeight.bold,
      ),
      middleText: 'Are you sure you want to cancel this visit?',
      middleTextStyle: const TextStyle(fontFamily: 'Times New Roman'),
      textConfirm: 'Yes, Cancel',
      textCancel: 'No',
      confirmTextColor: const Color(0xFFFFFFFF),
      onConfirm: () {
        // Implement cancel logic
        print('Visit cancelled');
        Get.back(); // close dialog
        Get.back(); // go back to previous screen
        Get.snackbar(
          'Cancelled',
          'Visit has been cancelled.',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
}
