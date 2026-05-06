import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import 'dart:async';

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
          // Farm Banner Header & Search Bar Overlay
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              _buildFarmHeader(context),
              Positioned(
                bottom: -30, // Centered on the video edge (half of the 60px height)
                left: 16,
                right: 16,
                child: const AnimatedSearchBar(),
              ),
            ],
          ),

          // Content area below header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), // Reduced top padding to close the gap
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Square Ads Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.05, // Slightly wider than tall
                  children: [
                    _buildSquareAd(
                      title: 'Order\nFeed',
                      bgColor: const Color(0xFFEADBFC), // Pastel Purple
                      icon: Icons.shopping_basket_outlined,
                      imagePath: 'assets/images/order feeds.png'
                    ),
                    _buildSquareAd(
                      title: 'See\nBuyers',
                      bgColor: const Color(0xFFF9C8D9), // Pastel Pink
                      icon: Icons.trending_up,
                      imagePath: 'assets/images/see buyers.png'
                    ),
                    _buildSquareAd(
                      title: 'See\'s Everyday\nRate',
                      bgColor: const Color(0xFFFDE0D9), // Pastel Peach
                      icon: Icons.currency_rupee,
                      imagePath: 'assets/images/hen sales.png',
                      textColor: Colors.black, // Set to black for visibility over light image
                    ),
                    _buildSquareAd(
                      title: 'Increase\nProductivity',
                      bgColor: const Color(0xFFFFF2D8), // Pastel Yellow
                      icon: Icons.medical_services_outlined,
                      imagePath: 'assets/images/Productivity.png',
                      textColor: Colors.black, // Set to black for visibility over light image
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildHotDemandSection(),
                const SizedBox(height: 32),
                const MarketTrendGraph(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmHeader(BuildContext context) {
    // Extract first name or use default
    String rawName = controller.user.fullName ?? 'FARMER';
    String firstName = rawName.split(' ').first.toUpperCase();
    if (firstName.isEmpty) firstName = 'FARMER';

    return FarmVideoHeader(firstName: firstName);
  }

  Widget _buildSquareAd({
    required String title,
    required Color bgColor,
    required IconData icon,
    String? imagePath,
    Color textColor = Colors.white,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24), // Highly rounded corners
              image: imagePath != null && imagePath.isNotEmpty
                  ? DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.1), // Match circle background to text color
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: textColor, // Set icon color to match text color
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            title,
            style: GoogleFonts.montserrat(
              color: Colors.black87, // Dark text since it's outside on the white background
              fontSize: 15,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHotDemandSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'HOT Demand',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: Colors.red, // Requested red title
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.green),
              onPressed: () {
                // Refresh logic
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250, // Increased height to prevent pixel overflow
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              _buildDemandCard('Hotel Taj', 'Needs 200kg Broiler', 'Premium', 'assets/images/brolier.png'),
              const SizedBox(width: 8),
              _buildDemandCard('Fresh Mart', 'Needs 500 Eggs', 'Immediate', 'assets/images/eggs.png'),
              const SizedBox(width: 8),
              _buildDemandCard('Local Market', 'Needs 50 Country Chicken', 'Bulk', 'assets/images/country chicken.png'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDemandCard(String title, String subtitle, String tag, String fallbackImage) {
    return SizedBox(
      width: 140, // Narrower width for circular Swiggy-style dish items
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image floating directly without a background card or shadow
          Center(
            child: Image.asset(
              fallbackImage,
              height: 120,
              width: 120,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 8),
          // Badge moved below the image
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Text(
            title, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle, 
            style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold), // Requested green bold text
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class FarmVideoHeader extends StatefulWidget {
  final String firstName;

  const FarmVideoHeader({super.key, required this.firstName});

  @override
  State<FarmVideoHeader> createState() => _FarmVideoHeaderState();
}

class _FarmVideoHeaderState extends State<FarmVideoHeader> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/10685-226624850_medium.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0); // Mute background video by default
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 250,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Video
          if (_controller.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
          else
            Container(color: Colors.black87),

          // Dark overlay to ensure text readability
          Container(
            color: Colors.black.withValues(alpha: 0.3),
          ),
          
          // Farm Typography Overlay
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.firstName}\nCHICKEN\nFARM',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedSearchBar extends StatefulWidget {
  const AnimatedSearchBar({super.key});

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  final TextEditingController _controller = TextEditingController();
  int _currentIndex = 0;
  Timer? _timer;
  final List<String> _hints = ['feeds', 'vets', 'track', 'orders'];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _hints.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60, // Increased height to make it bigger and fill the gap
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30), // Match the new height for perfectly rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Animated Hint
          Positioned(
            left: 52, // Shifted slightly right to clear the cursor
            right: 48,
            top: 0,
            bottom: 0,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, child) {
                if (value.text.isNotEmpty) {
                  return const SizedBox.shrink();
                }
                return IgnorePointer(
                  child: Row(
                    children: [
                      const Text('Search for ', style: TextStyle(color: Colors.black54, fontSize: 16)), // Matched TextField default font size
                      ClipRect(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.8),
                                end: Offset.zero,
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            _hints[_currentIndex],
                            key: ValueKey<int>(_currentIndex),
                            style: const TextStyle(color: Colors.black54, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Actual TextField
          TextField(
            controller: _controller,
            cursorColor: Colors.black87,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.black54),
              suffixIcon: Icon(Icons.mic, color: Colors.black54),
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class MarketTrendGraph extends StatefulWidget {
  const MarketTrendGraph({super.key});

  @override
  State<MarketTrendGraph> createState() => _MarketTrendGraphState();
}

class _MarketTrendGraphState extends State<MarketTrendGraph> {
  String selectedFilter = 'Broiler';
  final List<String> filters = ['Broiler', 'Egg', 'Country Chicken'];

  String selectedTimeFilter = '1W';
  final List<String> timeFilters = ['1W', '1M', '1Y', 'Today'];
  DateTimeRange? customDateRange;

  // Helper to generate dynamic mock data based on selected category and time
  List<FlSpot> _getSpots(String filter, String timeFrame) {
    if (filter == 'Broiler') { // Range 100 to 600
      if (timeFrame == 'Today') return const [FlSpot(0, 100), FlSpot(1, 120), FlSpot(2, 110), FlSpot(3, 115), FlSpot(4, 130), FlSpot(5, 140), FlSpot(6, 135)];
      if (timeFrame == '1W') return const [FlSpot(0, 600), FlSpot(1, 550), FlSpot(2, 500), FlSpot(3, 400), FlSpot(4, 450), FlSpot(5, 300), FlSpot(6, 100)]; // Down trend to show red
      if (timeFrame == '1M') return const [FlSpot(0, 100), FlSpot(1, 200), FlSpot(2, 150), FlSpot(3, 300), FlSpot(4, 400), FlSpot(5, 350), FlSpot(6, 600)];
      return const [FlSpot(0, 300), FlSpot(1, 300), FlSpot(2, 300), FlSpot(3, 300), FlSpot(4, 300), FlSpot(5, 300), FlSpot(6, 300)];
    } else if (filter == 'Egg') { // Range 1 to 15 (1, 5, 7, 9, 10, 13, 15)
      if (timeFrame == 'Today') return const [FlSpot(0, 5), FlSpot(1, 5), FlSpot(2, 7), FlSpot(3, 7), FlSpot(4, 9), FlSpot(5, 9), FlSpot(6, 10)];
      if (timeFrame == '1W') return const [FlSpot(0, 1), FlSpot(1, 5), FlSpot(2, 7), FlSpot(3, 9), FlSpot(4, 10), FlSpot(5, 13), FlSpot(6, 15)];
      if (timeFrame == '1M') return const [FlSpot(0, 15), FlSpot(1, 13), FlSpot(2, 10), FlSpot(3, 9), FlSpot(4, 7), FlSpot(5, 5), FlSpot(6, 1)];
      return const [FlSpot(0, 7), FlSpot(1, 7), FlSpot(2, 7), FlSpot(3, 7), FlSpot(4, 7), FlSpot(5, 7), FlSpot(6, 7)];
    } else { // Country Chicken, Range 100 to 700
      if (timeFrame == 'Today') return const [FlSpot(0, 200), FlSpot(1, 210), FlSpot(2, 220), FlSpot(3, 215), FlSpot(4, 250), FlSpot(5, 260), FlSpot(6, 300)];
      if (timeFrame == '1W') return const [FlSpot(0, 100), FlSpot(1, 200), FlSpot(2, 300), FlSpot(3, 400), FlSpot(4, 500), FlSpot(5, 600), FlSpot(6, 700)];
      if (timeFrame == '1M') return const [FlSpot(0, 700), FlSpot(1, 600), FlSpot(2, 500), FlSpot(3, 400), FlSpot(4, 300), FlSpot(5, 200), FlSpot(6, 100)];
      return const [FlSpot(0, 400), FlSpot(1, 400), FlSpot(2, 400), FlSpot(3, 400), FlSpot(4, 400), FlSpot(5, 400), FlSpot(6, 400)];
    }
  }

  // Trend color based on the spots array
  Color _getTrendColor(List<FlSpot> spots) {
    if (spots.isEmpty) return Colors.blue;
    double firstY = spots.first.y;
    double lastY = spots.last.y;
    if (lastY > firstY) return Colors.green;
    if (lastY < firstY) return Colors.red;
    return Colors.blue;
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1B5E20),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        customDateRange = picked;
        selectedTimeFilter = 'Custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final spots = _getSpots(selectedFilter, selectedTimeFilter);
    final trendColor = _getTrendColor(spots);

    // Calculate Y-axis properties dynamically
    double minY = 0;
    double maxY = 100;
    double intervalY = 20;

    if (selectedFilter == 'Broiler') {
      minY = 0;
      maxY = 600;
      intervalY = 100;
    } else if (selectedFilter == 'Egg') {
      minY = 0;
      maxY = 16;
      intervalY = 2; // Better distribution for 1,5,7,9,10,13,15
    } else {
      minY = 0;
      maxY = 700;
      intervalY = 100;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live Market Trend'.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: const Color(0xFF1B5E20),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        // Filter Chips - Categories
        Row(
          children: filters.map((filter) {
            final isSelected = selectedFilter == filter;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: filter == filters.last ? 0 : 8.0),
                child: ChoiceChip(
                  label: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        filter,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF1B5E20),
                  backgroundColor: Colors.grey.shade200,
                  showCheckmark: isSelected, // Keeps the elegant checkmark
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  labelStyle: TextStyle(
                     color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    }
                  },
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        // Time Filters and Date Picker
        Row(
          children: [
            Expanded(
              child: Row(
                children: timeFilters.map((time) {
                  final isSelected = selectedTimeFilter == time;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: time == timeFilters.last ? 0 : 6.0),
                      child: ChoiceChip(
                        label: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(time, style: const TextStyle(fontSize: 13)),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: Colors.black87,
                        backgroundColor: Colors.white,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedTimeFilter = time;
                              customDateRange = null; // Reset custom date if pre-set time is selected
                            });
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            IconButton(
              icon: Icon(Icons.calendar_month, color: selectedTimeFilter == 'Custom' ? const Color(0xFF1B5E20) : Colors.black54),
              onPressed: _selectCustomDateRange,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(Colors.green, 'Increased'),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.red, 'Decreased'),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.blue, 'Unchanged'),
          ],
        ),
        const SizedBox(height: 24),
        // Chart container (White BG with Dashed Lines)
        Container(
          height: 340, // Increased height for a bigger chart
          padding: const EdgeInsets.fromLTRB(0, 24, 16, 16), // Minimized left padding
          child: LineChart(
            LineChartData(
              minX: -0.2, // Prevents dots from overlapping Y-axis numbers
              maxX: 6.2,
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                drawHorizontalLine: true,
                horizontalInterval: intervalY,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                    dashArray: [5, 5], // Dashed lines
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                    dashArray: [5, 5], // Dashed lines
                  );
                },
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    if (touchedSpots.isEmpty) return [];
                    return touchedSpots.map((spot) {
                      // Only return tooltip for the first bar that matches to avoid duplicate overlapping tooltips
                      if (spot.barIndex == touchedSpots.first.barIndex) {
                        return LineTooltipItem(
                          '₹${spot.y.toInt()}',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      }
                      return null;
                    }).toList().cast<LineTooltipItem?>();
                  },
                ),
                handleBuiltInTouches: true,
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28, // Minimized gap
                    interval: intervalY,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 4.0), // Reduced spacing
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1, // Forces integer indexes to prevent messy/overlapping dates
                    getTitlesWidget: (value, meta) {
                      if (value % 1 != 0) return const SizedBox(); // Ensure only exact integer dates show up
                      
                      const days = ['Jan 25', 'Jan 26', 'Jan 27', 'Jan 28', 'Jan 29', 'Jan 30', 'Jan 31'];
                      if (value.toInt() >= 0 && value.toInt() < days.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            days[value.toInt()], 
                            style: const TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.w600)
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: _buildLineBars(spots),
            ),
          ),
        ),
      ],
    );
  }

  // Generate a separate line bar for each segment so the line changes color if it goes up or down
  List<LineChartBarData> _buildLineBars(List<FlSpot> spots) {
    List<LineChartBarData> bars = [];
    if (spots.isEmpty) return bars;

    for (int i = 0; i < spots.length - 1; i++) {
      FlSpot current = spots[i];
      FlSpot next = spots[i + 1];

      Color segmentColor;
      if (next.y > current.y) {
        segmentColor = Colors.green;
      } else if (next.y < current.y) {
        segmentColor = Colors.red;
      } else {
        segmentColor = Colors.blue;
      }

      bars.add(
        LineChartBarData(
          spots: [current, next],
          isCurved: false,
          color: segmentColor,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            checkToShowDot: (spot, barData) {
              if (i == spots.length - 2) return true; // Show both dots on the very last segment
              return spot.x == current.x; // Show only the start dot for other segments to prevent double-drawing
            },
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: segmentColor,
              );
            },
          ),
        ),
      );
    }
    return bars;
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
