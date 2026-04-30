import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controllers/alerts_controller.dart';

class AlertsView extends StatelessWidget {
  final AlertsController controller = Get.put(AlertsController());

  AlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Global Disease Radar',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: const Color(0xFF1B5E20),
          ),
        ),
        backgroundColor: Colors.transparent,

        elevation: 0,
      ),
      body: Stack(
        children: [
          // Full Screen Google Map Container
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Obx(() {
              // Ensure map reacts to farm location updates
              LatLng? farmPosition = controller.farmLocation.value;
              bool loading = controller.isLoading.value;

              if (loading &&
                  farmPosition == null &&
                  controller.currentPosition.value == null) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.teal),
                );
              }

              // Default location if currentPosition is missing
              LatLng initPos = const LatLng(11.0168, 76.9558);

              // Prioritize user's own farm location
              if (farmPosition != null) {
                initPos = farmPosition;
              } else if (controller.currentPosition.value != null) {
                initPos = LatLng(
                  controller.currentPosition.value!.latitude,
                  controller.currentPosition.value!.longitude,
                );
              }

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initPos,
                  zoom: 13, // Good zoom to see local city
                ),
                markers: controller.mapMarkers.toSet(),
                circles: controller.mapCircles.toSet(),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
              );
            }),
          ),

          // Map Filters
          Positioned(
            top:
                MediaQuery.of(context).padding.top +
                AppBar().preferredSize.height +
                10,
            left: 16,
            right: 16,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(
                () => Row(
                  children: [
                    ...['All', 'Disease', 'Other Issues'].map((filter) {
                      final bool isSelected =
                          controller.mapFilter.value == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ActionChip(
                          label: Text(
                            filter,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          backgroundColor: Colors.transparent,
                          disabledColor: Colors.white,
                          color: WidgetStatePropertyAll(
                            isSelected ? Colors.teal : Colors.white,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.teal
                                  : Colors.grey.shade300,
                            ),
                          ),
                          onPressed: () => controller.setFilter(filter),
                        ),
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: ElevatedButton.icon(
                        onPressed: () => controller.showAddAlertDialog(),
                        icon: const Icon(Icons.add_alert, size: 16),
                        label: const Text(
                          'Report',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SF Pro Display',
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,

                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
