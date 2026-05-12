import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/vet_home_controller.dart';
import 'emergency_booking_view.dart';
import 'vaccination_booking_view.dart';
import 'vet_bookings_view.dart';

class VetHomeView extends StatelessWidget {
  final VetHomeController controller = Get.put(VetHomeController());

  VetHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // ── Sticky AppBar matching Sell Your Chickens style ──
      appBar: AppBar(
        title: Text(
          'Veterinary Services',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: const Color(0xFF1B5E20),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF1B5E20)),
        actions: [
          TextButton.icon(
            onPressed: () => Get.to(() => VetBookingsView()),
            icon: const Icon(Icons.history, color: Color(0xFF1B5E20), size: 16),
            label: Text(
              'Bookings',
              style: GoogleFonts.montserrat(
                color: const Color(0xFF1B5E20),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Obx(
            () => controller.isLoading.value
                ? const LinearProgressIndicator(
                    color: Color(0xFF1B5E20),
                    backgroundColor: Colors.transparent,
                    minHeight: 2,
                  )
                : const SizedBox(height: 2),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Emergency Support + chips ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Emergency Support Card (notification style) ──
                  GestureDetector(
                    onTap: () => Get.to(() => EmergencyBookingView()),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9B0F06),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFD1B3F5), width: 1),
                      ),
                      child: Row(
                        children: [
                          // Icon circle
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7F2020),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          // Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '🚨 Emergency Support',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Vet responds in ~5 mins',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Button
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'BOOK NOW',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Vaccination Booking Card (notification style) ──
                  GestureDetector(
                    onTap: () => Get.to(() => VaccinationBookingView()),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC5D89D),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFD4CC9E), width: 1),
                      ),
                      child: Row(
                        children: [
                          // Icon circle
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B3C53),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: const Center(
                              child: Text('💉', style: TextStyle(fontSize: 22)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vaccination Booking',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Schedule & get reminders',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Button
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'BOOK NOW',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Nearby Section Title with Refresh on right ──
                  Row(
                    children: [
                      Text(
                        'Nearby Vets (30 KM)',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: const Color(0xFF1B5E20),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => controller.fetchNearbyVets(),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B5E20).withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.refresh_rounded, color: Color(0xFF1B5E20), size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // ── Loading indicator moved to AppBar ──

          // ── Doctors List ──
          Obx(() {
            final vets = controller.nearbyVets;

            if (!controller.isLoading.value && vets.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.person_search, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'No vets found nearby.',
                          style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try refreshing or expanding the area.',
                          style: GoogleFonts.montserrat(color: Colors.grey.shade400, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildDoctorListTile(context, vets[index]),
                  childCount: vets.length,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDoctorListTile(BuildContext context, Map<String, dynamic> vet) {
    final bool isAvailable = vet['available'] == true || vet['available'] == null;
    final double rating = (vet['rating'] as num?)?.toDouble() ?? 0.0;
    final double distance = (vet['distance'] as num?)?.toDouble() ?? 0.0;
    final int expYears = (vet['experience_years'] as num?)?.toInt() ?? 0;

    return GestureDetector(
      onTap: () => _showDoctorDetailsSheet(context, vet),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFAF6),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: avatar + info ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rounded square avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEADBFC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.person_rounded, size: 38, color: Color(0xFF6A3FA0)),
                ),
                const SizedBox(width: 14),
                // Name + details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              vet['name'] ?? 'Unknown Vet',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isAvailable ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isAvailable ? '● Available' : '● Busy',
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isAvailable ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$expYears years of experience',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            rating.toStringAsFixed(1),
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.location_on_rounded, color: Colors.red.shade300, size: 13),
                          const SizedBox(width: 2),
                          Text(
                            '${distance.toStringAsFixed(1)} km away',
                            style: GoogleFonts.montserrat(fontSize: 12, color: Colors.black45),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 12),

            // ── Bottom row: two action buttons ──
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.snackbar(
                        '📞 Calling...',
                        'Connecting you to ${vet['name']}',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF1B5E20),
                        colorText: Colors.white,
                        borderRadius: 12,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.call_rounded, color: Colors.white, size: 15),
                          const SizedBox(width: 6),
                          Text(
                            'Call',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showDoctorDetailsSheet(context, vet),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.video_call_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'video call',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDoctorDetailsSheet(BuildContext context, Map<String, dynamic> vet) {
    final bool isAvailable = vet['available'] == true || vet['available'] == null;
    final double rating = (vet['rating'] as num?)?.toDouble() ?? 0.0;
    final double distance = (vet['distance'] as num?)?.toDouble() ?? 0.0;
    final int expYears = (vet['experience_years'] as num?)?.toInt() ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Header: avatar + info + X button ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rounded square avatar (matches list tile)
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEADBFC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.person_rounded, size: 42, color: Color(0xFF6A3FA0)),
                  ),
                  const SizedBox(width: 14),
                  // Name + subtitle + badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vet['name'] ?? 'Unknown Vet',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Poultry & Livestock Expert',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isAvailable
                                  ? const Color(0xFFA5D6A7)
                                  : const Color(0xFFEF9A9A),
                            ),
                          ),
                          child: Text(
                            isAvailable ? '● Available Now' : '● Currently Busy',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isAvailable
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFC62828),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // X Close button
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded, size: 18, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Stat pills ──
              Row(
                children: [
                  _statPill(Icons.star_rounded, '${rating.toStringAsFixed(1)} Rating', Colors.amber),
                  const SizedBox(width: 8),
                  _statPill(Icons.location_on_rounded, '${distance.toStringAsFixed(1)} km', const Color(0xFFE53935)),
                  const SizedBox(width: 8),
                  _statPill(Icons.work_outline_rounded, '$expYears yrs', const Color(0xFF1B5E20)),
                ],
              ),

              const SizedBox(height: 20),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 16),

              // ── Info rows ──
              _infoRow(Icons.verified_rounded, 'Speciality', 'Poultry & Livestock'),
              _infoRow(Icons.access_time_rounded, 'Response Time', '~5 minutes'),
              _infoRow(Icons.language_rounded, 'Languages', 'Tamil, English'),
              _infoRow(Icons.currency_rupee_rounded, 'Fee', '₹200 (Pay after acceptance)'),

              const SizedBox(height: 24),

              // ── Action buttons ──
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.call_rounded, size: 18),
                      label: Text(
                        'Call',
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Get.back();
                        Get.snackbar(
                          '📞 Calling...',
                          'Connecting you to ${vet['name']}',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF1B5E20),
                          colorText: Colors.white,
                          borderRadius: 12,
                          margin: const EdgeInsets.all(16),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.videocam_rounded, size: 18),
                      label: Text(
                        'Video Call',
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1B5E20),
                        side: const BorderSide(color: Color(0xFF1B5E20), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () {
                        Get.back();
                        Get.snackbar(
                          '📹 Starting Video Call...',
                          'Connecting you to ${vet['name']}',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.blue.shade700,
                          colorText: Colors.white,
                          borderRadius: 12,
                          margin: const EdgeInsets.all(16),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statPill(IconData icon, String label, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFFF6FFDC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD4ECA0)),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 5),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1B5E20).withValues(alpha: 0.5), size: 18),
          const SizedBox(width: 10),
          Text(
            '$title:',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
