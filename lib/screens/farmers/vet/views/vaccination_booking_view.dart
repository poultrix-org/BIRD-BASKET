import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/vaccination_booking_controller.dart';
import '../widgets/photo_upload_section.dart';

class VaccinationBookingView extends StatelessWidget {
  final VaccinationBookingController controller =
      Get.put(VaccinationBookingController());

  VaccinationBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Vaccination Booking',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: const Color(0xFF1B5E20),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF1B5E20)),
      ),
      body: Stack(
        children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Farm Details ──
                    _sectionTitle('Farm Details'),
                    _fieldLabel('Farm Name'),
                    _textField(
                      controller: controller.farmNameController,
                      hint: 'e.g. Sri Murugan Farms',
                    ),
                    const SizedBox(height: 16),
                    _fieldLabel('Bird Type'),
                    _textField(
                      controller: controller.birdTypeController,
                      hint: 'e.g. Broiler, Layer, Country Hen',
                    ),
                    const SizedBox(height: 16),
                    _fieldLabel('Total Birds'),
                    _textField(
                      controller: controller.totalBirdsController,
                      hint: 'e.g. 500',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _fieldLabel('Bird Age'),
                    _textField(
                      controller: controller.birdAgeController,
                      hint: 'e.g. 21 days, 3 weeks',
                    ),

                    _divider(),

                    // ── Vaccination Type ──
                    _sectionTitle('Vaccination Type'),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.selectedVaccinationType.value,
                        hint: Text(
                          'Select vaccination type',
                          style: GoogleFonts.montserrat(
                              color: Colors.grey.shade400, fontSize: 14),
                        ),
                        style: GoogleFonts.montserrat(
                            color: Colors.black87, fontSize: 14),
                        decoration: _inputDecoration(),
                        items: controller.vaccinationTypes
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type,
                                      style:
                                          GoogleFonts.montserrat(fontSize: 14)),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            controller.selectedVaccinationType.value = val,
                        validator: (val) =>
                            val == null ? 'Please select a vaccination type' : null,
                      ),
                    ),

                    _divider(),

                    // ── Schedule ──
                    _sectionTitle('Schedule'),
                    Obx(
                      () => GestureDetector(
                        onTap: () => controller.pickDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: controller.attemptedSubmit.value &&
                                      controller.preferredDate.value == null
                                  ? Colors.red
                                  : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.preferredDate.value == null
                                    ? 'Select Preferred Date'
                                    : '📅 ${controller.preferredDate.value!.day}/${controller.preferredDate.value!.month}/${controller.preferredDate.value!.year}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: controller.preferredDate.value == null
                                      ? Colors.grey.shade500
                                      : Colors.black87,
                                ),
                              ),
                              Icon(Icons.calendar_today_rounded,
                                  color: Colors.grey.shade500, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => GestureDetector(
                        onTap: () => controller.pickTime(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.preferredTime.value == null
                                    ? 'Select Preferred Time (optional)'
                                    : '🕐 ${controller.preferredTime.value!.format(context)}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: controller.preferredTime.value == null
                                      ? Colors.grey.shade500
                                      : Colors.black87,
                                ),
                              ),
                              Icon(Icons.access_time_rounded,
                                  color: Colors.grey.shade500, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),

                    _divider(),

                    // ── Location ──
                    _sectionTitle('Location'),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: controller.isLocating.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.my_location_rounded,
                                  color: Colors.white),
                          label: Text(
                            controller.isLocating.value
                                ? 'Detecting...'
                                : 'Auto Detect Farm Location',
                            style: GoogleFonts.montserrat(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: controller.isLocating.value
                              ? null
                              : () => controller.detectLocation(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'OR',
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    _fieldLabel('Enter Address Manually'),
                    _textField(
                      controller: controller.addressController,
                      hint: 'e.g. Farm No. 12, Kangeyam, Tamil Nadu',
                      isRequired: false,
                    ),

                    _divider(),



                    // ── Reminder ──
                    _sectionTitle('Reminder'),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: Obx(
                        () => Row(
                          children: [
                            Checkbox(
                              value: controller.reminderEnabled.value,
                              onChanged: (val) =>
                                  controller.reminderEnabled.value = val ?? false,
                              activeColor: const Color(0xFF1B5E20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Remind me for next vaccination',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'We\'ll remind you ~3 months after this date',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 12, color: Colors.green.shade700),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    _divider(),

                    // ── Notes ──
                    _sectionTitle('Additional Notes (Optional)'),
                    _fieldLabel('Previous vaccination details / Special instructions'),
                    TextFormField(
                      controller: controller.notesController,
                      maxLines: 4,
                      style: GoogleFonts.montserrat(fontSize: 14),
                      decoration: _inputDecoration(
                          hint: 'e.g. Last dose was Newcastle on Jan 2025...'),
                    ),

                    const SizedBox(height: 32),
                    
                    PhotoUploadSection(
                      imagePaths: controller.imagePaths,
                      attemptedSubmit: controller.attemptedSubmit,
                      onPickImage: controller.pickImage,
                    ),

                    const SizedBox(height: 32),
                    // ── Submit Button ──
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: const StadiumBorder(),
                            elevation: 0,
                          ),
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.submitBooking(),
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)
                              : Text(
                                  'Schedule Vaccination',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  // ── Helpers ──

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1B5E20),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF5D654E),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.montserrat(fontSize: 14),
      decoration: _inputDecoration(hint: hint),
      validator: isRequired
          ? (val) => (val == null || val.trim().isEmpty)
              ? 'This field is required'
              : null
          : null,
    );
  }

  InputDecoration _inputDecoration({String hint = ''}) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          GoogleFonts.montserrat(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        borderSide: const BorderSide(color: Color(0xFF5D654E)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _radioTile({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required void Function(String?) onChanged,
  }) {
    final bool selected = groupValue == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF1B5E20).withValues(alpha: 0.06)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF1B5E20)
                : Colors.grey.shade200,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: const Color(0xFF1B5E20),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.montserrat(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(color: Color(0xFFE2E4DA), thickness: 1),
    );
  }
}
