import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/farmer_alert_model.dart';
import '../../home/controllers/farmers_home_controller.dart';

class AlertsController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Map Data
  var mapMarkers = <Marker>{}.obs;
  var mapCircles = <Circle>{}.obs;
  var currentPosition = Rx<Position?>(null);

  // Farm Location
  var farmLocation = Rx<LatLng?>(null);

  // Data list
  var alertsList = <FarmerAlertModel>[].obs;
  var isLoading = true.obs;
  var isSubmitting = false.obs;

  // Filter state
  var mapFilter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFarmLocation();
    _initializeMap();
  }

  void _loadFarmLocation() {
    try {
      final homeController = Get.find<FarmersHomeController>();
      if (homeController.user.farmGpsLat != null &&
          homeController.user.farmGpsLong != null) {
        double lat = double.parse(homeController.user.farmGpsLat!);
        double lng = double.parse(homeController.user.farmGpsLong!);
        farmLocation.value = LatLng(lat, lng);
        _updateFarmPin();
      }
    } catch (e) {
      print('Could not load farm location: $e');
    }
  }

  void _updateFarmPin() {
    if (farmLocation.value != null) {
      var currentMarkers = mapMarkers.toList();
      // Remove any existing home pin
      currentMarkers.removeWhere(
        (m) => m.markerId == const MarkerId('my_farm_location'),
      );

      // Add new home pin
      currentMarkers.add(
        Marker(
          markerId: const MarkerId('my_farm_location'),
          position: farmLocation.value!,
          infoWindow: const InfoWindow(title: 'My Farm Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueCyan,
          ), // Unique color for your farm
          zIndex: 10,
        ),
      );

      mapMarkers.assignAll(currentMarkers);
    }
  }

  Future<void> _initializeMap() async {
    isLoading.value = true;
    await _getUserLocation();
    await fetchAlerts();
    isLoading.value = false;
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    currentPosition.value = await Geolocator.getCurrentPosition();
  }

  Future<void> fetchAlerts() async {
    try {
      final response = await _supabase
          .from('farmer_alerts')
          .select()
          .order('created_at', ascending: false);

      alertsList.value = (response as List)
          .map((data) => FarmerAlertModel.fromJson(data))
          .toList();

      _buildMapLayers();
    } catch (e) {
      print('Error fetching alerts: $e');
    }
  }

  void _buildMapLayers() {
    Set<Marker> markers = {};
    Set<Circle> circles = {};

    Map<String, int> coordCounts = {};

    for (var alert in alertsList) {
      // Validate filter
      if (mapFilter.value == 'Disease' && alert.type != 'disease') continue;
      if (mapFilter.value == 'Other Issues' && alert.type != 'general')
        continue;

      // Duplicate coord offset logic
      String coordKey =
          "${alert.latitude.toStringAsFixed(4)}_${alert.longitude.toStringAsFixed(4)}";
      int offsetIndex = coordCounts[coordKey] ?? 0;
      coordCounts[coordKey] = offsetIndex + 1;

      // Offset by slightly shifting the marker so they don't perfectly overlap
      double offsetLat = alert.latitude + (offsetIndex * 0.005);
      double offsetLng = alert.longitude + (offsetIndex * 0.005);

      Color baseColor;
      if (alert.severity == 'high') {
        baseColor = Colors.red;
      } else if (alert.severity == 'medium') {
        baseColor = Colors.orange;
      } else {
        baseColor = Colors.green;
      }

      LatLng position = LatLng(offsetLat, offsetLng);

      markers.add(
        Marker(
          markerId: MarkerId(alert.id),
          position: position,
          infoWindow: InfoWindow(
            title: alert.type == 'disease'
                ? 'Disease: ${alert.title}'
                : 'Alert: ${alert.title}',
            snippet: 'Tap marker or circle to view details',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            alert.severity == 'high'
                ? BitmapDescriptor.hueRed
                : (alert.severity == 'medium'
                      ? BitmapDescriptor.hueOrange
                      : BitmapDescriptor.hueGreen),
          ),
        ),
      );

      circles.add(
        Circle(
          circleId: CircleId(alert.id),
          center: position,
          radius:
              alert.radius *
              1000, // stored in KM in DB, need radius in meters for Map
          fillColor: baseColor.withValues(alpha: 0.3),
          strokeColor: baseColor,
          strokeWidth: 2,
          consumeTapEvents: true,
          onTap: () => showAlertDetails(alert),
        ),
      );
    }

    mapMarkers.assignAll(markers);
    mapCircles.assignAll(circles);

    // Add your farm pin back on top
    _updateFarmPin();
  }

  void setFilter(String filter) {
    if (mapFilter.value != filter) {
      mapFilter.value = filter;
      _buildMapLayers(); // Re-render the map instantly securely overlapping logic
    }
  }

  // View Details
  void showAlertDetails(FarmerAlertModel alert) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    alert.type == 'disease'
                        ? Icons.coronavirus
                        : Icons.warning_amber_rounded,
                    color: alert.severity == 'high'
                        ? Colors.red
                        : (alert.severity == 'medium'
                              ? Colors.orange
                              : Colors.green),
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      alert.title,
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (alert.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    alert.category!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Divider(height: 30),

              if (alert.imageUrl != null && alert.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    alert.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              if (alert.imageUrl != null && alert.imageUrl!.isNotEmpty)
                const SizedBox(height: 16),

              const Text(
                'Description:',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                alert.description,
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),

              if (alert.symptoms != null && alert.symptoms!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Symptoms:',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: alert.symptoms!
                          .map(
                            (s) => Chip(
                              label: Text(
                                s,
                                style: const TextStyle(fontSize: 12),
                              ),
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.red.shade50,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              if (alert.birdsAffected != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Birds Affected: ${alert.birdsAffected}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),

              Row(
                children: [
                  const Icon(Icons.radar, color: Colors.grey, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Affected Radius: ${alert.radius.toStringAsFixed(1)} KM',
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.grey, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Reported on: ${alert.createdAt.toLocal().toString().split(".")[0]}',
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Add Alert Flow
  void showAddAlertDialog() {
    double? farmLat = farmLocation.value?.latitude;
    double? farmLng = farmLocation.value?.longitude;

    if (farmLat == null || farmLng == null) {
      if (currentPosition.value == null) {
        Get.snackbar(
          'Location Required',
          'Farm Location not set in profile. Auto-detecting failed.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      farmLat = currentPosition.value!.latitude;
      farmLng = currentPosition.value!.longitude;
    }

    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final radiusCtrl = TextEditingController(text: '5');
    final birdsCtrl = TextEditingController();

    var selectedType = 'disease'.obs;
    var selectedSeverity = 'medium'.obs;
    var selectedCategory = Rx<String?>(null);
    var selectedSymptoms = <String>[].obs;
    var selectedImagePath = Rx<String?>(null);

    final diseaseTypes = [
      'Bird Flu (Avian Influenza)',
      'Newcastle Disease',
      'Coccidiosis',
      'Fowl Pox',
      'Unknown Disease',
    ];
    final generalTypes = [
      'Weather Alert',
      'Feed Shortage',
      'Market Issue',
      'Transport Problem',
      'Price Drop',
      'Other',
    ];
    final symptomOptions = [
      'Not eating',
      'Weakness',
      'Breathing issue',
      'Sudden death',
      'Diarrhea',
      'Swelling',
      'Drop in egg production',
    ];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Report Local Incident',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'The alert will be pinned to your registered farm location.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),

              // Type selector
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => RadioListTile<String>(
                        title: const Text(
                          'Disease',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: 'disease',
                        groupValue: selectedType.value,
                        activeColor: Colors.red,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          selectedType.value = val!;
                          selectedCategory.value = null; // reset
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Obx(
                      () => RadioListTile<String>(
                        title: const Text(
                          'Other Issues',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: 'general',
                        groupValue: selectedType.value,
                        activeColor: Colors.orange,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          selectedType.value = val!;
                          selectedCategory.value = null; // reset
                        },
                      ),
                    ),
                  ),
                ],
              ),

              Obx(
                () => DropdownButtonFormField<String>(
                  isExpanded: true,
                  hint: Text(
                    selectedType.value == 'disease'
                        ? 'Select Disease Type'
                        : 'Select Alert Category',
                  ),
                  value: selectedCategory.value,
                  items:
                      (selectedType.value == 'disease'
                              ? diseaseTypes
                              : generalTypes)
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (val) => selectedCategory.value = val,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Severity Level',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: ['low', 'medium', 'high']
                    .map(
                      (sev) => Expanded(
                        child: Obx(
                          () => RadioListTile<String>(
                            title: Text(
                              sev.capitalizeFirst!,
                              style: const TextStyle(fontSize: 12),
                            ),
                            value: sev,
                            groupValue: selectedSeverity.value,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) => selectedSeverity.value = val!,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: radiusCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Affected Radius (in KM)',
                  border: OutlineInputBorder(),
                  suffixText: 'km',
                ),
              ),
              const SizedBox(height: 16),

              Obx(() {
                if (selectedType.value == 'disease') {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Symptoms Observed:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 0,
                        children: symptomOptions
                            .map(
                              (symptom) => Obx(() {
                                final isSelected = selectedSymptoms.contains(
                                  symptom,
                                );
                                return FilterChip(
                                  label: Text(
                                    symptom,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected)
                                      selectedSymptoms.add(symptom);
                                    else
                                      selectedSymptoms.remove(symptom);
                                  },
                                );
                              }),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: birdsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Number of Birds Affected',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),

              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Image Picker
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectedImagePath.value != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(selectedImagePath.value!),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => selectedImagePath.value = null,
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text(
                              'Remove',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      )
                    else
                      OutlinedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: Text(
                          selectedType.value == 'disease'
                              ? 'Upload Photo (Required)'
                              : 'Upload Photo (Optional)',
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(type: FileType.image);
                          if (result != null) {
                            selectedImagePath.value = result.files.single.path;
                          }
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    onPressed: isSubmitting.value
                        ? null
                        : () {
                            if (selectedType.value == 'disease' &&
                                selectedImagePath.value == null) {
                              Get.snackbar(
                                'Photo Required',
                                'Photo evidence is required for disease alerts.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }
                            _submitAlert(
                              title: titleCtrl.text,
                              desc: descCtrl.text,
                              type: selectedType.value,
                              category: selectedCategory.value,
                              severity: selectedSeverity.value,
                              radiusKmStr: radiusCtrl.text,
                              birdsAffected: birdsCtrl.text,
                              symptoms: selectedSymptoms.toList(),
                              imagePath: selectedImagePath.value,
                              latitude: farmLat!,
                              longitude: farmLng!,
                            );
                          },
                    child: isSubmitting.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Broadcast Alert',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _submitAlert({
    required String title,
    required String desc,
    required String type,
    String? category,
    required String severity,
    required String radiusKmStr,
    String? birdsAffected,
    List<String>? symptoms,
    String? imagePath,
    required double latitude,
    required double longitude,
  }) async {
    if (title.isEmpty || desc.isEmpty || category == null) {
      Get.snackbar(
        'Missing Info',
        'Title, category, and description are required.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSubmitting.value = true;

      String farmerId = '';
      try {
        final homeController = Get.find<FarmersHomeController>();
        farmerId = homeController.user.userId ?? 'anonymous_farmer';
      } catch (e) {
        farmerId = 'anonymous_farmer';
      }

      double radiusKm = double.tryParse(radiusKmStr) ?? 5.0;
      int? birds = int.tryParse(birdsAffected ?? '');

      String? uploadedImageUrl;

      if (imagePath != null) {
        final File file = File(imagePath);
        final ext = file.path.split('.').last;
        final fileName = '${const Uuid().v4()}.$ext';

        try {
          await _supabase.storage.from('alert_images').upload(fileName, file);
          uploadedImageUrl = _supabase.storage
              .from('alert_images')
              .getPublicUrl(fileName);
        } catch (e) {
          print('Storage upload failed: $e');
        }
      }

      final newAlert = FarmerAlertModel(
        id: const Uuid().v4(),
        farmerId: farmerId,
        type: type,
        category: category,
        title: title,
        severity: severity,
        description: desc,
        symptoms: symptoms,
        birdsAffected: birds,
        latitude: latitude,
        longitude: longitude,
        radius: radiusKm,
        imageUrl: uploadedImageUrl,
        createdAt: DateTime.now(),
      );

      try {
        await _supabase.from('farmer_alerts').insert(newAlert.toJson());
      } catch (dbError) {
        print('Could not insert to DB: $dbError');
      }

      alertsList.insert(0, newAlert);
      _buildMapLayers();

      Get.back();
      Get.snackbar(
        'Alert Broadcasted',
        'Your alert is now visible to nearby farmers.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to broadcast alert: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
