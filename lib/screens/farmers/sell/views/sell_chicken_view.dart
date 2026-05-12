import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/sell_chicken_controller.dart';

class SellChickenView extends StatelessWidget {
  SellChickenView({super.key});

  final SellChickenController controller = Get.put(SellChickenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.transparent, // Off-white/bone for minimal farming aesthetic
      appBar: AppBar(
        title: Text(
          'Sell Your Chickens',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: const Color(0xFF1B5E20), // Dark green heading
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Color(0xFF1B5E20)),
        actions: [
          Obx(
            () => controller.isFormOpen.value
                ? IconButton(
                    icon: Icon(Icons.cancel_rounded),
                    tooltip: "View Listings",
                    onPressed: () => controller.closeForm(),
                  )
                : IconButton(
                    icon: Icon(Icons.add),
                    tooltip: "New Listing",
                    onPressed: () => controller.openForm(),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingListings.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.isFormOpen.value) {
          return _buildSellForm(context);
        } else {
          return _buildListingsView(context);
        }
      }),
    );
  }

  Widget _buildListingsView(BuildContext context) {
    if (controller.myActiveListings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              "No Active Listings",
              style: GoogleFonts.montserrat(
                fontSize: 22,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "You haven't posted any chickens for sale yet.",
              style: GoogleFonts.montserrat(fontSize: 16, color: Colors.grey.shade500),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text(
                'Create First Listing',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D654E),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => controller.openForm(),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.myActiveListings.length,
      itemBuilder: (context, index) {
        final item = controller.myActiveListings[index];
        final totalQty =
            double.tryParse(item['total_quantity'].toString()) ?? 0.0;
        final price = double.tryParse(item['price_per_kg'].toString()) ?? 0.0;
        final date = item['available_date']?.toString().split('T')[0] ?? '';
        final int birds =
            int.tryParse(item['number_of_birds']?.toString() ?? '0') ?? 0;

        String locationStr = 'No location provided';
        if (item['location'] != null) {
          if (item['location'] is Map) {
            locationStr =
                item['location']['address']?.toString() ??
                'Location coordinates';
          } else {
            locationStr = item['location'].toString();
          }
        }

        return InkWell(
          onTap: () => _showListingDetails(context, item),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            // REMOVED PADDING entirely so the image can span edge-to-edge
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.04,
                  ), // subtle shadow like reference
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 1. Content Area (determines the dynamic height of the entire card)
                Container(
                  constraints: const BoxConstraints(minHeight: 165),
                  padding: const EdgeInsets.only(left: 140.0), // Space for the image
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Tags
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _buildBadge(
                              "🏷️ ${item['status']?.toString().toUpperCase() ?? 'ACTIVE'}",
                              isSecondary: false,
                            ),
                            if (item['accept_negotiation'] == true)
                              _buildBadge("🤝 Negotiable", isSecondary: true),
                          ],
                        ),
                        SizedBox(height: 10),

                        // Title
                        Text(
                          "$birds Birds • $totalQty kg",
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E2019), // Deep text
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),

                        // Description/Subtitle
                        Text(
                          "Available From $date\n$locationStr",
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 12),

                        // Price bottom
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₹$price",
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              "/kg",
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "₹${price + 10} /kg", // Mock market average crossed out
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Image Area (stretches dynamically to match the content height)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  width: 140,
                  child: Builder(
                    builder: (context) {
                      final List<String> urls = [];
                      if (item['image_urls'] != null && item['image_urls'] is List) {
                        for (var u in item['image_urls']) {
                          if (u != null && u.toString().startsWith('http')) {
                            urls.add(u.toString());
                          }
                        }
                      }
                      if (urls.isEmpty && item['image_url'] != null &&
                          item['image_url'].toString().startsWith('http')) {
                        urls.add(item['image_url'].toString());
                      }

                      if (urls.isEmpty) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                            ),
                            border: Border(
                              right: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        );
                      }

                      return _ListTileImageCarousel(urls: urls);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text, {required bool isSecondary}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isSecondary ? Colors.orange.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSecondary ? Colors.orange.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isSecondary ? Colors.orange.shade800 : Colors.grey.shade700,
        ),
      ),
    );
  }

  void _showListingDetails(BuildContext context, Map<String, dynamic> item) {
    final totalQty = double.tryParse(item['total_quantity'].toString()) ?? 0.0;
    final price = double.tryParse(item['price_per_kg'].toString()) ?? 0.0;
    final weightPerBird =
        double.tryParse(item['weight_per_bird'].toString()) ?? 0.0;
    final date = item['available_date']?.toString().split('T')[0] ?? '';
    final birds = int.tryParse(item['number_of_birds']?.toString() ?? '0') ?? 0;

    String locationStr = 'No address provided';
    if (item['location'] != null) {
      if (item['location'] is Map) {
        locationStr =
            item['location']['address']?.toString() ?? 'Location saved';
      } else {
        locationStr = item['location'].toString();
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height * 0.75, // Cover 75% of screen
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Bottom sheet drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Carousel
                      Builder(
                        builder: (context) {
                          final List<String> urls = [];
                          if (item['image_urls'] != null && item['image_urls'] is List) {
                            for (var u in item['image_urls']) {
                              if (u != null && u.toString().startsWith('http')) {
                                urls.add(u.toString());
                              }
                            }
                          }
                          if (urls.isEmpty && item['image_url'] != null &&
                              item['image_url'].toString().startsWith('http')) {
                            urls.add(item['image_url'].toString());
                          }
                          if (urls.isEmpty) {
                            return Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Icon(Icons.image_not_supported_outlined,
                                    size: 64, color: Colors.grey.shade400),
                              ),
                            );
                          }
                          return SizedBox(
                            height: 200,
                            child: _DetailImageCarousel(urls: urls),
                          );
                        },
                      ),
                      SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "$birds Birds Listing",
                              style: GoogleFonts.montserrat(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B5E20).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item['status']?.toString().toUpperCase() ??
                                  'ACTIVE',
                              style: GoogleFonts.montserrat(
                                color: Color(0xFF1B5E20),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),
                      Text(
                        "Listing Details",
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Stat layout
                      _buildDetailRow(
                        Icons.scale,
                        "Total Quantity",
                        "$totalQty kg",
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(Icons.savings, "Price per Kg", "₹$price"),
                      const Divider(height: 24),
                      _buildDetailRow(
                        Icons.monitor_weight_outlined,
                        "Avg Weight (per Bird)",
                        "$weightPerBird kg",
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        Icons.calendar_month,
                        "Available From",
                        date,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        Icons.location_on,
                        "Location",
                        locationStr,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        Icons.handshake,
                        "Negotiable",
                        item['accept_negotiation'] == true ? "Yes" : "No",
                        valueColor: item['accept_negotiation'] == true
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),

                      if (item['notes'] != null &&
                          item['notes'].toString().isNotEmpty) ...[
                        const Divider(height: 24),
                        Text(
                          "Additional Notes",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            item['notes'].toString(),
                            style: GoogleFonts.montserrat(fontSize: 14, height: 1.4),
                          ),
                        ),
                      ],

                      SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Get.back();
                            Get.snackbar(
                              "Buyers Viewer",
                              "Currently searching for matched buyers... Coming soon!",
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          child: Text(
                            "View Buyers Matches",
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      // Cancel Listing button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.red.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            _showCancelConfirmation(context, item);
                          },
                          child: Text(
                            "Cancel Listing",
                            style: GoogleFonts.montserrat(
                              color: Colors.red.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ───────── Cancel Confirmation Bottom Sheet ─────────
  void _showCancelConfirmation(BuildContext parentContext, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Lottie animation
              SizedBox(
                width: 150,
                height: 150,
                child: Lottie.asset(
                  'assets/animations/cancel listing.json',
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                "Cancel this listing?",
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                "This listing will be permanently removed and buyers will no longer see it. This action cannot be undone.",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // Buttons row
              Row(
                children: [
                  // No, Keep it — Green
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.green.shade400, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(
                          "No, Keep it",
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Yes, Cancel it — Red
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          Navigator.of(ctx).pop(); // Close confirmation
                          Navigator.of(parentContext).pop(); // Close details sheet

                          // Delete from Supabase
                          try {
                            final createdAt = item['created_at'];
                            final farmerId = item['farmer_id'];
                            if (createdAt != null && farmerId != null) {
                              await controller.supabase
                                  .from('SellListings')
                                  .delete()
                                  .eq('farmer_id', farmerId.toString())
                                  .eq('created_at', createdAt.toString());
                            }
                            await controller.fetchMyListings();
                            Get.snackbar(
                              "Listing Cancelled",
                              "Your listing has been removed successfully.",
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          } catch (e) {
                            print("Error deleting listing: $e");
                            Get.snackbar(
                              "Error",
                              "Could not cancel listing. Try again.",
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                        child: Text(
                          "Yes, Cancel it",
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade500, size: 22),
        SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.montserrat(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: valueColor ?? Colors.black87,
            ),
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSellForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Items'),
            _buildCard(
              child: Column(
                children: [
                  _buildTextFieldWithMic(
                    textController: controller.birdsController,
                    label: 'Quantity',
                    hint: 'e.g. 50',
                    fieldName: 'quantity',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => controller.calculateTotal(),
                  ),
                  SizedBox(height: 16),
                  _buildTextFieldWithMic(
                    textController: controller.weightController,
                    label: 'Approx Weight per Bird (kg)',
                    hint: 'e.g. 1.5',
                    fieldName: 'weight',
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => controller.calculateTotal(),
                  ),
                  SizedBox(height: 16),
                  Obx(
                    () => Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Quantity:',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${controller.totalQuantity.value.toStringAsFixed(2)} kg',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF5D654E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ESTIMATED EARNINGS
                        if (controller.totalQuantity.value > 0 && controller.expectedPrice.value > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 4, right: 4),
                            child: Row(
                              children: [
                                Text(
                                  '💰 Estimated Earnings:',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '₹${(controller.totalQuantity.value * controller.expectedPrice.value).toStringAsFixed(2)}',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Obx(() => InkWell(
                    onTap: () => controller.pickDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: controller.attemptedSubmit.value && controller.availableDate.value == null 
                            ? Colors.red 
                            : Colors.grey.shade300,
                          width: controller.attemptedSubmit.value && controller.availableDate.value == null ? 1.5 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.availableDate.value == null
                                ? 'Available Date'
                                : '📅 ${controller.availableDate.value!.toLocal().toString().split(' ')[0]}',
                            style: GoogleFonts.montserrat(
                              fontSize: 14, // Adjusted explicitly
                              color: controller.attemptedSubmit.value && controller.availableDate.value == null 
                                ? Colors.red 
                                : Colors.black87,
                            ),
                          ),
                          Icon(Icons.calendar_today, color: controller.attemptedSubmit.value && controller.availableDate.value == null ? Colors.red : Colors.grey),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),

            SizedBox(height: 16),
            const Divider(
              color: Color(0xFFE2E4DA),
              thickness: 1,
              indent: 8,
              endIndent: 8,
            ),
            SizedBox(height: 8),
            _buildSectionTitle('Pricing'),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final price = controller.expectedPrice.value;
                    final isGood = price <= 95 && price > 0;
                    final isHigh = price > 95;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Market average: ₹95/kg',
                          style: GoogleFonts.montserrat(
                            color: Color(0xFF5D654E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (price > 0) ...[
                          SizedBox(height: 4),
                          Text(
                            isGood ? '✅ Your price is competitive' : '⚠️ Your price is above market',
                            style: GoogleFonts.montserrat(
                              color: isGood ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    );
                  }),
                  SizedBox(height: 16),
                  _buildTextFieldWithMic(
                    textController: controller.priceController,
                    label: 'Expected Price per Kg (₹)',
                    hint: 'e.g. 100',
                    fieldName: 'price',
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (val) {
                      controller.expectedPrice.value = double.tryParse(val) ?? 0.0;
                    },
                  ),
                  SizedBox(height: 8),
                  Obx(
                    () => SwitchListTile(
                      title: Text('Accept Negotiation', style: GoogleFonts.montserrat()),
                      value: controller.acceptNegotiation.value,
                      onChanged: (val) =>
                          controller.acceptNegotiation.value = val,
                      activeThumbColor: const Color(0xFF5D654E),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),
            const Divider(
              color: Color(0xFFE2E4DA),
              thickness: 1,
              indent: 8,
              endIndent: 8,
            ),
            SizedBox(height: 8),
            _buildSectionTitle('Urgency & Delivery'),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("How fast do you want to sell?", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Obx(() => Column(
                    children: [
                      RadioListTile(
                        value: 'today',
                        groupValue: controller.urgency.value,
                        onChanged: (val) => controller.urgency.value = val.toString(),
                        title: Text('Sell Today', style: GoogleFonts.montserrat()),
                        subtitle: Text('More buyers, higher priority', style: GoogleFonts.montserrat()),
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFF1B5E20),
                      ),
                      RadioListTile(
                        value: 'normal',
                        groupValue: controller.urgency.value,
                        onChanged: (val) => controller.urgency.value = val.toString(),
                        title: Text('Within 3 days', style: GoogleFonts.montserrat()),
                        subtitle: Text('Normal visibility', style: GoogleFonts.montserrat()),
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFF1B5E20),
                      ),
                      RadioListTile(
                        value: 'flexible',
                        groupValue: controller.urgency.value,
                        onChanged: (val) => controller.urgency.value = val.toString(),
                        title: Text('Flexible', style: GoogleFonts.montserrat()),
                        subtitle: Text('Low priority', style: GoogleFonts.montserrat()),
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFF1B5E20),
                      ),
                    ],
                  )),
                  SizedBox(height: 16),
                  Text("Delivery Preference", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Obx(() => Column(
                    children: [
                      RadioListTile(
                        value: 'pickup',
                        groupValue: controller.deliveryType.value,
                        onChanged: (val) => controller.deliveryType.value = val.toString(),
                        title: Text('Buyer Pickup (Recommended)', style: GoogleFonts.montserrat()),
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFF1B5E20),
                      ),
                      RadioListTile(
                        value: 'delivery',
                        groupValue: controller.deliveryType.value,
                        onChanged: (val) => controller.deliveryType.value = val.toString(),
                        title: Text('I will deliver (+ cost)', style: GoogleFonts.montserrat()),
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFF1B5E20),
                      ),
                    ],
                  )),
                ],
              ),
            ),

            SizedBox(height: 16),
            const Divider(
              color: Color(0xFFE2E4DA),
              thickness: 1,
              indent: 8,
              endIndent: 8,
            ),
            SizedBox(height: 8),
            _buildSectionTitle('Location'),
            _buildCard(
              child: Column(
                children: [
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.my_location, color: Colors.white),
                      label: Text('Auto Detect Location', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20), // Green highlight
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      onPressed: () => controller.detectLocation(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text('OR', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  SizedBox(height: 16),
                  _buildTextFieldWithMic(
                    textController: controller.locationController,
                    label: 'Enter Address Manually',
                    hint: 'e.g. Farm No. 12, Kangeyam, Tamil Nadu',
                    fieldName: 'location',
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),
            const Divider(
              color: Color(0xFFE2E4DA),
              thickness: 1,
              indent: 8,
              endIndent: 8,
            ),
            SizedBox(height: 8),
            _buildSectionTitle('Additional Info'),
            _buildCard(
              child: _buildTextFieldWithMic(
                textController: controller.notesController,
                label: 'Notes',
                hint: 'e.g. Healthy broilers, ready in 3 days',
                fieldName: 'notes',
                maxLines: 3,
                isRequired: false,
              ),
            ),

            SizedBox(height: 16),
            const Divider(
              color: Color(0xFFE2E4DA),
              thickness: 1,
              indent: 8,
              endIndent: 8,
            ),
            SizedBox(height: 8),
            _buildSectionTitle('Upload Photos'),
            Text(
              'Upload 3 chicken photos (compulsory).',
              style: GoogleFonts.montserrat(color: Colors.black, fontSize: 13),
            ),
            SizedBox(height: 10),
            Obx(
              () => Row(
                children: List.generate(3, (index) {
                  final path = controller.imagePaths[index].value;
                  final isMissing = controller.attemptedSubmit.value && path == null;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.pickImage(index),
                      child: Container(
                        height: 100,
                        margin: EdgeInsets.only(
                          right: index < 2 ? 8 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: isMissing ? Colors.red.shade50 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: path != null
                                ? const Color(0xFF5D654E)
                                : isMissing ? Colors.red : Colors.grey.shade300,
                            width: isMissing ? 1.5 : 1.0,
                          ),
                          image: path != null
                              ? DecorationImage(
                                  image: FileImage(File(path)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: path == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo,
                                      color: isMissing ? Colors.red.shade300 : Colors.grey.shade400, size: 28),
                                  SizedBox(height: 4),
                                  Text(
                                    'Photo ${index + 1}',
                                    style: GoogleFonts.montserrat(
                                      color: isMissing ? Colors.red : Colors.grey.shade500,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                  );
                }),
              ),
            ),

            SizedBox(height: 24),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () => _showConfirmationSheet(context),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Review & Post',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 12.0),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1B5E20), // Dark green
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: child,
    );
  }

  Widget _buildTextFieldWithMic({
    required TextEditingController textController,
    required String label,
    required String hint,
    required String fieldName,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = true, 
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5D654E),
          ),
        ),
        SizedBox(height: 8),
        Obx(
          () => TextFormField(
            controller: textController,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: onChanged,
            style: GoogleFonts.montserrat(),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.montserrat(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
              errorStyle: GoogleFonts.montserrat(
                color: Colors.red,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),

              suffixIcon: GestureDetector(
                onTap: () {
                  if (controller.isListening.value &&
                      controller.activeFieldForVoice.value == fieldName) {
                    controller.stopListening();
                  } else {
                    controller.startListening(fieldName, textController);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: controller.isListening.value &&
                            controller.activeFieldForVoice.value == fieldName
                        ? Colors.red.shade50
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    controller.isListening.value &&
                            controller.activeFieldForVoice.value == fieldName
                        ? Icons.mic
                        : Icons.mic_none,
                    color: controller.isListening.value &&
                            controller.activeFieldForVoice.value == fieldName
                        ? Colors.red
                        : Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: controller.isListening.value &&
                          controller.activeFieldForVoice.value == fieldName
                      ? Colors.red
                      : Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF5D654E)),
              ),
            ),
            validator: isRequired
                ? (value) {
                    if (value == null || value.isEmpty) return 'This field is required';
                    return null;
                  }
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(Icons.upload_file, color: Color(0xFF5D654E)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.grey.shade300),
          backgroundColor: Colors
              .transparent, // Off-white/bone for minimal farming aesthetic
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        label: Text(
          label,
          style: GoogleFonts.montserrat(
            color: Color(0xFF5D654E),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ───────── Confirmation Bottom Sheet ─────────
  void _showConfirmationSheet(BuildContext context) {
    // Validate form first
    controller.attemptedSubmit.value = true;
    bool hasErrors = false;

    if (!controller.formKey.currentState!.validate()) {
      hasErrors = true;
    }
    if (controller.availableDate.value == null) {
      hasErrors = true;
      Get.snackbar('Validation', 'Please select an available date',
          snackPosition: SnackPosition.BOTTOM);
    }

    if (hasErrors) {
      Get.snackbar('Validation', 'Please fill all required highlighted fields',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final birds = int.tryParse(controller.birdsController.text) ?? 0;
    final weight = double.tryParse(controller.weightController.text) ?? 0.0;
    final price = double.tryParse(controller.priceController.text) ?? 0.0;
    final totalQty = controller.totalQuantity.value;
    final date = controller.availableDate.value?.toLocal().toString().split(' ')[0] ?? '';
    final location = controller.locationController.text;
    final notes = controller.notesController.text;
    final negotiable = controller.acceptNegotiation.value;

    // Collect local image paths
    final List<String> localImagePaths = [];
    for (var img in controller.imagePaths) {
      if (img.value != null) localImagePaths.add(img.value!);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Confirm Your Listing",
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Review all details before posting to buyers.",
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Photos preview
                      if (localImagePaths.isNotEmpty) ...[
                        Text(
                          "Photos",
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 180,
                          child: _ConfirmationImageCarousel(paths: localImagePaths),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Details card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            _confirmRow("🐔 Number of Birds", "$birds"),
                            const Divider(height: 20),
                            _confirmRow("⚖️ Weight per Bird", "$weight kg"),
                            const Divider(height: 20),
                            _confirmRow("📦 Total Quantity", "${totalQty.toStringAsFixed(2)} kg"),
                            const Divider(height: 20),
                            _confirmRow("💰 Price per Kg", "₹$price"),
                            const Divider(height: 20),
                            _confirmRow("💵 Est. Earnings", "₹${(totalQty * price).toStringAsFixed(2)}"),
                            const Divider(height: 20),
                            _confirmRow("📅 Available From", date),
                            const Divider(height: 20),
                            _confirmRow("📍 Location", location.isNotEmpty ? location : 'Not set'),
                            const Divider(height: 20),
                            _confirmRow("🤝 Negotiable", negotiable ? "Yes" : "No"),
                            if (notes.isNotEmpty) ...[
                              const Divider(height: 20),
                              _confirmRow("📝 Notes", notes),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Confirm Post button
                      Obx(() => SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: controller.isLoading.value
                              ? null
                              : () {
                                  Navigator.of(ctx).pop(); // Close confirmation sheet
                                  controller.submitForm();
                                },
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  '✅  Confirm & Post',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      )),

                      const SizedBox(height: 12),

                      // Cancel
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: const StadiumBorder(),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(
                            'Go Back & Edit',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _confirmRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

// ─── Stateful Image Carousel for List Tiles ───
class _ListTileImageCarousel extends StatefulWidget {
  final List<String> urls;
  const _ListTileImageCarousel({required this.urls});

  @override
  State<_ListTileImageCarousel> createState() => _ListTileImageCarouselState();
}

class _ListTileImageCarouselState extends State<_ListTileImageCarousel> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomLeft: Radius.circular(15),
        ),
        border: Border(
          right: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
            child: PageView.builder(
              itemCount: widget.urls.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, i) {
                return CachedNetworkImage(
                  imageUrl: widget.urls[i],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.green.shade600,
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 32,
                      color: Colors.grey.shade400,
                    ),
                  ),
                );
              },
            ),
          ),
          // Dot indicators
          if (widget.urls.length > 1)
            Positioned(
              bottom: 6,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.urls.length, (i) {
                  return Container(
                    width: _currentPage == i ? 8 : 6,
                    height: _currentPage == i ? 8 : 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == i ? Colors.white : Colors.white54,
                      border: Border.all(color: Colors.black26, width: 0.5),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Stateful Image Carousel for Confirmation Sheet (local files) ───
class _ConfirmationImageCarousel extends StatefulWidget {
  final List<String> paths;
  const _ConfirmationImageCarousel({required this.paths});

  @override
  State<_ConfirmationImageCarousel> createState() => _ConfirmationImageCarouselState();
}

class _ConfirmationImageCarouselState extends State<_ConfirmationImageCarousel> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          itemCount: widget.paths.length,
          onPageChanged: (i) => setState(() => _currentPage = i),
          itemBuilder: (context, i) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: FileImage(File(widget.paths[i])),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
        if (widget.paths.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.paths.length, (i) {
                return Container(
                  width: _currentPage == i ? 10 : 7,
                  height: _currentPage == i ? 10 : 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == i ? Colors.white : Colors.white54,
                    boxShadow: [
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

// ─── Stateful Image Carousel for Details Bottom Sheet (network URLs) ───
class _DetailImageCarousel extends StatefulWidget {
  final List<String> urls;
  const _DetailImageCarousel({required this.urls});

  @override
  State<_DetailImageCarousel> createState() => _DetailImageCarouselState();
}

class _DetailImageCarouselState extends State<_DetailImageCarousel> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          itemCount: widget.urls.length,
          onPageChanged: (i) => setState(() => _currentPage = i),
          itemBuilder: (context, i) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: widget.urls[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade100,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade100,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.urls.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.urls.length, (i) {
                return Container(
                  width: _currentPage == i ? 10 : 7,
                  height: _currentPage == i ? 10 : 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == i ? Colors.white : Colors.white54,
                    boxShadow: [
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
