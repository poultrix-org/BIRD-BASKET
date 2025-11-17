// controllers/setup_account_controller.dart
import 'dart:io'; // Required for File operations
import 'package:file_picker/file_picker.dart'; // Required for picking files
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import all your home views
import '../../../farmers/home/views/farmers_home_view.dart';
import '../../../meetshop/home/views/meat_shop_home_view.dart';
import '../../../vetnarians/home/views/vet_home_view.dart';
import '../../../company/home/views/company_home_view.dart';
import '../../../chicks/home/views/chicks_delivery_home_view.dart';

import '../../role_selections/models/user_models.dart';
import '../../splashscreens/controllers/splash_controller.dart';

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

  // --- FILE PATH VARIABLES ---
  // We store the local path here temporarily until we upload to Supabase
  String? uploadedIdProofPath;
  String? uploadedFarmProofPath;
  String? uploadedBusinessProofPath;
  String? uploadedShopProofPath;

  @override
  void onInit() {
    super.onInit();
    role = Get.arguments as String;
  }

  void pickLocation() {
    // Hardcoded for now
    farmGpsLatController.text = '11.0168';
    farmGpsLongController.text = '76.9558';
  }

  /// 1. Pick a file from the device
  Future<void> uploadProof(String proofType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'pdf'],
      );

      if (result == null) return; // User canceled

      PlatformFile file = result.files.first;

      // Store the local path based on what button was clicked
      if (proofType == 'ID Proof' || proofType == 'Govt. Proof') {
        uploadedIdProofPath = file.path;
      } else if (proofType == 'Farm Proof') {
        uploadedFarmProofPath = file.path;
      } else if (proofType == 'Business Proof') {
        uploadedBusinessProofPath = file.path;
      } else if (proofType == 'Shop Proof') {
        uploadedShopProofPath = file.path;
      }

      Get.snackbar('File Selected', '${file.name} ready for upload.');
    } catch (e) {
      Get.snackbar('Error', 'Could not pick file: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  /// 2. Helper to upload file to Supabase Storage ('userproofs')
  Future<String?> _uploadFileToSupabase(
      String? localPath, String userId, String folderName) async {
    if (localPath == null) return null;

    try {
      final file = File(localPath);
      final fileExt = localPath.split('.').last;
      // Create a unique file name using timestamp
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      // Path: userId/folder/filename.jpg
      final storagePath = '$userId/$folderName/$fileName';

      // Upload to the 'userproofs' bucket
      await supabase.storage.from('userproofs').upload(
        storagePath,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      // Return the storage path to save in the database
      return storagePath;
    } catch (e) {
      print("Upload Error: $e");
      return null;
    }
  }

  /// Creates Auth user, Uploads files, Creates Profile, Navigates Home.
  void saveProfile() async {
    // --- FIX: Close Keyboard First ---
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 100));

    if (!formKey.currentState!.validate()) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Colors.brown)),
      barrierDismissible: false,
    );

    try {
      // Activate flag to prevent SplashController form auto-logging out
      SplashController.isRegistering = true;

      final email = emailController.text.trim();
      final phone = phoneController.text.trim();

      // Check if user exists in profiles
      final check = await supabase
          .from('profiles')
          .select('role')
          .or('email.eq.$email,phone.eq.$phone')
          .maybeSingle();

      if (check != null && check.isNotEmpty) {
        final existingRole = check['role'];
        throw Exception(
            'This user is already registered as a $existingRole. Please log in.');
      }

      // Create Auth User
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: passwordController.text.trim(),
        phone: phone,
      );

      final authUser = authResponse.user;
      if (authUser == null) {
        throw Exception('Could not sign up user.');
      }

      // --- UPLOAD FILES TO SUPABASE ---
      // We do this after signup so we have the User ID for the folder structure
      String? idProofUrl = await _uploadFileToSupabase(
          uploadedIdProofPath, authUser.id, 'id_proofs');
      String? farmProofUrl = await _uploadFileToSupabase(
          uploadedFarmProofPath, authUser.id, 'farm_proofs');
      String? businessProofUrl = await _uploadFileToSupabase(
          uploadedBusinessProofPath, authUser.id, 'business_proofs');
      String? shopProofUrl = await _uploadFileToSupabase(
          uploadedShopProofPath, authUser.id, 'shop_proofs');

      // Create User Model with real file paths
      final userModel = UserModel(
        userId: authUser.id,
        role: role,
        createdAt: DateTime.now(),
        email: authUser.email,
        phone: authUser.phone,

        // --- Dynamic Fields ---
        fullName: (role == 'Farmer' ||
            role == 'Veterinarian' ||
            role == 'Chicks Delivery')
            ? fullNameController.text.trim()
            : null,
        address: (role == 'Veterinarian' || role == 'Chicks Delivery')
            ? addressController.text.trim()
            : null,
        idProofPath: idProofUrl, // <--- Uses uploaded URL

        farmAddress:
        role == 'Farmer' ? farmAddressController.text.trim() : null,
        farmGpsLat: role == 'Farmer' ? farmGpsLatController.text.trim() : null,
        farmGpsLong:
        role == 'Farmer' ? farmGpsLongController.text.trim() : null,
        landSize: role == 'Farmer' ? landSizeController.text.trim() : null,
        numberOfHens: role == 'Farmer'
            ? int.tryParse(numberOfHensController.text.trim())
            : null,
        typeOfHens: role == 'Farmer' ? selectedHenType.value : null,
        farmProofPath: farmProofUrl, // <--- Uses uploaded URL

        clinicName:
        role == 'Veterinarian' ? clinicNameController.text.trim() : null,
        experience: (role == 'Veterinarian' || role == 'Chicks Delivery')
            ? int.tryParse(experienceController.text.trim())
            : null,
        specialization:
        role == 'Veterinarian' ? selectedSpecialization.value : null,
        companyName:
        role == 'Company' ? companyNameController.text.trim() : null,
        ownerName: role == 'Company' ? ownerNameController.text.trim() : null,
        companyAddress:
        role == 'Company' ? companyAddressController.text.trim() : null,
        supplyType: role == 'Company' ? selectedCompanySupplyType.value : null,
        deliveryRadius: (role == 'Company' ||
            role == 'Chicks Delivery' ||
            role == 'Meat Shop')
            ? int.tryParse(deliveryRadiusController.text.trim())
            : null,
        businessProofPath: businessProofUrl, // <--- Uses uploaded URL

        vehicleType:
        role == 'Chicks Delivery' ? selectedVehicleType.value : null,
        shopName: role == 'Meat Shop' ? shopNameController.text.trim() : null,
        shopAddress:
        role == 'Meat Shop' ? shopAddressController.text.trim() : null,
        shopProofPath: shopProofUrl, // <--- Uses uploaded URL
      );

      // Save Profile to DB
      final data = userModel.toJson();
      data['id'] = authUser.id;
      data.removeWhere((key, value) => value == null);

      await supabase.from('profiles').insert(data);

      // Deactivate Flag
      SplashController.isRegistering = false;

      Get.back(); // Close loading dialog
      _navigateToHome(role, userModel);
    } catch (e) {
      SplashController.isRegistering = false;
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
      // Navigates to the new Meat Shop View
        Get.offAll(() => MeatShopHomeView(), arguments: userModel);
        break;
    }
  }

  @override
  void onClose() {
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