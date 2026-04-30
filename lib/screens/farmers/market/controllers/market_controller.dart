import 'package:get/get.dart';

class MarketController extends GetxController {
  var isRefreshing = false.obs;
  var location = 'Kangeyam, Tamil Nadu'.obs;
  var currentDate = 'April 21'.obs;

  // Rate Cards
  var broilerRate = 95.0.obs;
  var broilerYesterday = 92.0.obs;
  var broilerTrend = 3.0.obs; // +3

  var eggRate = 5.10.obs;
  var eggYesterday = 4.90.obs;
  var eggTrend = 0.20.obs; // +0.20

  var feedRate = 1250.0.obs;
  var feedYesterday = 1220.0.obs;
  var feedTrend = 30.0.obs; // +30

  var chickRate = 35.0.obs;
  var chickYesterday = 33.0.obs;
  var chickTrend = 2.0.obs; // +2

  // Weekly Trend Data
  var weeklyTrend = [
    {'day': 'Mon', 'price': 90},
    {'day': 'Tue', 'price': 92},
    {'day': 'Wed', 'price': 93},
    {'day': 'Thu', 'price': 94},
    {'day': 'Fri', 'price': 95},
  ].obs;

  // Insights
  var marketInsights = [
    'Demand HIGH in your area',
    'Good time to sell chickens',
    'Feed price rising → Buy early',
  ].obs;

  // Alerts
  var diseaseAlerts = [
    {
      'title': 'Heat Stress Alert',
      'desc': 'High temperature in your district',
      'severity': 'high',
    },
    {
      'title': 'Bird Flu Risk',
      'desc': 'Nearby district reported cases',
      'severity': 'high',
    },
  ].obs;

  // Common Diseases Info
  var commonDiseases = [
    {
      'name': 'Newcastle Disease',
      'symptoms': 'Weakness, not eating, gasping, coughing.',
      'prevention': 'Vaccination schedule, biosecurity & clean water.',
    },
    {
      'name': 'Avian Influenza',
      'symptoms': 'Sudden death, swollen head, purple comb.',
      'prevention': 'Strict biosecurity, restrict visitors.',
    },
    {
      'name': 'Coccidiosis',
      'symptoms': 'Bloody droppings, ruffled feathers.',
      'prevention': 'Keep litter dry, use coccidiostats in feed.',
    },
    {
      'name': 'Heat Stress',
      'symptoms': 'Panting, pale comb/wattles, decreased egg production.',
      'prevention': 'Keep water cool, add electrolytes, avoid overcrowding.',
    },
  ].obs;

  // Nearby Rates
  var nearbyRates = [
    {'location': 'Erode', 'rate': 94.0},
    {'location': 'Coimbatore', 'rate': 96.0},
    {'location': 'Karur', 'rate': 93.0},
  ].obs;

  var notificationsEnabled = false.obs;

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    if (value) {
      Get.snackbar(
        'Alerts Enabled',
        'You will receive price and disease alerts.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Alerts Disabled',
        'Notifications turned off.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> refreshRates() async {
    isRefreshing.value = true;
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    isRefreshing.value = false;
    Get.snackbar(
      'Market Updated',
      'Latest rates fetched for ${location.value}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.snackBarTheme.backgroundColor?.withOpacity(
        0.8,
      ),
      colorText: Get.theme.snackBarTheme.contentTextStyle?.color,
    );
  }
}
