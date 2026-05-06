import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
        title: const Text(
          'Sell Your Chickens',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20), // Dark green heading
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1B5E20)),
        actions: [
          Obx(
            () => controller.isFormOpen.value
                ? IconButton(
                    icon: const Icon(Icons.list),
                    tooltip: "View Listings",
                    onPressed: () => controller.closeForm(),
                  )
                : IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: "New Listing",
                    onPressed: () => controller.openForm(),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingListings.value) {
          return const Center(child: CircularProgressIndicator());
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
            const SizedBox(height: 16),
            Text(
              "No Active Listings",
              style: TextStyle(
                fontSize: 22,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You haven't posted any chickens for sale yet.",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text(
                'Create First Listing',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left image matching exactly the right side height tightly with NO GAP
                  Container(
                    width: 140, // Increased size on the left per instructions
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      // We only curve the left corners to fit inside the parent border
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                      border: Border(
                        right: BorderSide(color: Colors.grey.shade200),
                      ),
                      image:
                          item['image_url'] != null &&
                              item['image_url'].toString().startsWith('http')
                          ? DecorationImage(
                              image: NetworkImage(item['image_url']),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child:
                        item['image_url'] != null &&
                            item['image_url'].toString().startsWith('http')
                        ? null
                        : Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                          ),
                  ),

                  // Content area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        16.0,
                      ), // Padding is applied to text ONLY
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
                          const SizedBox(height: 10),

                          // Title
                          Text(
                            "$birds Birds • $totalQty kg",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E2019), // Deep text
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),

                          // Description/Subtitle
                          Text(
                            "Available From $date\n$locationStr",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),

                          // Price bottom
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "₹$price",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "/kg",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "₹${price + 10} /kg", // Mock market average crossed out
                                style: TextStyle(
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
                ],
              ),
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
        style: TextStyle(
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
          decoration: const BoxDecoration(
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
                            child: PageView.builder(
                              itemCount: urls.length,
                              itemBuilder: (context, i) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    image: DecorationImage(
                                      image: NetworkImage(urls[i]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "$birds Birds Listing",
                              style: const TextStyle(
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
                              style: const TextStyle(
                                color: Color(0xFF1B5E20),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        "Listing Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

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
                        const Text(
                          "Additional Notes",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                            style: const TextStyle(fontSize: 14, height: 1.4),
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),
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
                          child: const Text(
                            "View Buyers Matches",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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

  Widget _buildDetailRow(
    IconData icon,
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade500, size: 22),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
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
            style: TextStyle(
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
                  const SizedBox(height: 16),
                  _buildTextFieldWithMic(
                    textController: controller.weightController,
                    label: 'Approx Weight per Bird (kg)',
                    hint: 'e.g. 1.5',
                    fieldName: 'weight',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => controller.calculateTotal(),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Quantity:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${controller.totalQuantity.value.toStringAsFixed(2)} kg',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF5D654E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => controller.pickDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(
                            () => Text(
                              controller.availableDate.value == null
                                  ? 'Available Date'
                                  : '📅 ${controller.availableDate.value!.toLocal().toString().split(' ')[0]}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const Icon(Icons.calendar_today, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(
              color: Color(0xFFE2E4DA),
              thickness: 1,
              indent: 8,
              endIndent: 8,
            ),
            const SizedBox(height: 8),
            _buildSectionTitle('Pricing'),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Market Price: ₹95/kg',
                    style: TextStyle(
                      color: Color(0xFF5D654E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextFieldWithMic(
                    textController: controller.priceController,
                    label: 'Expected Price per Kg (₹)',
                    hint: 'e.g. 100',
                    fieldName: 'price',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => SwitchListTile(
                      title: const Text('Accept Negotiation'),
                      value: controller.acceptNegotiation.value,
                      onChanged: (val) =>
                          controller.acceptNegotiation.value = val,
                      activeColor: const Color(0xFF5D654E),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(
              color: Color(0xFFE2E4DA),
              thickness: 1,
              indent: 8,
              endIndent: 8,
            ),
            const SizedBox(height: 8),
            _buildSectionTitle('Location'),
            _buildCard(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.my_location),
                    label: const Text('Auto Detect Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors
                          .transparent, // Off-white/bone for minimal farming aesthetic
                      foregroundColor: const Color(0xFF5D654E),
                      elevation: 0,
                    ),
                    onPressed: () => controller.detectLocation(),
                  ),
                  const SizedBox(height: 16),
                  _buildTextFieldWithMic(
                    textController: controller.locationController,
                    label: 'Or Enter Address Manually',
                    hint: 'e.g. Farm No. 12, Kangeyam, Tamil Nadu',
                    fieldName: 'location',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(
              color: Color(0xFFE2E4DA),
              thickness: 1,
              indent: 8,
              endIndent: 8,
            ),
            const SizedBox(height: 8),
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

            const SizedBox(height: 16),
            const Divider(
              color: Color(0xFFE2E4DA),
              thickness: 1,
              indent: 8,
              endIndent: 8,
            ),
            const SizedBox(height: 8),
            _buildSectionTitle('Upload Photos'),
            const Text(
              'Upload 3 chicken photos (compulsory).',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Obx(
              () => Row(
                children: List.generate(3, (index) {
                  final path = controller.imagePaths[index].value;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.pickImage(index),
                      child: Container(
                        height: 100,
                        margin: EdgeInsets.only(
                          right: index < 2 ? 8 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: path != null
                                ? const Color(0xFF5D654E)
                                : Colors.grey.shade300,
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
                                      color: Colors.grey.shade400, size: 28),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Photo ${index + 1}',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
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

            const SizedBox(height: 32),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,

                    shape: const StadiumBorder(),
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.submitForm(),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 30),
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
        style: const TextStyle(
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5D654E),
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => TextFormField(
            controller: textController,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
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
        icon: const Icon(Icons.upload_file, color: Color(0xFF5D654E)),
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
          style: const TextStyle(
            color: Color(0xFF5D654E),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
