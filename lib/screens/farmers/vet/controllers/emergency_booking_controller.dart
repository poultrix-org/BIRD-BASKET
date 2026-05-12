import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../home/controllers/farmers_home_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../vet/views/track_vet_view.dart';

class EmergencyBookingController extends GetxController {
  final supabase = Supabase.instance.client;
  final formKey = GlobalKey<FormState>();

  final descriptionController = TextEditingController();
  final birdsController = TextEditingController();
  final affectedBirdsController = TextEditingController();
  final locationController = TextEditingController();

  final issueTypes = [
    'Disease',
    'Low growth',
    'Feeding issue',
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

  var consultationType = 'Emergency Farm Visit'.obs;
  var emergencyLevel = 'Medium'.obs;
  var imagePaths = <RxnString>[RxnString(), RxnString(), RxnString()].obs;
  var isLoading = false.obs;
  var isSearchingVets = false.obs;
  var attemptedSubmit = false.obs;

  // Audio Recording
  final AudioRecorder audioRecorder = AudioRecorder();
  var isRecording = false.obs;
  var audioFilePath = RxnString();

  // Mock Nearby Vets
  var nearbyVets = <Map<String, dynamic>>[].obs;

  double lat = 0.0;
  double lng = 0.0;

  @override
  void onInit() {
    super.onInit();
    fetchNearbyVets();
  }

  void fetchNearbyVets() {
    nearbyVets.value = [
      {
        "name": "Dr. Kumar",
        "rating": 4.8,
        "distance": "2 km",
        "response": "5 mins",
        "available": true,
        "image": "assets/images/user.png"
      },
      {
        "name": "Dr. Ravi",
        "rating": 4.6,
        "distance": "5 km",
        "response": "8 mins",
        "available": true,
        "image": "assets/images/user.png"
      },
      {
        "name": "Dr. Anjali",
        "rating": 4.9,
        "distance": "8 km",
        "response": "12 mins",
        "available": false,
        "image": "assets/images/user.png"
      },
    ];
  }

  void toggleSymptom(String symptom) {
    if (selectedSymptoms.contains(symptom)) {
      selectedSymptoms.remove(symptom);
    } else {
      selectedSymptoms.add(symptom);
    }
  }

  Future<void> startRecording() async {
    try {
      if (await audioRecorder.hasPermission()) {
        final Directory tempDir = await getTemporaryDirectory();
        final String path = '${tempDir.path}/vet_audio_desc_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await audioRecorder.start(const RecordConfig(), path: path);
        isRecording.value = true;
      } else {
        Get.snackbar(
          'Permission Denied',
          'Microphone permission is required to record voice description.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Error starting record: $e");
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await audioRecorder.stop();
      isRecording.value = false;
      if (path != null) {
        audioFilePath.value = path;
      }
    } catch (e) {
      print("Error stopping record: $e");
    }
  }

  void discardRecording() {
    audioFilePath.value = null;
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

  Future<void> pickImage(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      imagePaths[index].value = result.files.single.path!;
      imagePaths.refresh();
    }
  }

  Future<void> broadcastVetRequest() async {
    attemptedSubmit.value = true;
    if (!formKey.currentState!.validate()) return;
    if (selectedIssue.value == null) {
      Get.snackbar(
        'Validation',
        'Please select an issue type',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    if (imagePaths.any((path) => path.value == null)) {
      Get.snackbar(
        'Validation',
        'Please upload all 3 photos.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSearchingVets.value = true;
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
          await supabase.storage.from('emergencybooking_images').upload(fileName, file);
          final url = supabase.storage
              .from('emergencybooking_images')
              .getPublicUrl(fileName);
          imageUrls.add(url);
        } catch (e) {
          print("Vet image $i upload failed: $e");
          imageUrls.add("upload_failed");
        }
      }

      String audioUrl = "";
      if (audioFilePath.value != null) {
        try {
          final file = File(audioFilePath.value!);
          final ext = file.path.split('.').last;
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${userId}_audio.$ext';
          await supabase.storage.from('emergencybooking_images').upload(fileName, file);
          audioUrl = supabase.storage
              .from('emergencybooking_images')
              .getPublicUrl(fileName);
        } catch (e) {
          print("Audio upload failed: $e");
        }
      }

      final payload = {
        "farmer_id": userId,
        "vet_id": "auto_assign",
        "issue_type": selectedIssue.value,
        "description": descriptionController.text,
        "number_of_birds": int.tryParse(birdsController.text) ?? 0,
        "affected_birds_count": int.tryParse(affectedBirdsController.text) ?? 0,
        "symptoms": selectedSymptoms.toList(),
        "location": {
          "latitude": lat,
          "longitude": lng,
          "address": locationController.text,
        },
        "image_url": imageUrls.isNotEmpty ? imageUrls[0] : "",
        "image_urls": imageUrls,
        "audio_url": audioUrl,
        "consultation_type": consultationType.value,
        "emergency_level": emergencyLevel.value,
        "payment_mode": "pay_later",
        "status": "pending",
      };

      try {
        await supabase.from('VetBookings').insert(payload);
      } catch (e) {
        print("Supabase insert warning (check table schema): $e");
      }

      // Simulate waiting for vet to accept
      await Future.delayed(const Duration(seconds: 4));

      Get.back(); // close loading dialog if open
      Get.off(() => TrackVetView(), arguments: {
        'booking_id': 'MOCK_${DateTime.now().millisecondsSinceEpoch}',
        'is_dummy': true,
        'farmer_lat': lat,
        'farmer_lng': lng,
        'vet_data': {
          'name': 'Dr. Kumar',
          'rating': 4.8,
          'latitude': lat + 0.05,
          'longitude': lng + 0.05,
          'distance': 5.2,
          'experience_years': 8,
        }
      });
      Get.snackbar(
        "Request Accepted!",
        "Dr. Kumar has accepted your emergency request.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Vet Booking error: $e");
      Get.snackbar(
        'Error',
        'Failed to broadcast request',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSearchingVets.value = false;
    }
  }

  @override
  void onClose() {
    audioRecorder.dispose();
    descriptionController.dispose();
    birdsController.dispose();
    affectedBirdsController.dispose();
    locationController.dispose();
    super.onClose();
  }
}
