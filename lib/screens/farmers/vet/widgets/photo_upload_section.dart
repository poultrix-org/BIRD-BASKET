import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PhotoUploadSection extends StatelessWidget {
  final RxList<RxnString> imagePaths;
  final RxBool attemptedSubmit;
  final Function(int) onPickImage;

  const PhotoUploadSection({
    super.key,
    required this.imagePaths,
    required this.attemptedSubmit,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 16),
          child: Text(
            'Upload Photos',
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B5E20),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Text(
          'Upload 3 photos (compulsory).',
          style: GoogleFonts.montserrat(color: Colors.black, fontSize: 13),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Row(
            children: List.generate(3, (index) {
              final path = imagePaths[index].value;
              final isMissing = attemptedSubmit.value && path == null;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onPickImage(index),
                  child: Container(
                    height: 100,
                    margin: EdgeInsets.only(
                      right: index < 2 ? 8 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: isMissing ? Colors.red.shade50 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: path != null
                            ? const Color(0xFF5D654E)
                            : isMissing ? Colors.red : Colors.grey.shade300,
                        width: isMissing ? 1.5 : 1.0,
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
                              Icon(Icons.add_a_photo,
                                  color: isMissing ? Colors.red.shade300 : Colors.grey.shade400, size: 28),
                              const SizedBox(height: 4),
                              Text(
                                'Photo ${index + 1}',
                                style: GoogleFonts.montserrat(
                                  color: isMissing ? Colors.red : Colors.grey.shade500,
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
      ],
    );
  }
}
