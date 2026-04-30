// controllers/farmers_home_controller.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';


import '../../../authentications/role_selections/models/user_models.dart';

class FarmersHomeController extends GetxController {
  late UserModel user;
  var currentIndex = 0.obs;

  // Weather variables
  var isWeatherLoading = true.obs;
  var weatherCity = "Loading...".obs;
  var weatherTemp = 0.obs;
  var weatherDesc = "".obs;
  var weatherIcon = "".obs;
  var weatherHigh = 0.obs;
  var weatherLow = 0.obs;
  var weatherWind = 0.obs;
  var weatherHumidity = 0.obs;

  // Add your provided OpenWeatherMap API key securely here
  final String weatherApiKey = "b924b76cc93b3b89fe1687e6ae94765f";

  void changePage(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    // Get the user model passed from the setup screen
    user = Get.arguments as UserModel;
    
    // Automatically load local weather
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    isWeatherLoading.value = true;
    try {
      // In production, grab GPS here. For now, use Kangeyam/user's city.
      // We will default to something safe since GPS requires await. 
      String city = "Tiruppur"; 
      
      final url = Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$weatherApiKey&units=metric");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        weatherCity.value = data['name'];
        weatherTemp.value = data['main']['temp'].round();
        weatherHigh.value = data['main']['temp_max'].round();
        weatherLow.value = data['main']['temp_min'].round();
        weatherHumidity.value = data['main']['humidity'];
        weatherWind.value = data['wind']['speed'].round();
        
        // e.g. "Clouds with rain", capitalized safely
        String desc = data['weather'][0]['description'] ?? "clear sky";
        weatherDesc.value = desc.substring(0, 1).toUpperCase() + desc.substring(1);
        
        // Save the icon code (e.g. "04d")
        weatherIcon.value = data['weather'][0]['icon'];
      }
    } catch (e) {
      print("Weather API Error: $e");
    } finally {
      isWeatherLoading.value = false;
    }
  }
}
