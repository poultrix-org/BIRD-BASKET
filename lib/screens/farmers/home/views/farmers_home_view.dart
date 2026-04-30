import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import 'package:carousel_slider/carousel_slider.dart';

import '../controllers/farmers_home_controller.dart';
import '../../profile/views/farmer_profile_view.dart';
import '../../sell/views/sell_chicken_view.dart';
import '../../vet/views/vet_home_view.dart';
import '../../market/views/market_view.dart';
import '../../alerts/views/alerts_view.dart';

class FarmersHomeView extends StatelessWidget {
  final FarmersHomeController controller = Get.put(FarmersHomeController());

  FarmersHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              textTheme: GoogleFonts.playfairDisplayTextTheme(
                Theme.of(context).textTheme,
              ),
            ),
            child: Obx(() {
              switch (controller.currentIndex.value) {
                case 0:
                  return _buildHomeContent(context);
                case 1:
                  return SafeArea(child: SellChickenView());
                case 2:
                  return SafeArea(child: VetHomeView());
                case 3:
                  return SafeArea(child: MarketView());
                case 4:
                  return SafeArea(child: AlertsView());
                default:
                  return _buildHomeContent(context);
              }
            }),
          ),
        ],
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F8F3), // Solid background
            border: Border(
              top: BorderSide(color: Color(0xFFE2E4DA), width: 1.5),
            ),
          ),
          child: BottomNavigationBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed, // Off-white
            selectedIconTheme: const IconThemeData(color: Color(0xFF1B5E20)),
            unselectedIconTheme: const IconThemeData(color: Colors.grey),
            selectedItemColor: const Color(0xFF1B5E20),
            unselectedItemColor: Colors.black54,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 10),
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.storefront),
                label: 'Sell',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.medical_services),
                label: 'Vet',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.trending_up),
                label: 'Market',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'Alerts',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weather Header
          _buildWeatherHeader(context),

          // Content area below weather
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        Text(
                          controller.user.fullName ?? 'Farmer',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    // Points or Coin UI
                    Row(
                      children: [
                        const Text(
                          '120',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.eco,
                            color: Colors.brown,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sponsored Banner Carousel
                CarouselSlider(
                  options: CarouselOptions(
                    height: 170.0,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    autoPlayAnimationDuration: const Duration(
                      milliseconds: 800,
                    ),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    viewportFraction: 1.0,
                  ),
                  items: [
                    _buildCarouselBanner(
                      title: 'Get 20% off on Premium Feed!',
                      subtitle: 'Limited time offer. Tap to order now.',
                      colors: [Colors.orangeAccent, Colors.deepOrange],
                    ),
                    _buildCarouselBanner(
                      title: 'Expert Vet Consultations',
                      subtitle: 'Ensure optimal health for your birds.',
                      colors: [
                        Colors.tealAccent.shade700,
                        const Color(0xFF1B5E20),
                      ],
                    ),
                    _buildCarouselBanner(
                      title: 'Sell at the Best Market Price!',
                      subtitle: 'Connect with bulk buyers instantly.',
                      colors: [Colors.blueAccent, Colors.blue],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Top Dashboard Summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E4DA)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🐔 Birds: 500', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 4),
                      Text(
                        '📅 Ready in: 5 days',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '💰 Today Rate: ₹95/kg',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Nearby Demand Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔥 Nearby Buyers',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '– Shop needs 200kg (2 km away)',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '– Shop needs 150kg (5 km away)',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Action Buttons
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  children: [
                    _buildActionButton('🍗 Sell Chicken', () {
                      controller.changePage(1); // Navigates to Sell Tab
                    }),
                    _buildActionButton('🌾 Order Feed', () {
                      Get.snackbar('Navigate', 'Navigating to Order Feed');
                    }),
                    _buildActionButton('🩺 Book Vet', () {
                      controller.changePage(2); // Navigates to Vet Tab
                    }),
                    _buildActionButton('📊 Market Rates', () {
                      controller.changePage(3); // Navigates to Market Rates Tab
                    }),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Obx(() {
      return Container(
        margin: EdgeInsets.only(
          top: statusBarHeight + 16,
          left: 16,
          right: 16,
          bottom: 20,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              offset: const Offset(-2, -2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(4, 4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.4),
            ],
          ),
        ),
        child: controller.isWeatherLoading.value
            ? const Center(
                child: CircularProgressIndicator(color: Colors.black87),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Huge Center Icon
                  if (controller.weatherIcon.value.isNotEmpty)
                    Image.network(
                      'https://openweathermap.org/img/wn/${controller.weatherIcon.value}@4x.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    )
                  else
                    const Icon(Icons.cloud, color: Colors.black87, size: 100),
                  const SizedBox(height: 16),
                  Text(
                    controller.weatherCity.value,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${controller.weatherTemp.value}°',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Mock Days Row to match image
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDayItem('Sun', false),
                      _buildDayItem('Mon', false),
                      _buildDayItem('Tue', true),
                      _buildDayItem('Wed', false),
                      _buildDayItem('Thu', false),
                      _buildDayItem('Fri', false),
                    ],
                  ),
                ],
              ),
      );
    });
  }

  Widget _buildDayItem(String day, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        day,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCarouselBanner({
    required String title,
    required String subtitle,
    required List<Color> colors,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Sponsored',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent, // Off-white
        foregroundColor: Colors.black,
        side: const BorderSide(color: Color(0xFF1B5E20), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }
}
