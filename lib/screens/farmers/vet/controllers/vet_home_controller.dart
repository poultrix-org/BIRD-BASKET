import 'package:get/get.dart';
import '../views/book_vet_view.dart';
import '../views/track_vet_view.dart';

class VetHomeController extends GetxController {
  // Mock data for nearby vets
  final nearbyVets = [
    {
      'name': 'Dr. Sharma',
      'speciality': 'Poultry Specialist',
      'distance': '2.5 km',
      'rating': '4.8',
      'experience': '10 Years',
    },
    {
      'name': 'Dr. Verma',
      'speciality': 'Livestock & Poultry',
      'distance': '5.1 km',
      'rating': '4.6',
      'experience': '7 Years',
    },
    {
      'name': 'Dr. Reddy',
      'speciality': 'Avian Medicine',
      'distance': '8.0 km',
      'rating': '4.9',
      'experience': '15 Years',
    },
  ].obs;

  void navigateToBookVet() {
    Get.to(() => BookVetView());
  }

  void navigateToTrackVet() {
    Get.to(() => TrackVetView());
  }
}
