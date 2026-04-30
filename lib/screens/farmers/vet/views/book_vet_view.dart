import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/book_vet_controller.dart';

class BookVetView extends StatelessWidget {
  final BookVetController controller = Get.put(BookVetController());

  BookVetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Book Veterinary Visit',
          style: TextStyle(
            fontFamily: 'Times New Roman',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,

        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('🔹 Condition Details'),
              _buildCard(
                child: Column(
                  children: [
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.selectedIssue.value,
                        decoration: _inputDecoration(
                          '🐔 What is the primary issue?',
                        ),
                        items: controller.issueTypes
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: const TextStyle(
                                    fontFamily: 'Times New Roman',
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            controller.selectedIssue.value = val,
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: controller.descriptionController,
                      label: '📝 Describe the Problem (Optional)',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('🔹 Farm Details'),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: controller.birdsController,
                      label: '🐔 Total Number of Birds',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '⚠️ Select Symptoms:',
                      style: TextStyle(
                        fontFamily: 'Times New Roman',
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: controller.symptomOptions.map((symptom) {
                        return Obx(() {
                          final isSelected = controller.selectedSymptoms
                              .contains(symptom);
                          return FilterChip(
                            label: Text(
                              symptom,
                              style: const TextStyle(
                                fontFamily: 'Times New Roman',
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: Colors.teal.shade100,
                            checkmarkColor: Colors.teal,
                            onSelected: (_) =>
                                controller.toggleSymptom(symptom),
                          );
                        });
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('🔹 Photos (Crucial for Vets)'),
              _buildCard(
                child: Column(
                  children: [
                    _buildUploadButton(
                      '📸 Upload Chicken Photo (Required)',
                      () => controller.pickImage(),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => controller.imagePath.value != null
                          ? const Text(
                              '✅ Photo Attached',
                              style: TextStyle(color: Colors.green),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('🔹 Location & Timing'),
              _buildCard(
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.my_location),
                      label: const Text(
                        '📍 Auto Detect Farm Location',
                        style: TextStyle(fontFamily: 'Times New Roman'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade50,
                        elevation: 0,
                      ),
                      onPressed: () => controller.detectLocation(),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: controller.locationController,
                      label: 'Or Manually Enter Address',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => RadioListTile<String>(
                              title: const Text(
                                'Immediate\n(Emergency)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Times New Roman',
                                ),
                              ),
                              value: 'Immediate',
                              groupValue: controller.visitType.value,
                              onChanged: (val) =>
                                  controller.visitType.value = val!,
                              activeColor: Colors.red,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Obx(
                            () => RadioListTile<String>(
                              title: const Text(
                                'Schedule\nVisit',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Times New Roman',
                                ),
                              ),
                              value: 'Schedule',
                              groupValue: controller.visitType.value,
                              onChanged: (val) =>
                                  controller.visitType.value = val!,
                              activeColor: Colors.teal,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Obx(
                      () => controller.visitType.value == 'Schedule'
                          ? InkWell(
                              onTap: () => controller.pickDate(context),
                              child: Container(
                                margin: const EdgeInsets.only(top: 10),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      controller.scheduledDate.value == null
                                          ? '📅 Select Date & Time'
                                          : '📅 ${controller.scheduledDate.value!.toLocal().toString().split('.')[0]}',
                                      style: const TextStyle(
                                        fontFamily: 'Times New Roman',
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.access_time,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('🔹 Payment Info'),
              _buildCard(
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💰 Consultation Fee: ₹200',
                      style: TextStyle(
                        fontFamily: 'Times New Roman',
                        fontSize: 18,
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '✔ Pay directly to the vet after the visit.',
                      style: TextStyle(
                        fontFamily: 'Times New Roman',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.submitBooking(),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            '🩺 Book Vet Visit',
                            style: TextStyle(
                              fontFamily: 'Times New Roman',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Times New Roman',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildUploadButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Colors.teal),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Times New Roman',
            color: Colors.teal,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontFamily: 'Times New Roman'),
      decoration: _inputDecoration(label),
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Required' : null,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontFamily: 'Times New Roman',
        color: Colors.grey,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.teal),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
