import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../home/controllers/farmers_home_controller.dart';

class VetBookingsController extends GetxController {
  final supabase = Supabase.instance.client;
  var isLoading = false.obs;

  var liveBookings = <Map<String, dynamic>>[].obs;
  var completedBookings = <Map<String, dynamic>>[].obs;
  var cancelledBookings = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    isLoading.value = true;
    try {
      final userId = Get.find<FarmersHomeController>().user.userId;
      if (userId == null) return;

      final live = <Map<String, dynamic>>[];
      final completed = <Map<String, dynamic>>[];
      final cancelled = <Map<String, dynamic>>[];

      // Fetch Vaccination Bookings
      try {
        final vacRes = await supabase
            .from('VaccinationBookings')
            .select()
            .eq('farmer_id', userId)
            .order('created_at', ascending: false);
        
        for (var item in vacRes) {
          final status = item['status'] ?? 'scheduled';
          final booking = {
            'type': 'vaccination',
            'title': 'Vaccination: ${item['vaccination_type'] ?? 'Unknown'}',
            'subtitle': 'Bird Type: ${item['bird_type'] ?? 'Unknown'}',
            'date': item['preferred_date']?.toString() ?? '',
            'farm_name': item['farm_name'] ?? '',
            'total_birds': item['total_birds']?.toString() ?? '',
            'bird_age': item['bird_age'] ?? '',
            'notes': item['notes'] ?? '',
            'image_urls': item['image_urls'] ?? [],
          };
          if (status == 'scheduled' || status == 'pending') {
            live.add(booking);
          } else if (status == 'completed') {
            completed.add(booking);
          } else {
            cancelled.add(booking);
          }
        }
      } catch (e) {
        print('Error fetching VaccinationBookings: $e');
      }

      // Fetch Emergency/Vet Bookings
      try {
        final vetRes = await supabase
            .from('VetBookings')
            .select()
            .eq('farmer_id', userId)
            .order('created_at', ascending: false);

        for (var item in vetRes) {
          final status = item['status'] ?? 'pending';
          final booking = {
            'type': 'emergency',
            'title': 'Vet Request: ${item['issue_type'] ?? 'Unknown'}',
            'subtitle': '${item['emergency_level'] ?? 'Normal'} Priority',
            'date': item['created_at']?.toString().split('T')[0] ?? '',
            'description': item['description'] ?? '',
            'symptoms': (item['symptoms'] as List?)?.join(', ') ?? '',
            'image_urls': item['image_urls'] ?? (item['image_url'] != null ? [item['image_url']] : []),
          };
          if (status == 'pending' || status == 'accepted') {
            live.add(booking);
          } else if (status == 'completed') {
            completed.add(booking);
          } else {
            cancelled.add(booking);
          }
        }
      } catch (e) {
        print('Error fetching VetBookings: $e');
      }

      liveBookings.value = live;
      completedBookings.value = completed;
      cancelledBookings.value = cancelled;
    } catch (e) {
      print('Error in fetchBookings: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
