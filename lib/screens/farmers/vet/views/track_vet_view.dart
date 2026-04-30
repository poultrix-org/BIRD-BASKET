import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/track_vet_controller.dart';

class TrackVetView extends StatelessWidget {
  final TrackVetController controller = Get.put(TrackVetController());

  TrackVetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Track Vet',
          style: TextStyle(
            fontFamily: 'Times New Roman',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,

        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Dummy Map Container
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey.shade300,
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.map, size: 80, color: Colors.grey),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.white,

                      onPressed: () {},
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trip Status',
                    style: TextStyle(
                      fontFamily: 'Times New Roman',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTrackerStep('Booking Confirmed', 0),
                  _buildTrackerStep(
                    'Vet Assigned: ${controller.vetName.value}',
                    1,
                  ),
                  _buildTrackerStep(
                    'On the Way (ETA: ${controller.vetETA.value})',
                    2,
                  ),
                  _buildTrackerStep('Arrived at Farm', 3),

                  const SizedBox(height: 32),
                  const Text(
                    'Vet Details',
                    style: TextStyle(
                      fontFamily: 'Times New Roman',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Vet Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.teal.shade100,
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.vetName.value,
                                    style: const TextStyle(
                                      fontFamily: 'Times New Roman',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.orange,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${controller.vetRating.value} Rating',
                                        style: const TextStyle(
                                          fontFamily: 'Times New Roman',
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.phone, color: Colors.teal),
                              onPressed: () => controller.callVet(),
                            ),
                          ],
                        ),
                        const Divider(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.call, color: Colors.teal),
                              label: const Text(
                                'Call',
                                style: TextStyle(
                                  fontFamily: 'Times New Roman',
                                  color: Colors.teal,
                                ),
                              ),
                              onPressed: () => controller.callVet(),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              label: const Text(
                                'Cancel Visit',
                                style: TextStyle(
                                  fontFamily: 'Times New Roman',
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
          ],
        ),
      ),
    );
  }

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
        color = Colors.green;
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
                  color: isCompleted ? Colors.green : Colors.grey.shade300,
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
                  fontFamily: 'Times New Roman',
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
}
