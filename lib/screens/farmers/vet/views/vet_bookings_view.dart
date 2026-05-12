import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/vet_bookings_controller.dart';

class VetBookingsView extends StatelessWidget {
  final VetBookingsController controller = Get.put(VetBookingsController());

  VetBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Your Bookings',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: const Color(0xFF1B5E20),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF1B5E20)),
          bottom: TabBar(
            indicatorColor: const Color(0xFF1B5E20),
            labelColor: const Color(0xFF1B5E20),
            unselectedLabelColor: Colors.grey,
            labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Live'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookingsList(context, 'Live Bookings', Icons.timer, controller.liveBookings),
            _buildBookingsList(context, 'Completed Bookings', Icons.check_circle, controller.completedBookings),
            _buildBookingsList(context, 'Cancelled Bookings', Icons.cancel, controller.cancelledBookings),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(BuildContext context, String status, IconData icon, RxList<Map<String, dynamic>> list) {
    return Obx(() {
      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No $status found.',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final booking = list[index];
          final type = booking['type'];

          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B5E20).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: const Color(0xFF1B5E20)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking['title'] ?? 'Booking',
                              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Date: ${booking['date']}',
                              style: GoogleFonts.montserrat(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Color(0xFFE2E4DA), thickness: 1),
                  ),
                  if (type == 'vaccination') ...[
                    _buildDetailRow('Farm', booking['farm_name']?.toString().isNotEmpty == true ? booking['farm_name'] : 'N/A'),
                    _buildDetailRow('Bird Type', booking['subtitle']?.replaceAll('Bird Type: ', '') ?? 'N/A'),
                    _buildDetailRow('Total Birds', booking['total_birds']?.toString().isNotEmpty == true ? booking['total_birds'] : 'N/A'),
                    _buildDetailRow('Bird Age', booking['bird_age']?.toString().isNotEmpty == true ? booking['bird_age'] : 'N/A'),
                    if ((booking['notes'] ?? '').toString().isNotEmpty)
                      _buildDetailRow('Notes', booking['notes']),
                  ] else if (type == 'emergency') ...[
                    _buildDetailRow('Priority', booking['subtitle']?.replaceAll(' Priority', '') ?? 'N/A'),
                    _buildDetailRow('Symptoms', booking['symptoms']?.toString().isNotEmpty == true ? booking['symptoms'] : 'None'),
                    if ((booking['description'] ?? '').toString().isNotEmpty)
                      _buildDetailRow('Description', booking['description']),
                  ],
                  
                  if (booking['image_urls'] != null && (booking['image_urls'] as List).isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Attached Media',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 160,
                      child: _BookingImageCarousel(
                        urls: (booking['image_urls'] as List)
                            .map((e) => e.toString())
                            .toList(),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingImageCarousel extends StatefulWidget {
  final List<String> urls;
  const _BookingImageCarousel({required this.urls});

  @override
  State<_BookingImageCarousel> createState() => _BookingImageCarouselState();
}

class _BookingImageCarouselState extends State<_BookingImageCarousel> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          itemCount: widget.urls.length,
          onPageChanged: (i) => setState(() => _currentPage = i),
          itemBuilder: (context, i) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.urls[i],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.urls.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.urls.length, (i) {
                return Container(
                  width: _currentPage == i ? 8 : 6,
                  height: _currentPage == i ? 8 : 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == i ? Colors.white : Colors.white54,
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 2),
                    ],
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
