import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/track_vet_controller.dart';

class TrackVetView extends StatelessWidget {
  final TrackVetController controller = Get.put(TrackVetController());

  TrackVetView({super.key}) {
    controller.onVetMarkerTapped = () {
      if (controller.fullVetData.isNotEmpty) {
        _showVetDetailsBottomSheet(controller.fullVetData);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Track Vet',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF1B5E20)),
      ),
      body: Column(
        children: [
          // Real Google Map Container
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Obx(
              () => GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(controller.farmerLat.value, controller.farmerLng.value),
                  zoom: 14.0,
                ),
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                markers: controller.markers.toSet(),
                onMapCreated: (GoogleMapController mapCtrl) {
                  controller.mapController.complete(mapCtrl);
                },
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trip Status',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTrackerStep('Booking Confirmed', 0),
                  Obx(() => _buildTrackerStep(
                      currentStatusValue() >= 1 ? 'Vet Assigned: ${controller.vetName.value}' : 'Assigning Vet...',
                      1,
                    )),
                  Obx(() => _buildTrackerStep(
                      currentStatusValue() >= 2 ? 'On the Way (ETA: ${controller.vetETA.value})' : 'Waiting for Departure...',
                      2,
                    )),
                  _buildTrackerStep('Arrived at Farm', 3),

                  const SizedBox(height: 32),
                  const Text(
                    'Vet Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Vet Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: const Color(0xFF1B5E20).withValues(alpha: 0.1),
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(() => Text(
                                        controller.vetName.value,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.orange,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Obx(() => Text(
                                            '${controller.vetRating.value} Rating',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.phone, color: Color(0xFF1B5E20)),
                              onPressed: () => controller.callVet(),
                            ),
                          ],
                        ),
                        const Divider(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.call, color: Color(0xFF1B5E20)),
                              label: const Text(
                                'Call',
                                style: TextStyle(
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                              onPressed: () => controller.callVet(),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.chat, color: Color(0xFF1B5E20)),
                              label: const Text(
                                'Chat',
                                style: TextStyle(
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                              onPressed: () {
                                Get.snackbar(
                                  'Chat',
                                  'Opening chat with ${controller.vetName.value}...',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              label: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                              onPressed: () => controller.cancelVisit(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int currentStatusValue() => controller.currentStatus.value;

  Widget _buildTrackerStep(String title, int stepIndex) {
    return Obx(() {
      final currentStatus = controller.currentStatus.value;
      final isCompleted = stepIndex < currentStatus;
      final isActive = stepIndex == currentStatus;
      final isLast = stepIndex == 3;

      Color color = Colors.grey.shade400;
      if (isActive && stepIndex == 2) {
        color = Colors.orange; // Pulsing orange for on the way
      } else if (isCompleted || isActive) {
        color = const Color(0xFF1B5E20);
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isCompleted || isActive) ? color : Colors.white,
                  border: Border.all(color: color, width: 2),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: isCompleted ? const Color(0xFF1B5E20) : Colors.grey.shade300,
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: isActive ? 2.0 : 4.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isActive ? 16 : 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? color
                      : (isCompleted ? Colors.black87 : Colors.grey),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  void _showVetDetailsBottomSheet(Map<String, dynamic> vet) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF1B5E20).withValues(alpha: 0.1),
                  child: const Icon(Icons.person, size: 36, color: Color(0xFF1B5E20)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vet['name'] ?? 'Unknown Vet',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${vet['rating']}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Doctor Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.work, 'Experience', '${vet['experience_years']} Years'),
            _buildDetailRow(Icons.location_on, 'Distance', '${(vet['distance'] as double).toStringAsFixed(1)} km away'),
            _buildDetailRow(Icons.verified, 'Speciality', 'Poultry & Livestock Expert'),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade500, size: 20),
          const SizedBox(width: 12),
          Text(
            '$title:',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
