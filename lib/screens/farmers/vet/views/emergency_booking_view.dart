import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/emergency_booking_controller.dart';
import '../widgets/photo_upload_section.dart';

class EmergencyBookingView extends StatelessWidget {
  final EmergencyBookingController controller = Get.put(EmergencyBookingController());

  EmergencyBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Emergency Support',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: const Color(0xFF1B5E20),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF1B5E20)),
      ),
      body: Obx(
        () => Stack(
          children: [
            SingleChildScrollView(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency Severity',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF5D654E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: ['Low', 'Medium', 'Critical']
                                .map((level) => Expanded(
                                      child: GestureDetector(
                                        onTap: () => controller.emergencyLevel.value = level,
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 4),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            color: controller.emergencyLevel.value == level
                                                ? (level == 'Low'
                                                    ? Colors.green.shade100
                                                    : level == 'Medium'
                                                        ? Colors.orange.shade100
                                                        : Colors.red.shade100)
                                                : Colors.white,
                                            border: Border.all(
                                              color: controller.emergencyLevel.value == level
                                                  ? (level == 'Low'
                                                      ? Colors.green
                                                      : level == 'Medium'
                                                          ? Colors.orange
                                                          : Colors.red)
                                                  : Colors.grey.shade300,
                                              width: controller.emergencyLevel.value == level ? 2 : 1,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              level == 'Low' ? '🟢 Low' : level == 'Medium' ? '🟡 Medium' : '🔴 Critical',
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.bold,
                                                color: controller.emergencyLevel.value == level
                                                    ? (level == 'Low'
                                                        ? Colors.green.shade800
                                                        : level == 'Medium'
                                                            ? Colors.orange.shade800
                                                            : Colors.red.shade800)
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: controller.selectedIssue.value,
                            decoration: InputDecoration(
                              hintText: 'e.g. Disease, Emergency...',
                              hintStyle: GoogleFonts.montserrat(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              labelText: 'What is the primary issue?',
                              labelStyle: GoogleFonts.montserrat(
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
                                borderSide: const BorderSide(color: Color(0xFF5D654E)),
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
                            onChanged: (val) => controller.selectedIssue.value = val,
                            validator: (value) => value == null ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          
                          // Audio Record Support
                          Text(
                            'Record Voice Description',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF5D654E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          controller.audioFilePath.value != null
                              ? Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.green.shade200),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.audiotrack, color: Colors.green),
                                          SizedBox(width: 8),
                                          Text('Voice description saved', style: GoogleFonts.montserrat(color: Colors.green, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: controller.discardRecording,
                                      ),
                                    ],
                                  ),
                                )
                              : GestureDetector(
                                  onLongPressStart: (_) => controller.startRecording(),
                                  onLongPressEnd: (_) => controller.stopRecording(),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    decoration: BoxDecoration(
                                      color: controller.isRecording.value ? Colors.red.shade50 : Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: controller.isRecording.value ? Colors.red : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          controller.isRecording.value ? Icons.mic : Icons.mic_none,
                                          color: controller.isRecording.value ? Colors.red : Colors.grey.shade500,
                                          size: 32,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          controller.isRecording.value ? 'Recording... Release to stop' : 'Hold to Record Voice',
                                          style: GoogleFonts.montserrat(
                                            color: controller.isRecording.value ? Colors.red : Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: controller.descriptionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Or type description (optional)',
                              hintStyle: GoogleFonts.montserrat(
                                color: Colors.grey.shade400,
                                fontSize: 13,
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
                                borderSide: const BorderSide(color: Color(0xFF5D654E)),
                              ),
                            ),
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
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  textController: controller.birdsController,
                                  label: 'Total Birds',
                                  hint: 'e.g. 500',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  textController: controller.affectedBirdsController,
                                  label: 'Affected Birds',
                                  hint: 'e.g. 50',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Select Symptoms:',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF5D654E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: controller.symptomOptions.map((symptom) {
                              final isSelected = controller.selectedSymptoms.contains(symptom);
                              return FilterChip(
                                label: Text(symptom),
                                selected: isSelected,
                                selectedColor: const Color(0xFF5D654E).withOpacity(0.2),
                                checkmarkColor: const Color(0xFF5D654E),
                                onSelected: (_) => controller.toggleSymptom(symptom),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    _buildDivider(),
                    const SizedBox(height: 8),



                    // ── Location & Visit Type ──
                    _buildSectionTitle('Location & Visit Type'),
                    _buildCard(
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.my_location, size: 22),
                              label: Text(
                                'Auto Detect Farm Location',
                                style: GoogleFonts.montserrat(
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
                          _buildTextField(
                            textController: controller.locationController,
                            label: 'Or Enter Address Manually',
                            hint: 'e.g. Farm No. 12, Kangeyam, Tamil Nadu',
                          ),

                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    _buildDivider(),
                    const SizedBox(height: 8),

                    // ── Payment & Trust Info ──
                    _buildSectionTitle('Payment Info'),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Consultation Fee',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  color: Color(0xFF5D654E),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '₹200',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Pay only after a vet accepts your request. Do not pay upfront.',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    PhotoUploadSection(
                      imagePaths: controller.imagePaths,
                      attemptedSubmit: controller.attemptedSubmit,
                      onPickImage: controller.pickImage,
                    ),
                    const SizedBox(height: 32),

                    // ── Submit Button ──
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: controller.isLoading.value ? null : () => controller.broadcastVetRequest(),
                        child: Text(
                          'Find Vet Now',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Full screen loading overlay
            if (controller.isSearchingVets.value)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Colors.black),
                        const SizedBox(height: 24),
                        Text(
                          "Emergency Alert Broadcasted",
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Searching nearby vets within 30km...",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildTextField({
    required TextEditingController textController,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5D654E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: textController,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.montserrat(
              color: Colors.grey.shade400,
              fontSize: 13,
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
              borderSide: const BorderSide(color: Color(0xFF5D654E)),
            ),
          ),
          validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 12.0),
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
    );
  }
}

class _TrustIndicator extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _TrustIndicator({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54),
        ),
      ],
    );
  }
}
