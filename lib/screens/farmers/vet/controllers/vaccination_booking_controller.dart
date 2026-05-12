import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../home/controllers/farmers_home_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'vet_bookings_controller.dart';
class VaccinationBookingController extends GetxController {
  final supabase = Supabase.instance.client;
  final formKey = GlobalKey<FormState>();

  // ── Text Controllers ──
  final farmNameController = TextEditingController();
  final birdTypeController = TextEditingController();
  final totalBirdsController = TextEditingController();
  final birdAgeController = TextEditingController();
  final addressController = TextEditingController();
  final notesController = TextEditingController();

  // ── Vaccination Type ──
  final vaccinationTypes = [
    'Newcastle Disease',
    'Gumboro',
    'Marek\'s Disease',
    'Fowl Pox',
    'Booster Dose',
    'Deworming',
    'Vitamin Support',
    'Custom',
  ];
  var selectedVaccinationType = RxnString();

  // ── Schedule ──
  var preferredDate = Rxn<DateTime>();
  var preferredTime = Rxn<TimeOfDay>();


  // ── Reminder ──
  var reminderEnabled = true.obs;

  // ── Location ──
  var isLocating = false.obs;
  double lat = 0.0;
  double lng = 0.0;

  // ── Submission ──
  var isLoading = false.obs;
  var attemptedSubmit = false.obs;
  var imagePaths = <RxnString>[RxnString(), RxnString(), RxnString()].obs;

  Future<void> pickImage(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      imagePaths[index].value = result.files.single.path!;
      imagePaths.refresh();
    }
  }

  Future<void> detectLocation() async {
    isLocating.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Location', 'Please enable location services.',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      final position = await Geolocator.getCurrentPosition();
      lat = position.latitude;
      lng = position.longitude;
      addressController.text = 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';
      Get.snackbar('Location Detected', 'Farm location saved.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1B5E20),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Could not detect location.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLocating.value = false;
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1B5E20)),
        ),
        child: child!,
      ),
    );
    if (picked != null) preferredDate.value = picked;
  }

  Future<void> pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1B5E20)),
        ),
        child: child!,
      ),
    );
    if (picked != null) preferredTime.value = picked;
  }

  Future<void> submitBooking() async {
    attemptedSubmit.value = true;
    if (!formKey.currentState!.validate()) return;
    if (selectedVaccinationType.value == null) {
      Get.snackbar('Validation', 'Please select a vaccination type.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (preferredDate.value == null) {
      Get.snackbar('Validation', 'Please select a preferred date.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    if (imagePaths.any((path) => path.value == null)) {
      Get.snackbar('Validation', 'Please upload all 3 photos.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final userModel = Get.find<FarmersHomeController>().user;
      final userId = userModel.userId;
      if (userId == null) throw Exception('User ID not found');

      final preferredTimeStr = preferredTime.value != null
          ? '${preferredTime.value!.hour.toString().padLeft(2, '0')}:${preferredTime.value!.minute.toString().padLeft(2, '0')}'
          : null;

      // ── Upload Images ──
      List<Future<String?>> uploadTasks = [];
      for (int i = 0; i < imagePaths.length; i++) {
        if (imagePaths[i].value != null) {
          uploadTasks.add((() async {
            try {
              final file = File(imagePaths[i].value!);
              final ext = file.path.split('.').last;
              final fileName = '${DateTime.now().millisecondsSinceEpoch}_${userId}_vac_$i.$ext';
              await supabase.storage.from('vacinationbooking_images').upload(fileName, file);
              return supabase.storage.from('vacinationbooking_images').getPublicUrl(fileName);
            } catch (e) {
              print("Vac image $i upload failed: $e");
              return null;
            }
          })());
        }
      }
      final results = await Future.wait(uploadTasks);
      List<String> imageUrls = results.whereType<String>().toList();

      // ── Calculate next due date (3 months from preferred date) ──
      final nextDueDate = preferredDate.value!.add(const Duration(days: 90));

      final payload = {
        'farmer_id': userId,
        'farm_name': farmNameController.text.trim(),
        'bird_type': birdTypeController.text.trim(),
        'total_birds': int.tryParse(totalBirdsController.text) ?? 0,
        'bird_age': birdAgeController.text.trim(),
        'vaccination_type': selectedVaccinationType.value,
        'preferred_date': preferredDate.value!.toIso8601String().split('T')[0],
        'preferred_time': preferredTimeStr,
        'consultation_type': 'Farm Visit',
        'latitude': lat,
        'longitude': lng,
        'address': addressController.text.trim(),
        'reminder_enabled': reminderEnabled.value,
        'notes': notesController.text.trim(),
        'status': 'scheduled',
        'image_urls': imageUrls,
      };

      try {
        await supabase.from('VaccinationBookings').insert(payload);
      } catch (e) {
        print('VaccinationBookings insert warning: $e');
      }

      // ── Save to health history ──
      try {
        await supabase.from('VaccinationHistory').insert({
          'farmer_id': userId,
          'farm_name': farmNameController.text.trim(),
          'bird_type': birdTypeController.text.trim(),
          'vaccination_type': selectedVaccinationType.value,
          'vaccination_date': preferredDate.value!.toIso8601String().split('T')[0],
          'next_due_date': reminderEnabled.value ? nextDueDate.toIso8601String().split('T')[0] : null,
          'notes': notesController.text.trim(),
        });
      } catch (e) {
        print('VaccinationHistory insert warning: $e');
      }

      // ── Refresh Bookings History ──
      try {
        if (!Get.isRegistered<VetBookingsController>()) {
          Get.put(VetBookingsController(), permanent: true);
        }
        Get.find<VetBookingsController>().fetchBookings();
      } catch (e) {
        print('History refresh warning: $e');
      }

      isLoading.value = false;
      _showSuccessDialog(nextDueDate);
    } catch (e) {
      isLoading.value = false;
      print('Vaccination booking error: $e');
      Get.snackbar('Error', 'Failed to schedule vaccination. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showSuccessDialog(DateTime nextDue) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF1B5E20), size: 48),
              ),
              const SizedBox(height: 16),
              Text(
                'Vaccination Scheduled!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your vaccination booking has been confirmed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              if (reminderEnabled.value) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '🔔 Next dose reminder: ${nextDue.day}/${nextDue.month}/${nextDue.year}',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // Force dismissing the dialog AND the current screen
                    Get.close(2);
                  },
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onClose() {
    farmNameController.dispose();
    birdTypeController.dispose();
    totalBirdsController.dispose();
    birdAgeController.dispose();
    addressController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
