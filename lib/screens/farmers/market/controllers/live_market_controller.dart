import 'dart:convert';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/market_rate_model.dart';
import '../models/disease_alert_model.dart';

class LiveMarketController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // States
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Location
  var currentPosition = Rx<Position?>(null);
  var locationName = 'Locating...'.obs;
  var lastUpdatedTime = ''.obs;

  // Data
  var nearestRate = Rx<MarketRateModel?>(null);
  var previousRate = Rx<MarketRateModel?>(null);
  var nearbyAlerts = <DiseaseAlertModel>[].obs;

  // Map Markers
  var mapMarkers = <Marker>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCachedData();
    refreshMarketData();
  }

  Future<void> refreshMarketData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // 1. Get user location
      await _getUserLocation();

      if (currentPosition.value == null) {
        throw Exception("Could not fetch location");
      }

      // 2. Fetch data from Supabase
      await fetchMarketRates();
      await fetchNearbyAlerts();

      // 3. Update Markers
      _updateMapMarkers();

      // 4. Update Time & Cache
      lastUpdatedTime.value = _formatTime(DateTime.now());
      _cacheData();
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    currentPosition.value = await Geolocator.getCurrentPosition();
  }

  Future<void> fetchMarketRates() async {
    // Fetch last 30 rates to find nearest. In large scale apps, consider PostGIS plugin or Supabase Edge Functions for geo-queries.
    final response = await _supabase
        .from('market_rates')
        .select()
        .order('created_at', ascending: false)
        .limit(50);

    List<MarketRateModel> allRates = (response as List)
        .map((data) => MarketRateModel.fromJson(data))
        .toList();

    if (allRates.isEmpty) return;

    // Haversine sorting to find nearest
    allRates.sort((a, b) {
      double distA = calculateDistance(
        currentPosition.value!.latitude,
        currentPosition.value!.longitude,
        a.latitude,
        a.longitude,
      );
      double distB = calculateDistance(
        currentPosition.value!.latitude,
        currentPosition.value!.longitude,
        b.latitude,
        b.longitude,
      );
      return distA.compareTo(distB);
    });

    MarketRateModel closest = allRates.first;
    nearestRate.value = closest;
    locationName.value = closest.locationName;

    // Find previous rate for the same location to calculate trend
    try {
      final prevResponse = await _supabase
          .from('market_rates')
          .select()
          .eq('location_name', closest.locationName)
          .lt('created_at', closest.createdAt.toIso8601String())
          .order('created_at', ascending: false)
          .limit(1);

      if ((prevResponse as List).isNotEmpty) {
        previousRate.value = MarketRateModel.fromJson(prevResponse[0]);
      }
    } catch (e) {
      // Ignored if no previous data found
    }
  }

  Future<void> fetchNearbyAlerts() async {
    final response = await _supabase
        .from('disease_alerts')
        .select()
        .order('created_at', ascending: false)
        .limit(50);

    List<DiseaseAlertModel> allAlerts = (response as List)
        .map((data) => DiseaseAlertModel.fromJson(data))
        .toList();

    // Filter within 50km
    nearbyAlerts.value = allAlerts.where((alert) {
      double distance = calculateDistance(
        currentPosition.value!.latitude,
        currentPosition.value!.longitude,
        alert.latitude,
        alert.longitude,
      );
      return distance <= 50.0; // 50 km radius
    }).toList();
  }

  void _updateMapMarkers() {
    Set<Marker> markers = {};

    // 1. User Location
    if (currentPosition.value != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(
            currentPosition.value!.latitude,
            currentPosition.value!.longitude,
          ),
          infoWindow: const InfoWindow(title: 'Your Farm'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    // 2. Disease Alerts
    for (var alert in nearbyAlerts) {
      double hue = BitmapDescriptor.hueGreen;
      if (alert.severity == 'high') hue = BitmapDescriptor.hueRed;
      if (alert.severity == 'medium') hue = BitmapDescriptor.hueOrange;

      markers.add(
        Marker(
          markerId: MarkerId(alert.alertId),
          position: LatLng(alert.latitude, alert.longitude),
          infoWindow: InfoWindow(
            title: alert.title,
            snippet: alert.severity.toUpperCase(),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        ),
      );
    }

    mapMarkers.value = markers;
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295; // Math.PI / 180
    var c = math.cos;
    var a =
        0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 *
        math.asin(math.sqrt(a)); // 2 * R * asin, Earth Radius R = 6371 km
  }

  // --- Caching Logic ---
  Future<void> _cacheData() async {
    final prefs = await SharedPreferences.getInstance();
    if (nearestRate.value != null) {
      await prefs.setString(
        'cached_market_rate',
        jsonEncode(nearestRate.value!.toJson()),
      );
      await prefs.setString('cached_location', locationName.value);
      await prefs.setString('cached_time', lastUpdatedTime.value);
    }
  }

  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedRate = prefs.getString('cached_market_rate');
    if (cachedRate != null) {
      nearestRate.value = MarketRateModel.fromJson(jsonDecode(cachedRate));
      locationName.value = prefs.getString('cached_location') ?? 'Unknown';
      lastUpdatedTime.value = prefs.getString('cached_time') ?? '';
    }
  }

  String _formatTime(DateTime time) {
    int hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    String ampm = time.hour >= 12 ? "PM" : "AM";
    String min = time.minute.toString().padLeft(2, '0');
    return "$hour:$min $ampm";
  }
}
