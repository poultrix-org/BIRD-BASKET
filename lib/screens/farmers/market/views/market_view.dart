import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/market_controller.dart';

class MarketView extends StatelessWidget {
  final MarketController controller = Get.put(MarketController());

  MarketView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.teal, size: 16),
                const SizedBox(width: 4),
                Obx(
                  () => Text(
                    controller.location.value,
                    style: const TextStyle(
                      fontFamily: 'Times New Roman',
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Obx(
              () => Text(
                'Today: ${controller.currentDate.value}',
                style: const TextStyle(
                  fontFamily: 'Times New Roman',
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Obx(
            () => IconButton(
              icon: controller.isRefreshing.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.teal,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.refresh, color: Colors.teal),
              onPressed: controller.isRefreshing.value
                  ? null
                  : controller.refreshRates,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshRates,
        color: Colors.teal,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('📉 Today\'s Rates'),
              _buildRateCardsRow(
                _buildRateCard(
                  '🐔',
                  'Broiler (Live)',
                  controller.broilerRate,
                  controller.broilerYesterday,
                  controller.broilerTrend,
                  '/ kg',
                ),
                _buildRateCard(
                  '🥚',
                  'Egg (Wholesale)',
                  controller.eggRate,
                  controller.eggYesterday,
                  controller.eggTrend,
                  '/ piece',
                ),
              ),
              const SizedBox(height: 12),
              _buildRateCardsRow(
                _buildRateCard(
                  '🌾',
                  'Starter Feed (50kg)',
                  controller.feedRate,
                  controller.feedYesterday,
                  controller.feedTrend,
                  '/ bag',
                ),
                _buildRateCard(
                  '🐣',
                  'Day-old Chick',
                  controller.chickRate,
                  controller.chickYesterday,
                  controller.chickTrend,
                  '/ chick',
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('📈 Weekly Trend (Broiler)'),
              _buildTrendGraph(),

              const SizedBox(height: 24),
              _buildSectionTitle('💡 Market Insight'),
              _buildMarketInsights(),

              const SizedBox(height: 24),
              _buildSectionTitle('🚨 Disease Alerts (Urgent)'),
              _buildDiseaseAlerts(),

              const SizedBox(height: 24),
              _buildSectionTitle('🦠 Common Poultry Diseases'),
              _buildDiseaseInfoList(),

              const SizedBox(height: 24),
              _buildSectionTitle('📍 Nearby Market Rates'),
              _buildNearbyRates(),

              const SizedBox(height: 24),
              _buildSectionTitle('🔔 Get Price Alerts'),
              _buildNotificationToggle(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Times New Roman',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildRateCardsRow(Widget card1, Widget card2) {
    return Row(
      children: [
        Expanded(child: card1),
        const SizedBox(width: 12),
        Expanded(child: card2),
      ],
    );
  }

  Widget _buildRateCard(
    String emoji,
    String title,
    RxDouble currentRate,
    RxDouble yesterdayRate,
    RxDouble trend,
    String unit,
  ) {
    return Obx(() {
      bool isUp = trend.value > 0;
      double formatAmount(double val) => double.parse(val.toStringAsFixed(2));

      return Container(
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
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Times New Roman',
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${formatAmount(currentRate.value)}',
                  style: const TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  ' $unit',
                  style: const TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: isUp
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUp ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 14,
                    color: isUp ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '₹${formatAmount(trend.value.abs())}',
                    style: TextStyle(
                      fontFamily: 'Times New Roman',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isUp ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Yest: ₹${formatAmount(yesterdayRate.value)}',
              style: const TextStyle(
                fontFamily: 'Times New Roman',
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTrendGraph() {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Obx(() {
        // Find max value to scale chart proportionally
        double maxPrice = 0;
        for (var item in controller.weeklyTrend) {
          if ((item['price'] as int) > maxPrice) {
            maxPrice = (item['price'] as int).toDouble();
          }
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: controller.weeklyTrend.map((data) {
            double price = (data['price'] as int).toDouble();
            String day = data['day'] as String;
            double height = (price / maxPrice) * 80;

            return Column(
              children: [
                Text(
                  '₹${price.toInt()}',
                  style: const TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 12,
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 30,
                  height: height,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade300,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  day,
                  style: const TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildMarketInsights() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        return Column(
          children: controller.marketInsights.map((insight) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insight,
                      style: const TextStyle(
                        fontFamily: 'Times New Roman',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildDiseaseAlerts() {
    return Obx(() {
      return Column(
        children: controller.diseaseAlerts.map((alert) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red.shade50, // very light red
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              leading: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 32,
              ),
              title: Text(
                alert['title']!,
                style: const TextStyle(
                  fontFamily: 'Times New Roman',
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              subtitle: Text(
                alert['desc']!,
                style: const TextStyle(
                  fontFamily: 'Times New Roman',
                  color: Colors.black87,
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildDiseaseInfoList() {
    return Obx(() {
      return Container(
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: controller.commonDiseases.map((disease) {
              return Theme(
                data: Theme.of(
                  Get.context!,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(
                    disease['name']!,
                    style: const TextStyle(
                      fontFamily: 'Times New Roman',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  leading: const Icon(
                    Icons.medical_information,
                    color: Colors.teal,
                  ),
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.coronavirus,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'Times New Roman',
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Symptoms: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: disease['symptoms']),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'Times New Roman',
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Prevention: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: disease['prevention']),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  Widget _buildNearbyRates() {
    return Container(
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
      child: Obx(() {
        return Column(
          children: controller.nearbyRates.map((nearby) {
            String location = nearby['location'] as String;
            double rate = nearby['rate'] as double;
            return ListTile(
              leading: const Icon(Icons.place, color: Colors.grey),
              title: Text(
                location,
                style: const TextStyle(
                  fontFamily: 'Times New Roman',
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Text(
                '₹${rate.toStringAsFixed(0)}/kg',
                style: const TextStyle(
                  fontFamily: 'Times New Roman',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.teal,
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildNotificationToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: Colors.teal, size: 28),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Push Alerts',
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Price & Disease Updates',
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Switch(
              value: controller.notificationsEnabled.value,
              activeColor: Colors.teal,
              onChanged: (val) => controller.toggleNotifications(val),
            ),
          ),
        ],
      ),
    );
  }
}
