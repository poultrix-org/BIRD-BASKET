// controllers/setup_account_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../chicks/home/views/chicks_delivery_home_view.dart';
import '../../../company/home/views/company_home_view.dart';
import '../../../farmers/home/views/farmers_home_view.dart';
import '../../../vetnarians/home/views/vet_home_view.dart';
import '../../models/user_models.dart';


class SetupAccountController extends GetxController {
  late String role;
  final formKey = GlobalKey<FormState>();

  // --- All possible TextEditingControllers ---
  // Common
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  // Farmer
  final farmAddressController = TextEditingController();
  final farmGpsLatController = TextEditingController();
  final farmGpsLongController = TextEditingController();
  final landSizeController = TextEditingController();
  final numberOfHensController = TextEditingController();
  final henTypeOptions = ['Broiler', 'Country', 'Layer'];
  var selectedHenType = RxnString();

  // Vet
  final clinicNameController = TextEditingController();
  final experienceController = TextEditingController();
  final vetSpecializationOptions = ['Poultry', 'General', 'Other'];
  var selectedSpecialization = RxnString();

  // Company
  final companyNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final companyAddressController = TextEditingController();
  final companySupplyTypeOptions = ['Feed', 'Medicine', 'Both'];
  var selectedCompanySupplyType = RxnString();
  final deliveryRadiusController = TextEditingController();

  // Feed Supplier - REMOVED

  // Chicks Delivery
  final vehicleTypeOptions = ['Bike', 'Auto', 'Van', 'Pickup'];
  var selectedVehicleType = RxnString();
  // Uses fullName, phone, address, experience, deliveryRadius

  @override
  void onInit() {
    super.onInit();
    // Receive the role from arguments
    role = Get.arguments as String;
  }

  void pickLocation() {
    // Dummy GPS Location logic
    farmGpsLatController.text = '11.0168';
    farmGpsLongController.text = '76.9558';
    Get.snackbar('Location Picked', 'Dummy location (Coimbatore) set.');
  }

  void uploadProof(String proofType) {
    // Dummy upload logic
    Get.snackbar(
      'File Uploaded',
      'Dummy $proofType.pdf uploaded successfully.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void saveProfile() {
    if (formKey.currentState!.validate()) {
      // Create user model
      final userModel = UserModel(
        role: role,
        createdAt: DateTime.now(),
        // Populate based on role
        // This is verbose but required by the architecture
        fullName: (role == 'Farmer' ||
            role == 'Veterinarian' ||
            role == 'Chicks Delivery')
            ? fullNameController.text
            : null,
        phone: phoneController.text,
        address: (role == 'Veterinarian' || role == 'Chicks Delivery')
            ? addressController.text
            : null,

        // Farmer
        farmAddress: role == 'Farmer' ? farmAddressController.text : null,
        farmGpsLat: role == 'Farmer' ? farmGpsLatController.text : null,
        farmGpsLong: role == 'Farmer' ? farmGpsLongController.text : null,
        landSize: role == 'Farmer' ? landSizeController.text : null,
        numberOfHens:
        role == 'Farmer' ? int.tryParse(numberOfHensController.text) : null,
        typeOfHens: role == 'Farmer' ? selectedHenType.value : null,
        farmProofPath: role == 'Farmer' ? 'dummy/farm_proof.pdf' : null,

        // Vet
        clinicName: role == 'Veterinarian' ? clinicNameController.text : null,
        experience: (role == 'Veterinarian' || role == 'Chicks Delivery')
            ? int.tryParse(experienceController.text)
            : null,
        specialization:
        role == 'Veterinarian' ? selectedSpecialization.value : null,
        idProofPath: (role == 'Veterinarian' || role == 'Chicks Delivery')
            ? 'dummy/id_proof.pdf'
            : null,

        // Company
        companyName: role == 'Company' ? companyNameController.text : null,
        ownerName: role == 'Company' ? ownerNameController.text : null,
        companyAddress: role == 'Company' ? companyAddressController.text : null,
        supplyType: role == 'Company' ? selectedCompanySupplyType.value : null,
        deliveryRadius: (role == 'Company' || role == 'Chicks Delivery')
            ? int.tryParse(deliveryRadiusController.text)
            : null,
        businessProofPath: role == 'Company' ? 'dummy/business_proof.pdf' : null,

        // Feed Supplier - REMOVED

        // Chicks Delivery
        vehicleType:
        role == 'Chicks Delivery' ? selectedVehicleType.value : null,
      );

      // --- DEV MODE: Navigate to respective home screen ---
      // We pass the userModel as an argument to the next screen
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
      // case 'Feed Supplier': // Removed
      //   Get.offAll(() => FeedHomeView(), arguments: userModel);
      //   break;
        case 'Chicks Delivery':
          Get.offAll(() => ChicksDeliveryHomeView(), arguments: userModel);
          break;
      }
    } else {
      Get.snackbar(
        'Error',
        'Please fill all required fields.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    // Dispose all controllers
    fullNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    farmAddressController.dispose();
    farmGpsLatController.dispose();
    farmGpsLongController.dispose();
    landSizeController.dispose();
    numberOfHensController.dispose();
    clinicNameController.dispose();
    experienceController.dispose();
    companyNameController.dispose();
    ownerNameController.dispose();
    companyAddressController.dispose();
    deliveryRadiusController.dispose();
    // supplierNameController.dispose(); // Removed
    // supplierDeliveryRadiusController.dispose(); // Removed
    super.onClose();
  }
}