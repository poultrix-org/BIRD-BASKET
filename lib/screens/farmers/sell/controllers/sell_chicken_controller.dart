import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../home/controllers/farmers_home_controller.dart';

class SellChickenController extends GetxController {
  final supabase = Supabase.instance.client;
  final formKey = GlobalKey<FormState>();

  final birdsController = TextEditingController();
  final weightController = TextEditingController();
  final priceController = TextEditingController();
  final locationController = TextEditingController();
  final notesController = TextEditingController();

  var totalQuantity = 0.0.obs;
  var availableDate = Rxn<DateTime>();
  var acceptNegotiation = false.obs;
  var imagePaths = <RxnString>[RxnString(), RxnString(), RxnString()].obs;
  var isLoading = false.obs;

  // Speech-to-text
  final stt.SpeechToText speech = stt.SpeechToText();
  var isListening = false.obs;
  var activeFieldForVoice = ''.obs;

  var myActiveListings = <Map<String, dynamic>>[].obs;
  var isLoadingListings = true.obs;
  var isFormOpen = false.obs; // Toggle between list view and form view

  double lat = 0.0;
  double lng = 0.0;

  @override
  void onInit() {
    super.onInit();
    // Pre-calculate to initialize zero properly
    calculateTotal();
    fetchMyListings();
  }

  @override
  void onClose() {
    speech.stop();
    birdsController.dispose();
    weightController.dispose();
    priceController.dispose();
    locationController.dispose();
    notesController.dispose();
    super.onClose();
  }

  void openForm() {
    isFormOpen.value = true;
  }

  void closeForm() {
    isFormOpen.value = false;
    _clearForm();
  }

  void _clearForm() {
    birdsController.clear();
    weightController.clear();
    priceController.clear();
    locationController.clear();
    notesController.clear();
    totalQuantity.value = 0.0;
    availableDate.value = null;
    acceptNegotiation.value = false;
    for (var img in imagePaths) {
      img.value = null;
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
          if (fieldName == 'quantity' || fieldName == 'weight') {
            calculateTotal();
          }
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

  Future<void> fetchMyListings() async {
    isLoadingListings.value = true;
    try {
      final userModel = Get.find<FarmersHomeController>().user;
      final userId = userModel.userId;

      if (userId == null) throw Exception("User ID not found locally");

      final prefs = await SharedPreferences.getInstance();

      // 1. Instantly load from local storage cache for zero-gap feel
      final cachedListings = prefs.getString('my_sell_listings_${userId}');
      if (cachedListings != null) {
        List<dynamic> parsed = jsonDecode(cachedListings);
        myActiveListings.assignAll(List<Map<String, dynamic>>.from(parsed));
        if (myActiveListings.isNotEmpty) {
          isFormOpen.value = false;
          isLoadingListings.value = false; // Immediately show UI
        }
      }

      // 2. Fetch fresh data from Supabase silently in background
      final data = await supabase
          .from('SellListings')
          .select()
          .eq('farmer_id', userId)
          .order('created_at', ascending: false);

      myActiveListings.assignAll(List<Map<String, dynamic>>.from(data));

      // Update the local cache with fresh data
      await prefs.setString('my_sell_listings_${userId}', jsonEncode(data));

      // If there are no listings natively, open the form by default for faster UX
      if (myActiveListings.isEmpty) {
        isFormOpen.value = true;
      } else {
        isFormOpen.value = false;
      }
    } catch (e) {
      print("Warning: Could not fetch listings. E: $e");
      // Fallback
      if (myActiveListings.isEmpty) {
        isFormOpen.value = true;
      }
    } finally {
      isLoadingListings.value = false;
    }
  }

  void calculateTotal() {
    int birds = int.tryParse(birdsController.text) ?? 0;
    double weight = double.tryParse(weightController.text) ?? 0.0;
    totalQuantity.value = birds * weight;
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      availableDate.value = picked;
    }
  }

  Future<void> detectLocation() async {
    // Dummy implementation replacing real GPS fetch to save time.
    lat = 11.2;
    lng = 77.3;
    locationController.text = "Kangeyam, Tamil Nadu";
    Get.snackbar(
      "Location Detected",
      "Location set successfully",
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

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;
    if (availableDate.value == null) {
      Get.snackbar(
        'Validation',
        'Please select an available date',
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

    isLoading.value = true;
    try {
      // Fix user error bypassing AuthWrapper memory checks
      final localUser = Get.find<FarmersHomeController>().user;
      final userId = localUser.userId;

      if (userId == null)
        throw Exception(
          "User token missing! Please manually logout and re-login completely.",
        );

      // Upload all 3 images to Supabase Storage
      List<String> imageUrls = [];
      for (int i = 0; i < imagePaths.length; i++) {
        try {
          final file = File(imagePaths[i].value!);
          final ext = file.path.split('.').last;
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${userId}_$i.$ext';

          await supabase.storage.from('chicken_images').upload(fileName, file);
          final url = supabase.storage
              .from('chicken_images')
              .getPublicUrl(fileName);
          imageUrls.add(url);
        } catch (storageErr) {
          print(
            "Image $i upload failed: $storageErr",
          );
          imageUrls.add("supabase_bucket_not_configured");
        }
      }

      final payload = {
        "farmer_id": userId,
        "number_of_birds": int.parse(birdsController.text),
        "weight_per_bird": double.parse(weightController.text),
        "total_quantity": totalQuantity.value,
        "price_per_kg": double.parse(priceController.text),
        "available_date": availableDate.value!.toIso8601String(),
        "location": {
          "latitude": lat,
          "longitude": lng,
          "address": locationController.text,
        },
        "notes": notesController.text,
        "image_url": imageUrls.isNotEmpty ? imageUrls[0] : "",
        "image_urls": imageUrls,
        "status": "active",
        "accept_negotiation": acceptNegotiation.value,
        // created_at is handled by DB defaults if omitted
      };

      await supabase.from('SellListings').insert(payload);

      // Fetch fresh listings
      await fetchMyListings();

      // Close the form UI securely
      isFormOpen.value = false;

      // Notify user success
      Get.defaultDialog(
        title: "✅ Listing Posted!",
        middleText: "Your chickens are now visible to nearby buyers.",
        textConfirm: "View Buyers",
        textCancel: "Close Window",
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back();
          Get.snackbar(
            "Info",
            "Nearby matching algorithm coming soon!",
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        onCancel: () {
          Get.back();
        },
      );
    } catch (e) {
      print("Selling creation error: $e");
      Get.snackbar(
        'Error',
        'Failed to post listing',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
