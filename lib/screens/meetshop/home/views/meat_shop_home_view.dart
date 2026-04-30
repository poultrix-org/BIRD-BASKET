// screens/meat_shop/home/views/meat_shop_home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/meat_shop_home_controller.dart';

class MeatShopHomeView extends StatelessWidget {
  final MeatShopHomeController controller = Get.put(MeatShopHomeController());

  MeatShopHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meat Shop Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Welcome Header
            Text(
              'Welcome, ${controller.user.shopName}!', // Using Shop Name
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 2. Role Chip
            Chip(
              label: Text(
                controller.user.role,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.brown[700],
            ),
            const SizedBox(height: 24),

            // 3. Shop Details Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.location_on,
                      "Address",
                      controller.user.shopAddress ?? "N/A",
                    ),
                    const Divider(),
                    _buildInfoRow(
                      Icons.map,
                      "Delivery Radius",
                      "${controller.user.deliveryRadius} km",
                    ),
                    const Divider(),
                    _buildInfoRow(
                      Icons.phone,
                      "Contact",
                      controller.user.phone ?? "N/A",
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // 4. Placeholder Action
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.snackbar('Notice', 'Inventory Management coming soon.');
                },
                child: const Text('Manage Inventory'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
