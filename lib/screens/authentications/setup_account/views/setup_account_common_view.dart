// views/setup_account_common_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/setup_account_controller.dart';

class SetupAccountCommonView extends StatelessWidget {
  final SetupAccountController controller = Get.put(SetupAccountController());

  // --- FIX: Added 'key' and corrected 'super.key' ---
  SetupAccountCommonView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create ${controller.role} Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please provide your details as a ${controller.role}.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),

              // --- NEW: Auth Fields ---
              _buildAuthFields(context), // <-- ADDED
              // --- DYNAMIC FORM ---
              _buildDynamicForm(context),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.saveProfile,
                  // Changed text to reflect action
                  child: const Text('Create Account & Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- NEW WIDGET: Auth Fields ---
  Widget _buildAuthFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Login Details',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
          ),
          validator: (value) {
            if (value == null || value.isEmpty || !value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: controller.passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock),
          ),
          validator: (value) {
            if (value == null || value.isEmpty || value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        Text(
          '${controller.role} Profile Details',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // --- WIDGET BUILDERS based on ROLE ---
  // This is the core logic for the dynamic view
  Widget _buildDynamicForm(BuildContext context) {
    switch (controller.role) {
      case 'Farmer':
        return _buildFarmerForm(context);
      case 'Veterinarian':
        return _buildVetForm(context);
      case 'Company':
        return _buildCompanyForm(context);
      case 'Chicks Delivery':
        return _buildChicksDeliveryForm(context);
      case 'Meat Shop':
        return _buildMeatShopForm(context);
      default:
        return const Text('Error: Unknown Role');
    }
  }

  Widget _buildFarmerForm(BuildContext context) {
    return Column(
      children: [
        _buildTextField(
          controller.fullNameController,
          'Full Name',
          Icons.person,
        ),
        _buildTextField(
          controller.phoneController,
          'Phone Number',
          Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        _buildTextField(
          controller.farmAddressController,
          'Farm Address',
          Icons.location_on,
        ),
        _buildTextField(
          controller.landSizeController,
          'Land Size (in acres)',
          Icons.landscape,
        ),
        _buildTextField(
          controller.numberOfHensController,
          'Number of Hens',
          Icons.numbers,
          keyboardType: TextInputType.number,
        ),
        _buildDropdown(
          hint: 'Type of Hens',
          icon: Icons.egg,
          observableValue: controller.selectedHenType,
          items: controller.henTypeOptions,
          onChanged: (val) {
            controller.selectedHenType.value = val;
          },
        ),
        _buildLocationPicker(context),
        _buildUploadButton(
          'Upload Farm Proof',
          () => controller.uploadProof('Farm Proof'),
        ),
      ],
    );
  }

  Widget _buildVetForm(BuildContext context) {
    return Column(
      children: [
        _buildTextField(
          controller.fullNameController,
          'Full Name',
          Icons.person,
        ),
        _buildTextField(
          controller.phoneController,
          'Phone Number',
          Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        _buildTextField(
          controller.clinicNameController,
          'Clinic Name',
          Icons.local_hospital,
        ),
        _buildTextField(
          controller.experienceController,
          'Experience (years)',
          Icons.star,
          keyboardType: TextInputType.number,
        ),
        _buildDropdown(
          hint: 'Specialization',
          icon: Icons.science,
          observableValue: controller.selectedSpecialization,
          items: controller.vetSpecializationOptions,
          onChanged: (val) {
            controller.selectedSpecialization.value = val;
          },
        ),
        _buildTextField(
          controller.addressController,
          'Address',
          Icons.location_city,
        ),
        _buildUploadButton(
          'Upload Govt. Proof',
          () => controller.uploadProof('Govt. Proof'),
        ),
      ],
    );
  }

  Widget _buildCompanyForm(BuildContext context) {
    return Column(
      children: [
        _buildTextField(
          controller.companyNameController,
          'Company Name',
          Icons.business,
        ),
        _buildTextField(
          controller.ownerNameController,
          'Owner Name',
          Icons.person_pin,
        ),
        _buildTextField(
          controller.phoneController,
          'Phone Number',
          Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        _buildTextField(
          controller.companyAddressController,
          'Company Address',
          Icons.location_city,
        ),
        _buildDropdown(
          hint: 'Supply Type',
          icon: Icons.category,
          observableValue: controller.selectedCompanySupplyType,
          items: controller.companySupplyTypeOptions,
          onChanged: (val) {
            controller.selectedCompanySupplyType.value = val;
          },
        ),
        _buildTextField(
          controller.deliveryRadiusController,
          'Delivery Radius (km)',
          Icons.delivery_dining,
          keyboardType: TextInputType.number,
        ),
        _buildUploadButton(
          'Upload Business Proof',
          () => controller.uploadProof('Business Proof'),
        ),
      ],
    );
  }

  Widget _buildChicksDeliveryForm(BuildContext context) {
    return Column(
      children: [
        _buildTextField(
          controller.fullNameController,
          'Full Name',
          Icons.person,
        ),
        _buildTextField(
          controller.phoneController,
          'Phone Number',
          Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        _buildDropdown(
          hint: 'Vehicle Type',
          icon: Icons.local_shipping,
          observableValue: controller.selectedVehicleType,
          items: controller.vehicleTypeOptions,
          onChanged: (val) {
            controller.selectedVehicleType.value = val;
          },
        ),
        _buildTextField(
          controller.deliveryRadiusController,
          'Delivery Radius (km)',
          Icons.map,
          keyboardType: TextInputType.number,
        ),
        _buildTextField(
          controller.experienceController,
          'Experience (years)',
          Icons.star,
          keyboardType: TextInputType.number,
        ),
        _buildTextField(
          controller.addressController,
          'Address',
          Icons.location_city,
        ),
        _buildUploadButton(
          'Upload ID Proof',
          () => controller.uploadProof('ID Proof'),
        ),
      ],
    );
  }

  Widget _buildMeatShopForm(BuildContext context) {
    return Column(
      children: [
        _buildTextField(
          controller.shopNameController,
          'Shop Name',
          Icons.storefront,
        ),
        _buildTextField(
          controller.phoneController,
          'Phone Number',
          Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        _buildTextField(
          controller.shopAddressController,
          'Shop Address',
          Icons.location_on,
        ),
        _buildTextField(
          controller.deliveryRadiusController,
          'Delivery Radius (km)',
          Icons.map,
          keyboardType: TextInputType.number,
        ),
        _buildUploadButton(
          'Upload Shop Proof',
          () => controller.uploadProof('Shop Proof'),
        ),
        _buildUploadButton(
          'Upload ID Proof',
          () => controller.uploadProof('ID Proof'),
        ),
      ],
    );
  }

  // --- COMMON HELPER WIDGETS ---
  // (These are all unchanged)

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required IconData icon,
    required RxnString observableValue,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Obx(
        () => DropdownButtonFormField<String>(
          value: observableValue.value,
          decoration: InputDecoration(labelText: hint, prefixIcon: Icon(icon)),
          hint: Text(hint),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null) {
              return 'Please select $hint';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildLocationPicker(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller.farmGpsLatController,
                'Farm GPS (Lat)',
                Icons.gps_fixed,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                controller.farmGpsLongController,
                'Farm GPS (Long)',
                Icons.gps_fixed,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: controller.pickLocation,
            icon: const Icon(Icons.my_location),
            label: const Text('Pick Current Location'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Colors.brown[700]!),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildUploadButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.upload_file),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: Colors.brown[700]!),
        ),
      ),
    );
  }
}
