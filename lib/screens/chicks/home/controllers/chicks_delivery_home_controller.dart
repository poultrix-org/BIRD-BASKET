// controllers/chicks_delivery_home_controller.dart
import 'package:get/get.dart';

import '../../../authentications/models/user_models.dart';

class ChicksDeliveryHomeController extends GetxController {
  late UserModel user;

  @override
  void onInit() {
    super.onInit();
    user = Get.arguments as UserModel;
  }
}