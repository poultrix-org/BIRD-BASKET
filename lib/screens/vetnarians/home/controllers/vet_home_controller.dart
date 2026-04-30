// controllers/vet_home_controller.dart
import 'package:get/get.dart';

import '../../../authentications/role_selections/models/user_models.dart';

class VetHomeController extends GetxController {
  late UserModel user;

  @override
  void onInit() {
    super.onInit();
    user = Get.arguments as UserModel;
  }
}
