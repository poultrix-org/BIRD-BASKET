class MarketRateModel {
  final String rateId;
  final String locationName;
  final double latitude;
  final double longitude;
  final double broilerRate;
  final double eggRate;
  final double feedRate;
  final double chickRate;
  final DateTime createdAt;

  MarketRateModel({
    required this.rateId,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.broilerRate,
    required this.eggRate,
    required this.feedRate,
    required this.chickRate,
    required this.createdAt,
  });

  factory MarketRateModel.fromJson(Map<String, dynamic> json) {
    return MarketRateModel(
      rateId: json['rate_id'] ?? '',
      locationName: json['location_name'] ?? 'Unknown',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      broilerRate: (json['broiler_rate'] ?? 0.0).toDouble(),
      eggRate: (json['egg_rate'] ?? 0.0).toDouble(),
      feedRate: (json['feed_rate'] ?? 0.0).toDouble(),
      chickRate: (json['chick_rate'] ?? 0.0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rate_id': rateId,
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'broiler_rate': broilerRate,
      'egg_rate': eggRate,
      'feed_rate': feedRate,
      'chick_rate': chickRate,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
