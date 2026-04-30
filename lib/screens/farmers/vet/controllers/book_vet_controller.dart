import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../home/controllers/farmers_home_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class BookVetController extends GetxController {
  final supabase = Supabase.instance.client;
  final formKey = GlobalKey<FormState>();

  final descriptionController = TextEditingController();
  final birdsController = TextEditingController();
  final locationController = TextEditingController();

  final issueTypes = [
    'Disease',
    'Low growth',
    'Feeding issue',
    'Vaccination',
    'Emergency',
  ];
  var selectedIssue = RxnString();

  final symptomOptions = [
    'Weakness',
    'Not eating',
    'Breathing issue',
    'Sudden death',
  ];
  var selectedSymptoms = <String>[].obs;

  var visitType = 'Immediate'.obs; // 'Immediate' or 'Schedule'
  var scheduledDate = Rxn<DateTime>();
  var imagePath = RxnString();
  var isLoading = false.obs;

  double lat = 0.0;
  double lng = 0.0;

  void toggleSymptom(String symptom) {
    if (selectedSymptoms.contains(symptom)) {
      selectedSymptoms.remove(symptom);
    } else {
      selectedSymptoms.add(symptom);
    }
  }

  Future<void> detectLocation() async {
    // Dummy GPS logic for now
    lat = 11.2;
    lng = 77.3;
    locationController.text = "Kangeyam, Tamil Nadu";
    Get.snackbar(
      "Location Detected",
      "Farm location set successfully",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (timePicked != null) {
        scheduledDate.value = DateTime(
          picked.year,
          picked.month,
          picked.day,
          timePicked.hour,
          timePicked.minute,
        );
      }
    }
  }

  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      imagePath.value = result.files.single.path!;
    }
  }

  Future<void> submitBooking() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedIssue.value == null) {
      Get.snackbar(
        'Validation',
        'Please select an issue type',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (imagePath.value == null) {
      Get.snackbar(
        'Validation',
        'Please upload a photo to help the vet',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (visitType.value == 'Schedule' && scheduledDate.value == null) {
      Get.snackbar(
        'Validation',
        'Please select a date & time for the scheduled visit',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final userModel = Get.find<FarmersHomeController>().user;
      final userId = userModel.userId;

      if (userId == null) throw Exception("User ID not found");

      String imageUrl = "firebase_storage_link_mock";

      final payload = {
        "farmer_id": userId,
        "vet_id":
            "auto_assign", // in real world, this could be the specific vet you clicked, or a matchmaking queue
        "issue_type": selectedIssue.value,
        "description": descriptionController.text,
        "number_of_birds": int.tryParse(birdsController.text) ?? 0,
        "symptoms": selectedSymptoms.toList(),
        "location": {
          "latitude": lat,
          "longitude": lng,
          "address": locationController.text,
        },
        "image_url": imageUrl,
        "visit_type": visitType.value.toLowerCase(),
        "scheduled_time":
            scheduledDate.value?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        "status": "pending",
      };

      await supabase.from('VetBookings').insert(payload);

      Get.defaultDialog(
        title: "✅ Vet Request Sent!",
        middleText:
            "Dr. Kumar will review your request shortly.\nETA: ~30 minutes.",
        textConfirm: "Track Vet",
        textCancel: "Home",
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back();
          Get.snackbar(
            "Track",
            "Live tracking map coming soon!",
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        onCancel: () => Get.back(),
      );
    } catch (e) {
      print("Vet Booking error: $e");
      Get.snackbar(
        'Error',
        'Failed to book vet visit',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
