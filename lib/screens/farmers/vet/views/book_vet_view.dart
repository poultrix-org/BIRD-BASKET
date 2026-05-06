import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/book_vet_controller.dart';

class BookVetView extends StatelessWidget {
  final BookVetController controller = Get.put(BookVetController());

  BookVetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text(
          'Book Veterinary Visit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1B5E20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Condition Details ──
              _buildSectionTitle('Condition Details'),
              _buildCard(
                child: Column(
                  children: [
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.selectedIssue.value,
                        decoration: InputDecoration(
                          hintText: 'e.g. Disease, Vaccination, Emergency...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          labelText: 'What is the primary issue?',
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF5D654E),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFF5D654E)),
                          ),
                        ),
                        items: controller.issueTypes
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            controller.selectedIssue.value = val,
                        validator: (value) =>
                            value == null ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextFieldWithMic(
                      textController: controller.descriptionController,
                      label: 'Describe the Problem',
                      hint:
                          'e.g. Birds are not eating since 2 days, showing weakness...',
                      fieldName: 'description',
                      maxLines: 3,
                      isRequired: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              _buildDivider(),
              const SizedBox(height: 8),

              // ── Farm Details ──
              _buildSectionTitle('Farm Details'),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextFieldWithMic(
                      textController: controller.birdsController,
                      label: 'Total Number of Birds',
                      hint: 'e.g. 500',
                      fieldName: 'birds',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Symptoms:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF5D654E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          controller.symptomOptions.map((symptom) {
                            return Obx(() {
                              final isSelected = controller.selectedSymptoms
                                  .contains(symptom);
                              return FilterChip(
                                label: Text(symptom),
                                selected: isSelected,
                                selectedColor: const Color(
                                  0xFF5D654E,
                                ).withValues(alpha: 0.2),
                                checkmarkColor: const Color(0xFF5D654E),
                                onSelected: (_) =>
                                    controller.toggleSymptom(symptom),
                              );
                            });
                          }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              _buildDivider(),
              const SizedBox(height: 8),

              // ── Photos (3 compulsory) ──
              _buildSectionTitle('Upload 3 Photos'),
              const Text(
                'Photos help the vet diagnose remotely (all 3 required).',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Obx(
                () => Row(
                  children: List.generate(3, (index) {
                    final path = controller.imagePaths[index].value;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => controller.pickImage(index),
                        child: Container(
                          height: 100,
                          margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: path != null
                                  ? const Color(0xFF1B5E20)
                                  : Colors.grey.shade300,
                              width: path != null ? 2 : 1,
                            ),
                            image: path != null
                                ? DecorationImage(
                                    image: FileImage(File(path)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: path == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      color: Colors.grey.shade400,
                                      size: 28,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Photo ${index + 1}',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 16),
              _buildDivider(),
              const SizedBox(height: 8),

              // ── Location & Timing ──
              _buildSectionTitle('Location & Timing'),
              _buildCard(
                child: Column(
                  children: [
                    // Highlighted Auto Detect Location
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.my_location, size: 22),
                        label: const Text(
                          'Auto Detect Farm Location',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => controller.detectLocation(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextFieldWithMic(
                      textController: controller.locationController,
                      label: 'Or Enter Address Manually',
                      hint: 'e.g. Farm No. 12, Kangeyam, Tamil Nadu',
                      fieldName: 'location',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => RadioListTile<String>(
                              title: const Text(
                                'Immediate\n(Emergency)',
                                style: TextStyle(fontSize: 12),
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
                                style: TextStyle(fontSize: 12),
                              ),
                              value: 'Schedule',
                              groupValue: controller.visitType.value,
                              onChanged: (val) =>
                                  controller.visitType.value = val!,
                              activeColor: const Color(0xFF5D654E),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      controller.scheduledDate.value == null
                                          ? 'Select Date & Time'
                                          : '📅 ${controller.scheduledDate.value!.toLocal().toString().split('.')[0]}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const Icon(
                                      Icons.calendar_today,
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

              const SizedBox(height: 16),
              _buildDivider(),
              const SizedBox(height: 8),

              // ── Payment Info ──
              _buildSectionTitle('Payment Info'),
              _buildCard(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Consultation Fee: ₹200',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF5D654E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    controller.paymentMode.value = 'pay_now',
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color:
                                        controller.paymentMode.value == 'pay_now'
                                            ? const Color(0xFF1B5E20)
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color:
                                          controller.paymentMode.value ==
                                                  'pay_now'
                                              ? const Color(0xFF1B5E20)
                                              : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.payment,
                                        color:
                                            controller.paymentMode.value ==
                                                    'pay_now'
                                                ? Colors.white
                                                : Colors.grey.shade600,
                                        size: 22,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Pay Now',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color:
                                              controller.paymentMode.value ==
                                                      'pay_now'
                                                  ? Colors.white
                                                  : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    controller.paymentMode.value = 'pay_later',
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color:
                                        controller.paymentMode.value ==
                                                'pay_later'
                                            ? const Color(0xFF1B5E20)
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color:
                                          controller.paymentMode.value ==
                                                  'pay_later'
                                              ? const Color(0xFF1B5E20)
                                              : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        color:
                                            controller.paymentMode.value ==
                                                    'pay_later'
                                                ? Colors.white
                                                : Colors.grey.shade600,
                                        size: 22,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Pay Later',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color:
                                              controller.paymentMode.value ==
                                                      'pay_later'
                                                  ? Colors.white
                                                  : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => Text(
                          controller.paymentMode.value == 'pay_now'
                              ? 'Pay ₹200 online now to confirm your booking.'
                              : 'Pay directly to the vet after the visit.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Submit Button ──
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.submitBooking(),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Obx(
                            () => Text(
                              controller.paymentMode.value == 'pay_now'
                                  ? 'Pay ₹200 & Book'
                                  : 'Book Vet Visit',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
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

  // ── Helper: Text field with mic button ──
  Widget _buildTextFieldWithMic({
    required TextEditingController textController,
    required String label,
    required String hint,
    required String fieldName,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5D654E),
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => TextFormField(
            controller: textController,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  if (controller.isListening.value &&
                      controller.activeFieldForVoice.value == fieldName) {
                    controller.stopListening();
                  } else {
                    controller.startListening(fieldName, textController);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: controller.isListening.value &&
                            controller.activeFieldForVoice.value == fieldName
                        ? Colors.red.shade50
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    controller.isListening.value &&
                            controller.activeFieldForVoice.value == fieldName
                        ? Icons.mic
                        : Icons.mic_none,
                    color: controller.isListening.value &&
                            controller.activeFieldForVoice.value == fieldName
                        ? Colors.red
                        : Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: controller.isListening.value &&
                          controller.activeFieldForVoice.value == fieldName
                      ? Colors.red
                      : Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF5D654E)),
              ),
            ),
            validator: isRequired
                ? (value) =>
                    (value == null || value.isEmpty) ? 'Required' : null
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1B5E20),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: child,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Color(0xFFE2E4DA),
      thickness: 1,
      indent: 8,
      endIndent: 8,
    );
  }
}
