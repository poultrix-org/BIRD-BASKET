import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../authentications/auths/views/login_view.dart';
import '../../../authentications/role_selections/models/user_models.dart';

class FarmerProfileView extends StatelessWidget {
  final UserModel user;

  const FarmerProfileView({super.key, required this.user});

  void _openLocationPicker(BuildContext context) {
    LatLng initialPos = const LatLng(11.1085, 77.3411); // Default: Tirupur
    if (user.farmGpsLat != null && user.farmGpsLong != null) {
      initialPos = LatLng(
        double.parse(user.farmGpsLat!),
        double.parse(user.farmGpsLong!),
      );
    }

    var selectedPos = initialPos.obs;

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          height: 500,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.teal,
                width: double.infinity,
                child: const Text(
                  'Pin Farm Location (Tirupur)',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Obx(
                  () => GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: initialPos,
                      zoom: 12,
                    ),
                    onTap: (pos) => selectedPos.value = pos,
                    markers: {
                      Marker(
                        markerId: const MarkerId('farm_pin'),
                        position: selectedPos.value,
                      ),
                    },
                    myLocationEnabled: true,
                    zoomControlsEnabled: true,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                        ),
                        onPressed: () => _saveLocation(selectedPos.value),
                        child: const Text("Save Pin"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveLocation(LatLng pos) async {
    Get.back(); // close map
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Colors.teal)),
      barrierDismissible: false,
    );
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({
            'farm_gps_lat': pos.latitude.toString(),
            'farm_gps_long': pos.longitude.toString(),
          })
          .eq('id', user.userId ?? '');

      user.farmGpsLat = pos.latitude.toString();
      user.farmGpsLong = pos.longitude.toString();

      final prefs = await SharedPreferences.getInstance();
      final data = user.toJson();
      data['id'] = user.userId;
      await prefs.setString('user_profile', jsonEncode(data));

      Get.back(); // close loading
      Get.snackbar(
        "Success",
        "Farm GPS location pinned successfully for testing alerts!",
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.teal,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        "Error",
        "Could not save location to Supabase.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontFamily: 'Times New Roman',
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
        backgroundColor: Colors.transparent,

        elevation: 0.5,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Top Avatar Section
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName ?? 'No Name',
              style: const TextStyle(
                fontFamily: 'Times New Roman',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              user.role,
              style: TextStyle(
                fontFamily: 'Times New Roman',
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 30),

            // Profile Details Cards
            _buildProfileSection(
              title: "Personal Information",
              children: [
                _buildInfoTile(
                  icon: Icons.email,
                  label: "Email",
                  value: user.email ?? 'N/A',
                ),
                _buildInfoTile(
                  icon: Icons.phone,
                  label: "Phone Number",
                  value: user.phone ?? 'N/A',
                ),
                _buildInfoTile(
                  icon: Icons.home,
                  label: "Address",
                  value: user.address ?? 'N/A',
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildProfileSection(
              title: "Farm Details",
              children: [
                _buildInfoTile(
                  icon: Icons.location_on,
                  label: "Farm Address",
                  value: user.farmAddress ?? 'N/A',
                ),
                _buildInfoTileWithAction(
                  icon: Icons.map,
                  label: "GPS Location",
                  value: (user.farmGpsLat != null && user.farmGpsLong != null)
                      ? '${double.parse(user.farmGpsLat!).toStringAsFixed(4)}, ${double.parse(user.farmGpsLong!).toStringAsFixed(4)}'
                      : 'Tap to Pin Location',
                  action: () => _openLocationPicker(context),
                  actionIcon: Icons.edit_location_alt,
                  actionColor: Colors.red,
                ),
                _buildInfoTile(
                  icon: Icons.landscape,
                  label: "Shed Size (sq. ft.)",
                  value: user.landSize ?? 'N/A',
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildProfileSection(
              title: "Livestock Details",
              children: [
                _buildInfoTile(
                  icon: Icons.numbers,
                  label: "Number of Birds",
                  value: user.numberOfHens?.toString() ?? 'N/A',
                ),
                _buildInfoTile(
                  icon: Icons.egg_alt,
                  label: "Type of Birds",
                  value: user.typeOfHens ?? 'N/A',
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,

                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () => _handleLogout(context),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Times New Roman',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTileWithAction({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback action,
    required IconData actionIcon,
    required Color actionColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontFamily: 'Times New Roman',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: value == 'Tap to Pin Location'
                              ? Colors.red
                              : Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(actionIcon, color: actionColor),
                      onPressed: action,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Show a small popup to confirm logout
    Get.defaultDialog(
      title: "Log Out",
      middleText: "Are you sure you want to exit your account?",
      textConfirm: "Yes, Log out",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () async {
        Get.back(); // close dialog
        Get.dialog(
          const Center(child: CircularProgressIndicator(color: Colors.white)),
          barrierDismissible: false,
        );

        try {
          // Clear Supabase session and cached preferences
          await Supabase.instance.client.auth.signOut();
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();

          Get.offAll(() => LoginView());
        } catch (e) {
          Get.back(); // close loading
          Get.snackbar("Error", "Could not log out properly.");
        }
      },
    );
  }
}
