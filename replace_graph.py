import sys

with open('/Users/nandhaprabhur/Desktop/BIRD-BASKET/lib/screens/farmers/home/views/farmers_home_view.dart', 'r') as f:
    lines = f.readlines()

# Find start and end
start_idx = -1
end_idx = -1

for i, line in enumerate(lines):
    if line.startswith('class _MarketTrendGraphState extends State<MarketTrendGraph> {'):
        start_idx = i
    if start_idx != -1 and line.startswith('}'):
        end_idx = i

if start_idx == -1 or end_idx == -1:
    print("Could not find _MarketTrendGraphState class")
    sys.exit(1)

new_code = """class _MarketTrendGraphState extends State<MarketTrendGraph> {
  String selectedFilter = 'Broiler';
  final List<String> filters = ['Broiler', 'Egg', 'Country Chicken'];

  String selectedTimeFilter = '1W';
  final List<String> timeFilters = ['1W', '1M', '1Y'];
  DateTimeRange? customDateRange;

  // Helper to generate dynamic mock data based on selected category and time
  List<FlSpot> _getSpots(String filter, String timeFrame) {
    if (filter == 'Broiler') { // Range 100 to 600
      if (timeFrame == '1W') return const [FlSpot(0, 100), FlSpot(1, 200), FlSpot(2, 150), FlSpot(3, 300), FlSpot(4, 400), FlSpot(5, 350), FlSpot(6, 600)];
      if (timeFrame == '1M') return const [FlSpot(0, 600), FlSpot(1, 500), FlSpot(2, 450), FlSpot(3, 350), FlSpot(4, 300), FlSpot(5, 200), FlSpot(6, 100)];
      return const [FlSpot(0, 300), FlSpot(1, 300), FlSpot(2, 300), FlSpot(3, 300), FlSpot(4, 300), FlSpot(5, 300), FlSpot(6, 300)];
    } else if (filter == 'Egg') { // Range 1 to 15 (1, 5, 7, 9, 10, 13, 15)
      if (timeFrame == '1W') return const [FlSpot(0, 1), FlSpot(1, 5), FlSpot(2, 7), FlSpot(3, 9), FlSpot(4, 10), FlSpot(5, 13), FlSpot(6, 15)];
      if (timeFrame == '1M') return const [FlSpot(0, 15), FlSpot(1, 13), FlSpot(2, 10), FlSpot(3, 9), FlSpot(4, 7), FlSpot(5, 5), FlSpot(6, 1)];
      return const [FlSpot(0, 7), FlSpot(1, 7), FlSpot(2, 7), FlSpot(3, 7), FlSpot(4, 7), FlSpot(5, 7), FlSpot(6, 7)];
    } else { // Country Chicken, Range 100 to 700
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
        const Text(
          'Live Market Trend',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // Filter Chips - Categories
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((filter) {
              final isSelected = selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  selectedColor: const Color(0xFF1B5E20),
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: TextStyle(
                     color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        // Time Filters and Date Picker
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: timeFilters.map((time) {
                    final isSelected = selectedTimeFilter == time;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(time, style: const TextStyle(fontSize: 12)),
                        selected: isSelected,
                        selectedColor: Colors.black87,
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade300),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
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
                    );
                  }).toList(),
                ),
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
          height: 280,
          padding: const EdgeInsets.fromLTRB(8, 24, 24, 16), // Adjusted padding
          child: LineChart(
            LineChartData(
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
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '₹${spot.y.toInt()}',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    }).toList();
                  },
                ),
                handleBuiltInTouches: true,
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: intervalY,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
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
                    getTitlesWidget: (value, meta) {
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
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: false,
                  color: trendColor, // Dynamic color
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, barData) {
                      // Show dots on max and min points (first and last)
                      return spot.x == spots.first.x || spot.x == spots.last.x; 
                    },
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: trendColor,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
"""

lines[start_idx:end_idx+1] = [new_code]

with open('/Users/nandhaprabhur/Desktop/BIRD-BASKET/lib/screens/farmers/home/views/farmers_home_view.dart', 'w') as f:
    f.writelines(lines)

print("Replaced successfully")
