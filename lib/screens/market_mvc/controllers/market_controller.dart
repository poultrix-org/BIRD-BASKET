import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/market_rate_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MarketController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. LOCATION (Get user current location)
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  // Calculate distance using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double p = 0.017453292519943295; // Math.PI / 180
    double a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;

    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  // 2. FETCH MARKET DATA and apply aggregation logic.
  Future<Map<String, dynamic>> fetchMarketRates() async {
    try {
      // Step 1: Get Current Location
      Position? position;
      try {
        position = await getCurrentLocation();
      } catch (e) {
        // fallback if location fails
        return _getFallbackData(e.toString());
      }

      if (position == null)
        return _getFallbackData("Could not determine location");

      final double userLat = position.latitude;
      final double userLon = position.longitude;

      // Step 2 & 8: Fetch all records from Supabase "market_rates"
      final currentResponse = await _supabase
          .from('market_rates')
          .select()
          .gte(
            'created_at',
            DateTime.now()
                .subtract(const Duration(hours: 24))
                .toIso8601String(),
          );

      final yesterdayResponse = await _supabase
          .from('market_rates')
          .select()
          .gte(
            'created_at',
            DateTime.now()
                .subtract(const Duration(hours: 48))
                .toIso8601String(),
          )
          .lt(
            'created_at',
            DateTime.now()
                .subtract(const Duration(hours: 24))
                .toIso8601String(),
          );

      List<MarketRateModel> currentRates = (currentResponse as List)
          .map((data) => MarketRateModel.fromJson(data))
          .toList();

      List<MarketRateModel> yesterdayRates = (yesterdayResponse as List)
          .map((data) => MarketRateModel.fromJson(data))
          .toList();

      // Step 2 cont: Filter nearest data using distance calculation (< 50km)
      List<MarketRateModel> nearestCurrent = _getNearestRates(
        currentRates,
        userLat,
        userLon,
        50.0,
      );
      List<MarketRateModel> nearestYesterday = _getNearestRates(
        yesterdayRates,
        userLat,
        userLon,
        50.0,
      );

      // Step 3 & 8: Aggregation Logic (Prioritize necc for egg)
      Map<String, dynamic> todayStats = _aggregateRates(nearestCurrent);
      Map<String, dynamic> yesterdayStats = _aggregateRates(nearestYesterday);

      // Step 4: Trend Calculation (last 7 days)
      List<double> weeklyTrend = await getWeeklyTrend(userLat, userLon, 50.0);

      // Determine location name based on nearest record or default
      String locationName = "Unknown";
      if (nearestCurrent.isNotEmpty) {
        locationName = nearestCurrent.first.locationName;
      }

      // Step 5: RESPONSE STRUCTURE
      Map<String, dynamic> result = {
        "location": locationName,
        "avg_broiler_rate": todayStats['avg_broiler'],
        "avg_egg_rate": todayStats['avg_egg'],
        "avg_feed_rate": todayStats['avg_feed'],
        "avg_chick_rate": todayStats['avg_chick'],
        "sources_count": todayStats['count'],
        "trend_data": weeklyTrend,
        "last_updated": DateTime.now().toIso8601String(),
        // Adding yesterday stats for UI trend arrows
        "yesterday_broiler": yesterdayStats['avg_broiler'],
        "yesterday_egg": yesterdayStats['avg_egg'],
        "yesterday_feed": yesterdayStats['avg_feed'],
        "yesterday_chick": yesterdayStats['avg_chick'],
      };

      // Bonus: Cache last data locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('market_data_cache', jsonEncode(result));
      return result;
    } catch (e) {
      // Fallback to cache if error occurs
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('market_data_cache');
      if (cached != null) {
        Map<String, dynamic> data = jsonDecode(cached);
        data['error'] = 'Loaded from cache: ${e.toString()}';
        return data;
      }
      return {"error": e.toString()};
    }
  }

  List<MarketRateModel> _getNearestRates(
    List<MarketRateModel> allRates,
    double userLat,
    double userLon,
    double maxDistanceKm,
  ) {
    return allRates.where((rate) {
      double distance = _calculateDistance(
        userLat,
        userLon,
        rate.latitude,
        rate.longitude,
      );
      return distance <= maxDistanceKm;
    }).toList();
  }

  Map<String, dynamic> _aggregateRates(List<MarketRateModel> rates) {
    if (rates.isEmpty) {
      return {
        'avg_broiler': null,
        'avg_egg': null,
        'avg_feed': null,
        'avg_chick': null,
        'count': 0,
      };
    }

    double broilerSum = 0;
    int broilerCount = 0;
    double eggSum = 0;
    int eggCount = 0;
    double feedSum = 0;
    int feedCount = 0;
    double chickSum = 0;
    int chickCount = 0;

    double? neccEggRate; // Priority for NECC egg data

    for (var rate in rates) {
      if (rate.broilerRate != null) {
        broilerSum += rate.broilerRate!;
        broilerCount++;
      }

      if (rate.eggRate != null) {
        if (rate.source.toLowerCase() == 'necc') {
          neccEggRate = rate.eggRate;
        }
        eggSum += rate.eggRate!;
        eggCount++;
      }

      if (rate.feedRate != null) {
        feedSum += rate.feedRate!;
        feedCount++;
      }
      if (rate.chickRate != null) {
        chickSum += rate.chickRate!;
        chickCount++;
      }
    }

    double? finalEggRate;
    if (neccEggRate != null) {
      finalEggRate = neccEggRate;
    } else if (eggCount > 0) {
      finalEggRate = eggSum / eggCount;
    }

    return {
      'avg_broiler': broilerCount > 0 ? (broilerSum / broilerCount) : null,
      'avg_egg': finalEggRate,
      'avg_feed': feedCount > 0 ? (feedSum / feedCount) : null,
      'avg_chick': chickCount > 0 ? (chickSum / chickCount) : null,
      'count': rates.length,
    };
  }

  Future<List<double>> getWeeklyTrend(
    double lat,
    double lon,
    double maxDistanceKm,
  ) async {
    try {
      final lastWeek = DateTime.now().subtract(const Duration(days: 7));
      final response = await _supabase
          .from('market_rates')
          .select()
          .gte('created_at', lastWeek.toIso8601String())
          .not(
            'broiler_rate',
            'is',
            null,
          ) // Only get rates that have broiler rate
          .order('created_at', ascending: true);

      List<MarketRateModel> weekRates = (response as List)
          .map((data) => MarketRateModel.fromJson(data))
          .where(
            (rate) =>
                _calculateDistance(lat, lon, rate.latitude, rate.longitude) <=
                maxDistanceKm,
          )
          .toList();

      // Group by day
      Map<String, List<double>> dailyRates = {};
      for (var rate in weekRates) {
        String dayKey =
            "${rate.createdAt.year}-${rate.createdAt.month.toString().padLeft(2, '0')}-${rate.createdAt.day.toString().padLeft(2, '0')}";
        if (!dailyRates.containsKey(dayKey)) {
          dailyRates[dayKey] = [];
        }
        dailyRates[dayKey]!.add(rate.broilerRate!);
      }

      // Calculate average for each day
      List<double> trend = [];
      for (int i = 6; i >= 0; i--) {
        DateTime d = DateTime.now().subtract(Duration(days: i));
        String dayKey =
            "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
        if (dailyRates.containsKey(dayKey) && dailyRates[dayKey]!.isNotEmpty) {
          double avg =
              dailyRates[dayKey]!.reduce((a, b) => a + b) /
              dailyRates[dayKey]!.length;
          trend.add(avg);
        } else {
          if (trend.isNotEmpty) {
            trend.add(trend.last); // Use previous day as fallback
          }
        }
      }

      return trend;
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> _getFallbackData(String error) {
    return {"error": error};
  }
}
