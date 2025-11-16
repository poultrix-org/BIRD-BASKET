// views/role_selection_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/role_selection_controller.dart';

class RoleSelectionView extends StatelessWidget {
  final RoleSelectionController controller = Get.put(RoleSelectionController());

  RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: controller.roles.length,
          itemBuilder: (context, index) {
            final role = controller.roles[index];
            final icon = controller.roleIcons[index];
            return RoleCard(
              icon: icon,
              role: role,
              onTap: () => controller.selectRole(role),
            );
          },
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final IconData icon;
  final String role;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.role,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.brown[700],
            ),
            const SizedBox(height: 16),
            Text(
              role,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}