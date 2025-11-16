// views/farmers_home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/farmers_home_controller.dart';

class FarmersHomeView extends StatelessWidget {
  final FarmersHomeController controller = Get.put(FarmersHomeController());

  FarmersHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Farmer Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${controller.user.fullName}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(
                controller.user.role,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.brown[700],
            ),
            const SizedBox(height: 24),
            const Text(
              'This is your farmer home screen. More features coming soon.',
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Not functional as per requirement
                  Get.snackbar('Notice', 'Edit Profile is not yet implemented.');
                },
                child: const Text('Edit Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}