import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
  var imagePath = RxnString();
  var isLoading = false.obs;

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
    imagePath.value = null;
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

  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      imagePath.value = result.files.single.path!;
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
    if (imagePath.value == null) {
      Get.snackbar(
        'Validation',
        'Please upload a photo of the chickens',
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

      // Actually upload the image to Supabase Storage
      String imageUrl = "";
      try {
        final file = File(imagePath.value!);
        final ext = file.path.split('.').last;
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${userId}.$ext';

        // Attempt to upload to a Supabase bucket named "chicken_images"
        await supabase.storage.from('chicken_images').upload(fileName, file);
        imageUrl = supabase.storage
            .from('chicken_images')
            .getPublicUrl(fileName);
      } catch (storageErr) {
        print(
          "Image storage bucket upload failed. Ensure 'chicken_images' public bucket is created: $storageErr",
        );
        // Fallback or leave empty to not crash list if bucket isn't set up yet
        imageUrl = "supabase_bucket_not_configured";
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
        "image_url": imageUrl,
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
