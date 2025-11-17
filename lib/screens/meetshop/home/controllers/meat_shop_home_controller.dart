// screens/meat_shop/home/controllers/meat_shop_home_controller.dart
import 'package:get/get.dart';
import '../../../authentications/role_selections/models/user_models.dart';

class MeatShopHomeController extends GetxController {
  late UserModel user;

  @override
  void onInit() {
    super.onInit();
    // Retrieve the user model passed from Splash or Setup
    user = Get.arguments as UserModel;
  }
}