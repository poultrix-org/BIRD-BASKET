import 'package:flutter/material.dart';
import '../controllers/market_controller.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({Key? key}) : super(key: key);

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final MarketController _controller = MarketController();
  Map<String, dynamic>? _marketData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMarketData();
  }

  Future<void> _loadMarketData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _marketData = null;
    });

    try {
      final data = await _controller.fetchMarketRates();
      if (data.containsKey('error') && data.keys.length == 1) {
        setState(() {
          _error = data['error'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _marketData = data;
          _isLoading = false;
          if (data.containsKey('error')) {
            // we have cache + error
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(data['error'])));
          }
        });
      }
    } catch (e) {
      setState(() {
        _error = "Failed to load market data: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Market Rates',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.teal),
            onPressed: _isLoading ? null : _loadMarketData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _marketData == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.teal));
    }

    if (_error != null && _marketData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Unknown error occurred.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMarketData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_marketData == null) {
      return const Center(child: Text("No Data Available"));
    }

    final data = _marketData!;
    final locationName = data['location'] ?? 'Unknown';

    // Manual date formatting
    final now = DateTime.now();
    final List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final List<String> weekdays = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    final String dateStr =
        "${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}";

    // Insights logic
    List<double> trendData =
        (data['trend_data'] as List?)?.cast<double>() ?? [];
    String insightText = "Market is stable.";
    Color insightColor = Colors.grey;
    if (trendData.length >= 2) {
      double latest = trendData.last;
      double previous = trendData[trendData.length - 2];
      if (latest > previous) {
        insightText = "Prices increasing → Good time to sell!";
        insightColor = Colors.green;
      } else if (latest < previous) {
        insightText = "Prices decreasing → Wait before selling.";
        insightColor = Colors.orange;
      }
    } else if (trendData.isNotEmpty && data['avg_broiler_rate'] != null) {
      double latest = data['avg_broiler_rate'];
      double previous = data['yesterday_broiler'] ?? latest;
      if (latest > previous) {
        insightText = "Prices increasing → Good time to sell!";
        insightColor = Colors.green;
      } else if (latest < previous) {
        insightText = "Prices decreasing → Wait before selling.";
        insightColor = Colors.orange;
      }
    }

    return RefreshIndicator(
      onRefresh: _loadMarketData,
      color: Colors.teal,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Location & Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          locationName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Sources: ${data['sources_count'] ?? 0}",
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Rate Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildRateCard(
                  "Broiler",
                  data['avg_broiler_rate'],
                  data['yesterday_broiler'],
                  "₹/kg",
                ),
                _buildRateCard(
                  "Egg",
                  data['avg_egg_rate'],
                  data['yesterday_egg'],
                  "₹/piece",
                ),
                _buildRateCard(
                  "Feed",
                  data['avg_feed_rate'],
                  data['yesterday_feed'],
                  "₹/bag",
                ),
                _buildRateCard(
                  "Chick",
                  data['avg_chick_rate'],
                  data['yesterday_chick'],
                  "₹/chick",
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Market Insight Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: insightColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: insightColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: insightColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insightText,
                      style: TextStyle(
                        color: insightColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Simple Trend Chart (Bar Chart)
            const Text(
              "7-Day Broiler Trend (₹)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTrendChart(trendData),
            const SizedBox(height: 24),

            // Last Updated Timestamp
            Center(
              child: Builder(
                builder: (context) {
                  if (data['last_updated'] == null)
                    return const SizedBox.shrink();
                  final dt = DateTime.parse(data['last_updated']);
                  final String ampm = dt.hour >= 12 ? 'PM' : 'AM';
                  final int hr = dt.hour > 12
                      ? dt.hour - 12
                      : (dt.hour == 0 ? 12 : dt.hour);
                  final String minute = dt.minute.toString().padLeft(2, '0');

                  return Text(
                    "Last updated: $hr:$minute $ampm",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRateCard(
    String title,
    double? current,
    double? yesterday,
    String unit,
  ) {
    if (current == null) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Text(
                "N/A",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    double diff = yesterday != null ? current - yesterday : 0;
    bool isUp = diff > 0;
    bool isDown = diff < 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (diff != 0)
                  Icon(
                    isUp ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isUp ? Colors.green : Colors.red,
                    size: 16,
                  ),
              ],
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "₹${current.toStringAsFixed(title == 'Egg' ? 2 : 0)}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            if (diff != 0)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  "${isUp ? '+' : ''}${diff.toStringAsFixed(title == 'Egg' ? 2 : 0)} vs yesterday",
                  style: TextStyle(
                    fontSize: 11,
                    color: isUp ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(List<double> data) {
    if (data.isEmpty || data.every((val) => val == 0)) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text("Not enough data for chart")),
      );
    }

    double maxVal = data.reduce((a, b) => a > b ? a : b);
    double minVal = data.reduce((a, b) => a < b ? a : b);

    // Add small buffer to avoid items being 100% or 0% exactly, and divide by zero protection
    if (maxVal == minVal) {
      maxVal += 1;
      minVal -= 1;
    }

    double range = maxVal - minVal;

    return Container(
      height: 160,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (index) {
          double val = data[index];
          // height percentage from 0.1 to 1.0 based on min/max
          double percentage = ((val - minVal) / range);
          if (percentage < 0.1) percentage = 0.1; // minimum height

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                val.toInt().toString(),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 30,
                height: 100 * percentage,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              // We just map the index backwards to days e.g., "Day -6" for earliest
              Text(
                index == data.length - 1
                    ? "Today"
                    : "D-${(data.length - 1) - index}",
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          );
        }),
      ),
    );
  }
}
