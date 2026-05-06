import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrackVetController extends GetxController {
  final supabase = Supabase.instance.client;

  var vetName = 'Dr. Sharma'.obs;
  var vetRating = '4.8'.obs;
  var vetPhone = '+91 9876543210'.obs;
  var vetETA = '15 mins'.obs;
  var vetDistanceStr = '2.5 km'.obs;

  // Statuses: 0 = Booking Confirmed, 1 = Vet Assigned, 2 = On the Way, 3 = Arrived
  var currentStatus = 0.obs;
  var statusText = 'Booking Confirmed'.obs;

  // Maps & Location
  var farmerLat = 0.0.obs;
  var farmerLng = 0.0.obs;
  var vetLat = 0.0.obs;
  var vetLng = 0.0.obs;

  late String bookingId;
  late bool isDummy;
  Timer? _movementTimer;
  Timer? _dbSyncTimer;

  Completer<GoogleMapController> mapController = Completer();
  var markers = <Marker>{}.obs;

  // Raw data for bottom sheet
  var fullVetData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeTracking();
  }

  void _initializeTracking() {
    // Get arguments passed from previous screen
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      bookingId = args['booking_id'];
      isDummy = args['is_dummy'];
      farmerLat.value = args['farmer_lat'];
      farmerLng.value = args['farmer_lng'];

      final vetData = args['vet_data'];
      fullVetData.value = vetData;
      vetName.value = vetData['name'];
      vetRating.value = vetData['rating'].toString();
      vetLat.value = vetData['latitude'];
      vetLng.value = vetData['longitude'];
      vetDistanceStr.value = '${(vetData['distance'] as double).toStringAsFixed(1)} km';
    }

    _updateMarkers();

    // Start Simulation sequence
    _simulateWorkflow();
  }

  void _simulateWorkflow() async {
    // 0 -> 1
    await Future.delayed(const Duration(seconds: 2));
    currentStatus.value = 1;
    statusText.value = 'Vet Assigned: ${vetName.value}';

    // 1 -> 2
    await Future.delayed(const Duration(seconds: 2));
    currentStatus.value = 2;
    statusText.value = 'On the Way';
    _startMovementSimulation();
    
    if (!isDummy) {
      _startDbSync();
    }
  }

  void _startMovementSimulation() {
    // Move vet towards farmer slightly every 2 seconds
    _movementTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (currentStatus.value >= 3) {
        timer.cancel();
        return;
      }

      double latDiff = farmerLat.value - vetLat.value;
      double lngDiff = farmerLng.value - vetLng.value;

      // Simple interpolation
      vetLat.value += latDiff * 0.1;
      vetLng.value += lngDiff * 0.1;

      // Check arrival
      if (latDiff.abs() < 0.001 && lngDiff.abs() < 0.001) {
        currentStatus.value = 3;
        statusText.value = 'Arrived at Farm';
        vetETA.value = 'Arrived';
        vetDistanceStr.value = '0.0 km';
        if (!isDummy) _updateDbStatus('arrived');
        timer.cancel();
      } else {
        // Update ETA string roughly
        int fakeMins = (latDiff.abs() * 1000).toInt();
        vetETA.value = '${fakeMins > 0 ? fakeMins : 1} mins';
      }

      _updateMarkers();
      _animateMapToVet();
    });
  }

  void _startDbSync() {
    _dbSyncTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (currentStatus.value >= 3) {
        timer.cancel();
        return;
      }
      try {
        await supabase.from('vet_bookings').update({
          'status': 'on_the_way',
          'latitude': vetLat.value,
          'longitude': vetLng.value,
        }).eq('booking_id', bookingId);
      } catch (e) {
        print("Sync error: $e");
      }
    });
  }

  Future<void> _updateDbStatus(String status) async {
    try {
      await supabase.from('vet_bookings').update({
        'status': status,
      }).eq('booking_id', bookingId);
    } catch (e) {
      print("Status update error: $e");
    }
  }

  void Function()? onVetMarkerTapped;

  void _updateMarkers() {
    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId('farmer'),
        position: LatLng(farmerLat.value, farmerLng.value),
        infoWindow: const InfoWindow(title: 'Your Farm'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
    markers.add(
      Marker(
        markerId: const MarkerId('vet'),
        position: LatLng(vetLat.value, vetLng.value),
        infoWindow: InfoWindow(title: vetName.value),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        onTap: onVetMarkerTapped,
      ),
    );
  }

  Future<void> _animateMapToVet() async {
    if (!mapController.isCompleted) return;
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newLatLng(LatLng(vetLat.value, vetLng.value)));
  }

  void callVet() {
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
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: 'Are you sure you want to cancel this visit?',
      textConfirm: 'Yes, Cancel',
      textCancel: 'No',
      confirmTextColor: const Color(0xFFFFFFFF),
      onConfirm: () async {
        if (!isDummy) {
          await _updateDbStatus('cancelled');
        }
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

  @override
  void onClose() {
    _movementTimer?.cancel();
    _dbSyncTimer?.cancel();
    super.onClose();
  }
}
