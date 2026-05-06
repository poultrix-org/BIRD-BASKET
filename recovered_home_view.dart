// // views/farmers_home_view.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import 'package:carousel_slider/carousel_slider.dart';
//
// import '../controllers/farmers_home_controller.dart';
// import '../../profile/views/farmer_profile_view.dart';
// import '../../sell/views/sell_chicken_view.dart';
// import '../../vet/views/vet_home_view.dart';
// import '../../market/views/market_view.dart';
// import '../../alerts/views/alerts_view.dart';
//
// class FarmersHomeView extends StatelessWidget {
//   final FarmersHomeController controller = Get.put(FarmersHomeController());
//
//   FarmersHomeView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F8F3),
//       body: Stack(
//         children: [
//           // Elegant Pattern Background Layer
//           Positioned.fill(
//             child: Opacity(
//               opacity: 0.35, // Increased opacity so it's more visible
//               child: Image.asset(
//                 'assets/images/pattern.png',
//                 repeat: ImageRepeat.repeat,
//               ),
//             ),
//           ),
//           SafeArea(
//             child: Obx(() {
//               switch (controller.currentIndex.value) {
//                 case 0:
//                   return _buildHomeContent(context);
//                 case 1:
//                   return SellChickenView();
//                 case 2:
//                   return VetHomeView();
//                 case 3:
//                   return MarketView();
//                 case 4:
//                   return AlertsView();
//                 default:
//                   return _buildHomeContent(context);
//               }
//             }),
//           ),
//         ],
//       ),
//       bottomNavigationBar: Obx(
//         () => BottomNavigationBar(
//           type: BottomNavigationBarType.fixed,
//           backgroundColor: const Color(0xFFF7F8F3), // Off-white
//           selectedIconTheme: const IconThemeData(color: Color(0xFF1E2019)),
//           unselectedIconTheme: const IconThemeData(color: Colors.grey),
//           selectedItemColor: Colors.black,
//           unselectedItemColor: Colors.black54,
//           selectedLabelStyle: const TextStyle(
//             fontFamily: 'Times New Roman',
//             fontWeight: FontWeight.bold,
//             fontSize: 10,
//           ),
//           unselectedLabelStyle: const TextStyle(
//             fontFamily: 'Times New Roman',
//             fontSize: 10,
//           ),
//           currentIndex: controller.currentIndex.value,
//           onTap: controller.changePage,
//           items: const [
//             BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.storefront),
//               label: 'Sell',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.medical_services),
//               label: 'Vet',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.trending_up),
//               label: 'Market',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.notifications),
//               label: 'Alerts',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHomeContent(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header with Welcome and Profile Icon
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Welcome, ${controller.user.fullName}!',
//                 style: const TextStyle(
//                   fontFamily: 'Times New Roman',
//                   fontWeight: FontWeight.bold,
//                   fontSize: 22,
//                 ),
//               ),
//               InkWell(
//                 onTap: () {
//                   Get.to(() => FarmerProfileView(user: controller.user));
//                 },
//                 child: const CircleAvatar(
//                   backgroundColor: Colors.teal,
//                   radius: 20,
//                   child: Icon(Icons.person, color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//
//           // Sponsored Banner Carousel (Swiggy Style)
//           CarouselSlider(
//             options: CarouselOptions(
//               height: 170.0,
//               autoPlay: true,
//               autoPlayInterval: const Duration(seconds: 2),
//               autoPlayAnimationDuration: const Duration(milliseconds: 800),
//               autoPlayCurve: Curves.fastOutSlowIn,
//               viewportFraction: 1.0,
//             ),
//             items: [
//               _buildCarouselBanner(
//                 title: 'Get 20% off on Premium Feed!',
//                 subtitle: 'Limited time offer. Tap to order now.',
//                 colors: [Colors.orangeAccent, Colors.deepOrange],
//               ),
//               _buildCarouselBanner(
//                 title: 'Expert Vet Consultations',
//                 subtitle: 'Ensure optimal health for your birds.',
//                 colors: [Colors.tealAccent.shade400, Colors.teal],
//               ),
//               _buildCarouselBanner(
//                 title: 'Sell at the Best Market Price!',
//                 subtitle: 'Connect with bulk buyers instantly.',
//                 colors: [Colors.blueAccent, Colors.blue],
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),
//
//           // Top Dashboard Summary
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             child: const Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '🐔 Birds: 500',
//                   style: TextStyle(fontFamily: 'Times New Roman', fontSize: 16),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   '📅 Ready in: 5 days',
//                   style: TextStyle(fontFamily: 'Times New Roman', fontSize: 16),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   '💰 Today Rate: ₹95/kg',
//                   style: TextStyle(fontFamily: 'Times New Roman', fontSize: 16),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//
//           // Nearby Demand Section
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.red.shade50,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.red.shade200),
//             ),
//             child: const Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '🔥 Nearby Buyers',
//                   style: TextStyle(
//                     fontFamily: 'Times New Roman',
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                     color: Colors.red,
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 Text(
//                   '– Shop needs 200kg (2 km away)',
//                   style: TextStyle(fontFamily: 'Times New Roman', fontSize: 16),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   '– Shop needs 150kg (5 km away)',
//                   style: TextStyle(fontFamily: 'Times New Roman', fontSize: 16),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//
//           // Quick Action Buttons
//           const Text(
//             'Quick Actions',
//             style: TextStyle(
//               fontFamily: 'Times New Roman',
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//             ),
//           ),
//           const SizedBox(height: 12),
//           GridView.count(
//             crossAxisCount: 2,
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             crossAxisSpacing: 12,
//             mainAxisSpacing: 12,
//             childAspectRatio: 2.5,
//             children: [
//               _buildActionButton('🍗 Sell Chicken', () {
//                 controller.changePage(1); // Navigates to Sell Tab
//               }),
//               _buildActionButton('🌾 Order Feed', () {
//                 Get.snackbar('Navigate', 'Navigating to Order Feed');
//               }),
//               _buildActionButton('🩺 Book Vet', () {
//                 controller.changePage(2); // Navigates to Vet Tab
//               }),
//               _buildActionButton('📊 Market Rates', () {
//                 controller.changePage(3); // Navigates to Market Rates Tab
//               }),
//             ],
//           ),
//           const SizedBox(height: 24),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCarouselBanner({
//     required String title,
//     required String subtitle,
//     required List<Color> colors,
//   }) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.symmetric(horizontal: 4.0),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(colors: colors),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Text(
//             'Sponsored',
//             style: TextStyle(
//               fontFamily: 'Times New Roman',
//               color: Colors.white70,
//               fontSize: 13,
//               letterSpacing: 1.1,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             title,
//             style: const TextStyle(
//               fontFamily: 'Times New Roman',
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 20,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             subtitle,
//             style: const TextStyle(
//               fontFamily: 'Times New Roman',
//               color: Colors.white,
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButton(String label, VoidCallback onTap) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: const Color(0xFFF7F8F3), // Off-white
//         foregroundColor: Colors.black,
//         side: BorderSide(color: Colors.teal.shade200),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         elevation: 0,
//       ),
//       onPressed: onTap,
//       child: Text(
//         label,
//         style: const TextStyle(
//           fontFamily: 'Times New Roman',
//           fontWeight: FontWeight.bold,
//           fontSize: 14,
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }