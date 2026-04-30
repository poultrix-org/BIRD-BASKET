class MarketRateModel {
  final String rateId;
  final String locationName;
  final double latitude;
  final double longitude;
  final double? broilerRate;
  final double? eggRate;
  final double? feedRate;
  final double? chickRate;
  final String source;
  final DateTime createdAt;

  MarketRateModel({
    required this.rateId,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    this.broilerRate,
    this.eggRate,
    this.feedRate,
    this.chickRate,
    required this.source,
    required this.createdAt,
  });

  factory MarketRateModel.fromJson(Map<String, dynamic> json) {
    return MarketRateModel(
      rateId: json['rate_id']?.toString() ?? '',
      locationName: json['location_name']?.toString() ?? 'Unknown',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      broilerRate: json['broiler_rate'] != null
          ? double.tryParse(json['broiler_rate'].toString())
          : null,
      eggRate: json['egg_rate'] != null
          ? double.tryParse(json['egg_rate'].toString())
          : null,
      feedRate: json['feed_rate'] != null
          ? double.tryParse(json['feed_rate'].toString())
          : null,
      chickRate: json['chick_rate'] != null
          ? double.tryParse(json['chick_rate'].toString())
          : null,
      source: json['source']?.toString() ?? 'farmer',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }
}

class MarketAggregationData {
  final String location;
  final double? avgBroilerRate;
  final double? avgEggRate;
  final double? avgFeedRate;
  final double? avgChickRate;
  final int sourcesCount;
  final List<double> trendData;
  final DateTime lastUpdated;

  final double? yesterdayBroilerRate;
  final double? yesterdayEggRate;
  final double? yesterdayFeedRate;
  final double? yesterdayChickRate;

  MarketAggregationData({
    required this.location,
    this.avgBroilerRate,
    this.avgEggRate,
    this.avgFeedRate,
    this.avgChickRate,
    required this.sourcesCount,
    required this.trendData,
    required this.lastUpdated,
    this.yesterdayBroilerRate,
    this.yesterdayEggRate,
    this.yesterdayFeedRate,
    this.yesterdayChickRate,
  });
}
