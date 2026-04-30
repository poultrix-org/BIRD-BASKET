import re

with open('lib/screens/farmers/sell/views/sell_chicken_view.dart', 'r') as f:
    text = f.read()

# Let's just find and replace the whole `_buildListingsView` again to be absolutely 100% sure we don't mess up brackets and get perfect styling
start_idx = text.find('  Widget _buildListingsView(BuildContext context) {')
end_idx = text.find('  Widget _buildBadge(String text, {required bool isSecondary}) {')

new_method = """  Widget _buildListingsView(BuildContext context) {
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
                  color: Colors.black.withOpacity(0.04), // subtle shadow like reference
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
                      border: Border(right: BorderSide(color: Colors.grey.shade200)),
                      image: item['image_url'] != null && item['image_url'].toString().startsWith('http')
                        ? DecorationImage(
                            image: NetworkImage(item['image_url']),
                            fit: BoxFit.cover,
                          )
                        : null,
                    ),
                    child: item['image_url'] != null && item['image_url'].toString().startsWith('http')
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
                      padding: const EdgeInsets.all(16.0), // Padding is applied to text ONLY
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
                            "Available From $date\\n$locationStr",
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

"""
text = text[:start_idx] + new_method + text[end_idx:]
with open('lib/screens/farmers/sell/views/sell_chicken_view.dart', 'w') as f:
    f.write(text)

