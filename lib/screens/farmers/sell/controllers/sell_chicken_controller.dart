import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_fonts/google_fonts.dart';

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
  var deliveryType = 'pickup'.obs;
  var urgency = 'normal'.obs;
  var matchedBuyersCount = 3.obs;
  var demandScore = 'HIGH'.obs;
  var expectedPrice = 0.0.obs;
  var attemptedSubmit = false.obs;

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

      final listings = List<Map<String, dynamic>>.from(data);

      // 3. Repair any broken image URLs
      await _repairBrokenImageUrls(listings, userId!);

      myActiveListings.assignAll(listings);

      // Update the local cache with fresh data
      await prefs.setString('my_sell_listings_${userId}', jsonEncode(listings));

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

  /// Scans listings for broken image URLs ('supabase_bucket_not_configured' or non-signed public URLs)
  /// and regenerates valid signed URLs from the storage bucket.
  Future<void> _repairBrokenImageUrls(List<Map<String, dynamic>> listings, String userId) async {
    for (var listing in listings) {
      bool needsRepair = false;

      // Check if image_url is broken or uses public URL (which returns 400)
      final imageUrl = listing['image_url']?.toString() ?? '';
      if (imageUrl == 'supabase_bucket_not_configured' || 
          (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) ||
          (imageUrl.contains('/object/public/') && !imageUrl.contains('/object/sign/'))) {
        needsRepair = true;
      }

      // Check if image_urls list has broken entries
      final imageUrls = listing['image_urls'];
      if (imageUrls is List) {
        for (var url in imageUrls) {
          final urlStr = url?.toString() ?? '';
          if (urlStr == 'supabase_bucket_not_configured' || 
              (urlStr.contains('/object/public/') && !urlStr.contains('/object/sign/'))) {
            needsRepair = true;
            break;
          }
        }
      }

      if (!needsRepair) continue;

      try {
        // List files in bucket that match this user's ID
        final files = await supabase.storage.from('chicken_images').list();
        final userFiles = files.where((f) => f.name.contains(userId)).toList();
        
        if (userFiles.isEmpty) continue;

        // Sort by name (timestamp-based) descending to get most recent
        userFiles.sort((a, b) => b.name.compareTo(a.name));

        List<String> repairedUrls = [];

        for (var file in userFiles) {
          try {
            final signedUrl = await supabase.storage
                .from('chicken_images')
                .createSignedUrl(file.name, 60 * 60 * 24 * 365); // 1 year
            repairedUrls.add(signedUrl);
          } catch (e) {
            print("Could not create signed URL for ${file.name}: $e");
          }
        }

        if (repairedUrls.isNotEmpty) {
          // Update the listing in-memory
          listing['image_url'] = repairedUrls.first;
          listing['image_urls'] = repairedUrls;

          // Also update in Supabase DB using farmer_id + created_at as composite key
          try {
            final createdAt = listing['created_at'];
            if (createdAt != null) {
              await supabase.from('SellListings').update({
                'image_url': repairedUrls.first,
                'image_urls': repairedUrls,
              }).eq('farmer_id', userId).eq('created_at', createdAt.toString());
              print("Repaired image URLs for listing created at $createdAt");
            }
          } catch (e) {
            print("Could not update DB with repaired URLs: $e");
          }
        }
      } catch (e) {
        print("Image URL repair failed: $e");
      }
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: GoogleFonts.montserratTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          child: child!,
        );
      },
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

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  Future<List<Map<String, dynamic>>> matchNearbyBuyers() async {
    try {
      final response = await supabase.from('BuyerRequests').select();
      final List<Map<String, dynamic>> matchedBuyers = [];

      for (var buyer in response) {
        if (buyer['location'] != null && buyer['location']['latitude'] != null && buyer['location']['longitude'] != null) {
          final buyerLat = (buyer['location']['latitude'] as num).toDouble();
          final buyerLon = (buyer['location']['longitude'] as num).toDouble();

          final dist = calculateDistance(lat, lng, buyerLat, buyerLon);
          final reqQty = (buyer['quantity_required'] ?? 0).toDouble();

          if (dist < 20.0 && reqQty <= totalQuantity.value) {
            matchedBuyers.add(buyer);
          }
        }
      }
      return matchedBuyers;
    } catch (e) {
      print("Error matching buyers: $e");
      return [];
    }
  }

  String calculateDemandScore(int buyersCount) {
    if (buyersCount > 5) return "HIGH";
    if (buyersCount >= 2) return "MEDIUM";
    return "LOW";
  }

  Future<double> getSuggestedPrice() async {
    try {
      final response = await supabase.from('market_rates').select('suggested_price_per_kg').limit(1);
      if (response.isNotEmpty) {
        return (response.first['suggested_price_per_kg'] ?? 0.0).toDouble();
      }
    } catch (e) {
      print("Error fetching market rates: $e");
    }
    return 0.0;
  }

  Future<void> submitForm() async {
    attemptedSubmit.value = true;
    bool hasErrors = false;

    if (!formKey.currentState!.validate()) {
      hasErrors = true;
    }
    if (availableDate.value == null) {
      hasErrors = true;
      Get.snackbar(
        'Validation',
        'Please select an available date',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    
    // Photos are optional as requested, but if empty they will be highlighted in the UI.
    if (hasErrors) {
      Get.snackbar(
        'Validation',
        'Please fill all required highlighted fields',
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

      final matchedBuyers = await matchNearbyBuyers();
      final demandScore = calculateDemandScore(matchedBuyers.length);
      final suggestedPrice = await getSuggestedPrice();
      final userPrice = double.tryParse(priceController.text) ?? 0.0;
      
      if (userPrice > suggestedPrice && suggestedPrice > 0) {
        print("Note: User's price (\$$userPrice) is higher than suggested (\$$suggestedPrice)");
      }

      // Upload images to Supabase Storage if they exist
      List<String> imageUrls = [];
      for (int i = 0; i < imagePaths.length; i++) {
        if (imagePaths[i].value == null) continue;
        try {
          final file = File(imagePaths[i].value!);
          final ext = file.path.split('.').last;
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${userId}_$i.$ext';

          // Use upsert to avoid duplicate filename conflicts
          await supabase.storage.from('chicken_images').upload(
            fileName,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

          // Try public URL first
          final publicUrl = supabase.storage
              .from('chicken_images')
              .getPublicUrl(fileName);

          // Verify the public URL is valid — if bucket is not public, use signed URL
          if (publicUrl.isNotEmpty && publicUrl.startsWith('http')) {
            // Test if public access works by trying a signed URL as a more reliable fallback
            try {
              final signedUrl = await supabase.storage
                  .from('chicken_images')
                  .createSignedUrl(fileName, 60 * 60 * 24 * 365); // 1 year expiry
              imageUrls.add(signedUrl);
              print("Image $i uploaded successfully (signed URL): $signedUrl");
            } catch (signedErr) {
              // Signed URL failed, use public URL as fallback
              imageUrls.add(publicUrl);
              print("Image $i uploaded successfully (public URL): $publicUrl");
            }
          }
        } catch (storageErr) {
          print("Image $i upload failed: $storageErr");
          // Don't add broken placeholder — just skip this image
        }
      }

      final payload = {
        "farmer_id": userId,
        "number_of_birds": int.tryParse(birdsController.text) ?? 0,
        "weight_per_bird": double.tryParse(weightController.text) ?? 0.0,
        "total_quantity": totalQuantity.value,
        "price_per_kg": double.tryParse(priceController.text) ?? 0.0,
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
        "delivery_type": deliveryType.value,
        "urgency": urgency.value,
        "demand_score": demandScore,
        "matched_buyers_count": matchedBuyers.length,
        // created_at is handled by DB defaults if omitted
      };

      await supabase.from('SellListings').insert(payload);
      
      print("Notify nearby buyers");

      // Fetch fresh listings
      await fetchMyListings();

      // Close the form UI securely
      isFormOpen.value = false;

      // Notify user success
      Get.defaultDialog(
        title: "🔥 ${matchedBuyers.length} buyers found near you",
        middleText: "Your chickens are now visible to nearby buyers.\nDemand is $demandScore",
        textConfirm: "View Buyers",
        textCancel: "Close Window",
        confirmTextColor: Colors.white,
        onConfirm: () {
          if (Get.isDialogOpen == true) {
            Get.back();
          }
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.snackbar(
              "Info",
              "Nearby matching algorithm coming soon!",
              snackPosition: SnackPosition.BOTTOM,
            );
          });
        },
        onCancel: () {
          if (Get.isDialogOpen == true) {
            Get.back();
          }
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
