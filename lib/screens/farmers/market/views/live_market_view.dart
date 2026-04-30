import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controllers/live_market_controller.dart';
import '../models/disease_alert_model.dart';
import '../models/market_rate_model.dart';

class LiveMarketPage extends StatelessWidget {
  final LiveMarketController controller = Get.put(LiveMarketController());

  LiveMarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Obx(
                  () => Text(
                    controller.locationName.value,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Obx(
              () => Text(
                'Last Updated: ${controller.lastUpdatedTime.value}',
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: controller.refreshMarketData,
              );
            }
          }),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.teal,
        onRefresh: controller.refreshMarketData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMapSection(),
              const SizedBox(height: 16),
              _buildRatesSection(),
              const SizedBox(height: 16),
              _buildDiseaseAlertsSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey.shade300,
      child: Obx(() {
        // Show map when ready
        if (controller.currentPosition.value == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_searching, color: Colors.grey, size: 40),
                SizedBox(height: 8),
                Text(
                  'Locating GPS...',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          );
        }

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              controller.currentPosition.value!.latitude,
              controller.currentPosition.value!.longitude,
            ),
            zoom: 10,
          ),
          markers: controller.mapMarkers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
        );
      }),
    );
  }

  Widget _buildRatesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📉 Live Market Rates',
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            MarketRateModel? current = controller.nearestRate.value;
            MarketRateModel? prev = controller.previousRate.value;

            if (current == null) {
              return const Center(
                child: Text(
                  'No rate data found nearby.',
                  style: TextStyle(color: Colors.black54),
                ),
              );
            }

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildRateCard(
                        '🐔 Broiler',
                        current.broilerRate,
                        prev?.broilerRate,
                        '₹',
                        '/ kg',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildRateCard(
                        '🥚 Egg',
                        current.eggRate,
                        prev?.eggRate,
                        '₹',
                        '/ piece',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildRateCard(
                        '🌾 Feed (50kg)',
                        current.feedRate,
                        prev?.feedRate,
                        '₹',
                        '/ bag',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildRateCard(
                        '🐣 Chick',
                        current.chickRate,
                        prev?.chickRate,
                        '₹',
                        '/ chick',
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRateCard(
    String title,
    double currentRate,
    double? prevRate,
    String currency,
    String unit,
  ) {
    double diff = 0.0;
    bool isUp = true;
    bool hasTrend = false;

    if (prevRate != null) {
      hasTrend = true;
      diff = currentRate - prevRate;
      isUp = diff >= 0;
    }

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
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$currency${currentRate.toStringAsFixed(currentRate == currentRate.toInt() ? 0 : 2)}',
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0, left: 2.0),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          if (hasTrend) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isUp ? Icons.trending_up : Icons.trending_down,
                  color: isUp ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isUp ? '+' : ''}${diff.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isUp ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiseaseAlertsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🚨 Nearby Disease Alerts (50km Radius)',
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.nearbyAlerts.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Safe! No nearby disease alerts reported within 50km.',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: controller.nearbyAlerts.map((alert) {
                Color alertColor = Colors.green;
                IconData alertIcon = Icons.info_outline;

                if (alert.severity == 'high') {
                  alertColor = Colors.red;
                  alertIcon = Icons.warning_amber_rounded;
                } else if (alert.severity == 'medium') {
                  alertColor = Colors.orange;
                  alertIcon = Icons.warning;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: alertColor.withOpacity(0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: alertColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: alertColor.withOpacity(0.1),
                      child: Icon(alertIcon, color: alertColor),
                    ),
                    title: Text(
                      alert.title,
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.bold,
                        color: alertColor,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        alert.description,
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    trailing: Text(
                      alert.severity.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.bold,
                        color: alertColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
