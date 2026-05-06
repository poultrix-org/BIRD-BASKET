import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../home/controllers/farmers_home_controller.dart';
import '../views/track_vet_view.dart';

class VetHomeController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = true.obs;
  var isLocationLoading = true.obs;
  var farmerLat = 0.0.obs;
  var farmerLng = 0.0.obs;
  var nearbyVets = <Map<String, dynamic>>[].obs;
  var isDummyMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // 1. Immediately show UI and load fallback/cached vets
    isLocationLoading.value = false;
    _useFallbackLocation();
    _loadDummyVets(); // Show something instantly
    
    // 2. Fetch real data from Supabase using fallback location first (optional, but good for speed)
    fetchNearbyVets();

    // 3. Silently fetch actual GPS location in the background
    _fetchRealLocationSilently();
  }

  Future<void> _fetchRealLocationSilently() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Location Required', 
          'Please turn on location services for accurate nearby doctors.',
          duration: const Duration(seconds: 4),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Location Required', 'Location permissions are needed to find nearby vets.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Location Required', 'Location permissions are permanently denied. Please enable them in settings.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      farmerLat.value = position.latitude;
      farmerLng.value = position.longitude;

      // 4. Once we have the real location, re-fetch the vets precisely
      fetchNearbyVets();
    } catch (e) {
      print("Error getting background location: $e");
    }
  }

  Future<void> getUserLocation() async {
    // Keeping this method around just in case it's called explicitly
    await _fetchRealLocationSilently();
  }

  void _useFallbackLocation() {
    // Default fallback to a central location if GPS fails
    farmerLat.value = 11.0168; // Coimbatore area approx
    farmerLng.value = 76.9558;
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth's radius in km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }

  Future<void> fetchNearbyVets() async {
    isLoading.value = true;
    try {
      final List<dynamic> response = await supabase
          .from('vets')
          .select()
          .eq('available', true);

      if (response.isEmpty) {
        _loadDummyVets();
      } else {
        isDummyMode.value = false;
        List<Map<String, dynamic>> processedVets = [];
        
        for (var vet in response) {
          double vLat = vet['latitude']?.toDouble() ?? 0.0;
          double vLng = vet['longitude']?.toDouble() ?? 0.0;
          double distance = calculateDistance(farmerLat.value, farmerLng.value, vLat, vLng);
          
          if (distance <= 20.0) { // Within 20km
            processedVets.add({
              'vet_id': vet['vet_id'],
              'name': vet['name'],
              'rating': vet['rating']?.toDouble() ?? 0.0,
              'experience_years': vet['experience_years'] ?? 0,
              'latitude': vLat,
              'longitude': vLng,
              'distance': distance,
            });
          }
        }
        
        processedVets.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
        nearbyVets.assignAll(processedVets);
      }
    } catch (e) {
      print("Error fetching vets from Supabase: $e");
      _loadDummyVets();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadDummyVets() {
    isDummyMode.value = true;
    // Load some hardcoded vets near the fallback location
    nearbyVets.assignAll([
      {
        'vet_id': 'dummy-1',
        'name': 'Dr. Sharma (Mock)',
        'rating': 4.8,
        'experience_years': 10,
        'latitude': farmerLat.value + 0.02,
        'longitude': farmerLng.value + 0.02,
        'distance': 2.5,
      },
      {
        'vet_id': 'dummy-2',
        'name': 'Dr. Verma (Mock)',
        'rating': 4.6,
        'experience_years': 7,
        'latitude': farmerLat.value - 0.04,
        'longitude': farmerLng.value + 0.01,
        'distance': 5.1,
      },
      {
        'vet_id': 'dummy-3',
        'name': 'Dr. Reddy (Mock)',
        'rating': 4.9,
        'experience_years': 15,
        'latitude': farmerLat.value + 0.05,
        'longitude': farmerLng.value - 0.06,
        'distance': 8.0,
      },
    ]);
  }

  Future<void> assignNearestVet() async {
    if (nearbyVets.isEmpty) {
      Get.snackbar('Unavailable', 'No vets are currently available nearby.');
      return;
    }
    // Assumes list is already sorted by distance
    final nearestVet = nearbyVets.first;
    await bookVet(nearestVet['vet_id'], nearestVet);
  }

  Future<void> bookVet(String vetId, Map<String, dynamic> vetData) async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    
    try {
      if (!isDummyMode.value) {
        final userModel = Get.find<FarmersHomeController>().user;
        final farmerId = userModel.userId;
        
        if (farmerId != null) {
          final bookingPayload = {
            'farmer_id': farmerId,
            'vet_id': vetId,
            'status': 'booked',
            'latitude': farmerLat.value,
            'longitude': farmerLng.value,
          };
          
          final bookingResponse = await supabase.from('vet_bookings').insert(bookingPayload).select().single();
          String bookingId = bookingResponse['booking_id'];
          
          Get.back(); // close dialog
          Get.to(() => TrackVetView(), arguments: {
            'booking_id': bookingId,
            'vet_data': vetData,
            'is_dummy': false,
            'farmer_lat': farmerLat.value,
            'farmer_lng': farmerLng.value,
          });
          return;
        }
      }
      
      // Fallback or Dummy Mode behavior
      await Future.delayed(const Duration(seconds: 1)); // simulate network delay
      Get.back(); // close dialog
      Get.to(() => TrackVetView(), arguments: {
        'booking_id': 'dummy-booking-id',
        'vet_data': vetData,
        'is_dummy': true,
        'farmer_lat': farmerLat.value,
        'farmer_lng': farmerLng.value,
      });

    } catch (e) {
      print("Error creating booking: $e");
      Get.back(); // close dialog
      Get.snackbar('Error', 'Failed to create booking.');
    }
  }
}
