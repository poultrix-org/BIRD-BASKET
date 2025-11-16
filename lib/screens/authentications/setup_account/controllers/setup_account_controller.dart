// controllers/setup_account_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Import all your home views
import '../../../farmers/home/views/farmers_home_view.dart';
import '../../../vetnarians/home/views/vet_home_view.dart';
import '../../../company/home/views/company_home_view.dart';
import '../../../chicks/home/views/chicks_delivery_home_view.dart';
import '../../role_selections/models/user_models.dart';
// import '../../../meat_shop/home/views/meat_shop_home_view.dart';

class SetupAccountController extends GetxController {
  late String role;
  final formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  // Auth Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // All Profile Controllers
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final experienceController = TextEditingController();
  final deliveryRadiusController = TextEditingController();
  final farmAddressController = TextEditingController();
  final farmGpsLatController = TextEditingController();
  final farmGpsLongController = TextEditingController();
  final landSizeController = TextEditingController();
  final numberOfHensController = TextEditingController();
  final henTypeOptions = ['Broiler', 'Country', 'Layer'];
  var selectedHenType = RxnString();
  final clinicNameController = TextEditingController();
  final vetSpecializationOptions = ['Poultry', 'General', 'Other'];
  var selectedSpecialization = RxnString();
  final companyNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final companyAddressController = TextEditingController();
  final companySupplyTypeOptions = ['Feed', 'Medicine', 'Both'];
  var selectedCompanySupplyType = RxnString();
  final vehicleTypeOptions = ['Bike', 'Auto', 'Van', 'Pickup'];
  var selectedVehicleType = RxnString();
  final shopNameController = TextEditingController();
  final shopAddressController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    role = Get.arguments as String;
  }

  void pickLocation() {
    farmGpsLatController.text = '11.0168';
    farmGpsLongController.text = '76.9558';
  }

  void uploadProof(String proofType) {
    Get.snackbar('File Uploaded', 'Dummy $proofType.pdf uploaded.');
  }

  /// Creates both the Auth user and the Profile user.
  void saveProfile() async {
    if (!formKey.currentState!.validate()) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Colors.brown)),
      barrierDismissible: false,
    );

    try {
      final email = emailController.text.trim();
      final phone = phoneController.text.trim();

      // --- 1. ENFORCE YOUR "ONE ROLE" RULE ---
      // Check if email OR phone already exists in the profiles table.
      final check = await supabase
          .from('profiles')
          .select('role')
          .or('email.eq.$email,phone.eq.$phone')
          .maybeSingle();

      if (check != null && check.isNotEmpty) {
        // A profile with this email or phone ALREADY exists.
        final existingRole = check['role'];
        throw Exception(
            'This user is already registered as a $existingRole. Please log in.');
      }

      // --- 2. CREATE AUTH USER ---
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: passwordController.text.trim(),
        phone: phone, // Attach phone to auth user too
      );

      final authUser = authResponse.user;
      if (authUser == null) {
        throw Exception('Could not sign up user.');
      }

      // --- 3. CREATE USER MODEL ---
      final userModel = UserModel(
        userId: authUser.id,
        role: role,
        createdAt: DateTime.now(),
        email: authUser.email,
        phone: authUser.phone,

        // --- All dynamic fields ---
        fullName: (role == 'Farmer' ||
            role == 'Veterinarian' ||
            role == 'Chicks Delivery')
            ? fullNameController.text.trim()
            : null,
        address: (role == 'Veterinarian' || role == 'Chicks Delivery')
            ? addressController.text.trim()
            : null,
        idProofPath: (role == 'Veterinarian' ||
            role == 'Chicks Delivery' ||
            role == 'Meat Shop')
            ? 'dummy/id_proof.pdf'
            : null,
        farmAddress: role == 'Farmer' ? farmAddressController.text.trim() : null,
        farmGpsLat: role == 'Farmer' ? farmGpsLatController.text.trim() : null,
        farmGpsLong: role == 'Farmer' ? farmGpsLongController.text.trim() : null,
        landSize: role == 'Farmer' ? landSizeController.text.trim() : null,
        numberOfHens: role == 'Farmer'
            ? int.tryParse(numberOfHensController.text.trim())
            : null,
        typeOfHens: role == 'Farmer' ? selectedHenType.value : null,
        farmProofPath: role == 'Farmer' ? 'dummy/farm_proof.pdf' : null,
        clinicName:
        role == 'Veterinarian' ? clinicNameController.text.trim() : null,
        experience: (role == 'Veterinarian' || role == 'Chicks Delivery')
            ? int.tryParse(experienceController.text.trim())
            : null,
        specialization:
        role == 'Veterinarian' ? selectedSpecialization.value : null,
        companyName: role == 'Company' ? companyNameController.text.trim() : null,
        ownerName: role == 'Company' ? ownerNameController.text.trim() : null,
        companyAddress:
        role == 'Company' ? companyAddressController.text.trim() : null,
        supplyType: role == 'Company' ? selectedCompanySupplyType.value : null,
        deliveryRadius: (role == 'Company' ||
            role == 'Chicks Delivery' ||
            role == 'Meat Shop')
            ? int.tryParse(deliveryRadiusController.text.trim())
            : null,
        businessProofPath:
        role == 'Company' ? 'dummy/business_proof.pdf' : null,
        vehicleType:
        role == 'Chicks Delivery' ? selectedVehicleType.value : null,
        shopName: role == 'Meat Shop' ? shopNameController.text.trim() : null,
        shopAddress:
        role == 'Meat Shop' ? shopAddressController.text.trim() : null,
        shopProofPath: role == 'Meat Shop' ? 'dummy/shop_proof.pdf' : null,
      );

      // --- 4. SAVE PROFILE TO DATABASE ---
      final data = userModel.toJson();
      data['id'] = authUser.id; // Link to auth.users table
      data.removeWhere((key, value) => value == null);

      await supabase.from('profiles').insert(data);

      // --- 5. HIDE LOADING & NAVIGATE ---
      Get.back(); // Close loading dialog
      // Success! The SplashController's stream will
      // see the 'signedIn' event and navigate to the new home page.
      // We pass the userModel just in case.
      _navigateToHome(role, userModel);

    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Sign Up Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _navigateToHome(String role, UserModel userModel) {
    switch (role) {
      case 'Farmer':
        Get.offAll(() => FarmersHomeView(), arguments: userModel);
        break;
      case 'Veterinarian':
        Get.offAll(() => VetHomeView(), arguments: userModel);
        break;
      case 'Company':
        Get.offAll(() => CompanyHomeView(), arguments: userModel);
        break;
      case 'Chicks Delivery':
        Get.offAll(() => ChicksDeliveryHomeView(), arguments: userModel);
        break;
      case 'Meat Shop':
        Get.snackbar('Success', 'Meat Shop Profile Saved!'); // Placeholder
        // Get.offAll(() => MeatShopHomeView(), arguments: userModel);
        break;
    }
  }

  @override
  void onClose() {
    // Dispose all controllers
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    experienceController.dispose();
    deliveryRadiusController.dispose();
    farmAddressController.dispose();
    farmGpsLatController.dispose();
    farmGpsLongController.dispose();
    landSizeController.dispose();
    numberOfHensController.dispose();
    clinicNameController.dispose();
    companyNameController.dispose();
    ownerNameController.dispose();
    companyAddressController.dispose();
    shopNameController.dispose();
    shopAddressController.dispose();
    super.onClose();
  }
}