// controllers/farmers_home_controller.dart
import 'package:get/get.dart';

import '../../../authentications/models/user_models.dart';

class FarmersHomeController extends GetxController {
  late UserModel user;

  @override
  void onInit() {
    super.onInit();
    // Get the user model passed from the setup screen
    user = Get.arguments as UserModel;
  }
}