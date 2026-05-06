import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../home/controllers/farmers_home_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
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
  var imagePaths = <RxnString>[RxnString(), RxnString(), RxnString()].obs;
  var isLoading = false.obs;
  var paymentMode = 'pay_later'.obs; // 'pay_now' or 'pay_later'

  // Speech-to-text
  final stt.SpeechToText speech = stt.SpeechToText();
  var isListening = false.obs;
  var activeFieldForVoice = ''.obs; // which field mic is for

  double lat = 0.0;
  double lng = 0.0;

  void toggleSymptom(String symptom) {
    if (selectedSymptoms.contains(symptom)) {
      selectedSymptoms.remove(symptom);
    } else {
      selectedSymptoms.add(symptom);
    }
  }

  Future<void> startListening(String fieldName, TextEditingController textController) async {
    bool available = await speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          isListening.value = false;
          activeFieldForVoice.value = '';
        }
      },
      onError: (error) {
        isListening.value = false;
        activeFieldForVoice.value = '';
      },
    );

    if (available) {
      isListening.value = true;
      activeFieldForVoice.value = fieldName;
      speech.listen(
        onResult: (result) {
          textController.text = result.recognizedWords;
        },
        listenFor: const Duration(seconds: 15),
        localeId: 'en_IN',
      );
    } else {
      Get.snackbar(
        'Mic Unavailable',
        'Speech recognition is not available on this device',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void stopListening() {
    speech.stop();
    isListening.value = false;
    activeFieldForVoice.value = '';
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

  Future<void> pickImage(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      imagePaths[index].value = result.files.single.path!;
      imagePaths.refresh();
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
    final missingImages = imagePaths.where((img) => img.value == null).length;
    if (missingImages > 0) {
      Get.snackbar(
        'Validation',
        'Please upload all 3 chicken photos',
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

      List<String> imageUrls = [];
      for (int i = 0; i < imagePaths.length; i++) {
        try {
          final file = File(imagePaths[i].value!);
          final ext = file.path.split('.').last;
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${userId}_vet_$i.$ext';
          await supabase.storage.from('chicken_images').upload(fileName, file);
          final url = supabase.storage
              .from('chicken_images')
              .getPublicUrl(fileName);
          imageUrls.add(url);
        } catch (e) {
          print("Vet image $i upload failed: $e");
          imageUrls.add("upload_failed");
        }
      }

      final payload = {
        "farmer_id": userId,
        "vet_id": "auto_assign",
        "issue_type": selectedIssue.value,
        "description": descriptionController.text,
        "number_of_birds": int.tryParse(birdsController.text) ?? 0,
        "symptoms": selectedSymptoms.toList(),
        "location": {
          "latitude": lat,
          "longitude": lng,
          "address": locationController.text,
        },
        "image_url": imageUrls.isNotEmpty ? imageUrls[0] : "",
        "image_urls": imageUrls,
        "visit_type": visitType.value.toLowerCase(),
        "scheduled_time":
            scheduledDate.value?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        "payment_mode": paymentMode.value,
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

  @override
  void onClose() {
    speech.stop();
    descriptionController.dispose();
    birdsController.dispose();
    locationController.dispose();
    super.onClose();
  }
}
