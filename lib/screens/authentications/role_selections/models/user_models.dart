// models/user_model.dart

class UserModel {
  String? userId; // This will be set from Supabase auth
  String role;
  DateTime? createdAt;

  // Common Fields
  String? fullName;
  String? phone;
  String? email; // Added email field
  String? address;
  String? idProofPath; // For Vet, Chicks Delivery

  // Farmer
  String? farmAddress;
  String? farmGpsLat;
  String? farmGpsLong;
  String? landSize;
  int? numberOfHens;
  String? typeOfHens; // Broiler / Country / Layer
  String? farmProofPath;

  // Veterinarian
  String? clinicName;
  int? experience; // years
  String? specialization; // Poultry / General / Other

  // Company (Feed/Medicine)
  String? companyName;
  String? ownerName;
  String? companyAddress;
  String? supplyType; // Feed / Medicine / Both
  int? deliveryRadius; // km
  String? businessProofPath;

  // Chicks Delivery Person
  String? vehicleType; // Bike / Auto / Van / Pickup
  // experience
  // deliveryRadius
  // address

  // --- NEW: Meat Shop ---
  String? shopName;
  String? shopAddress;
  String? shopProofPath;
  // deliveryRadius (already exists)

  UserModel({
    required this.role,
    this.userId,
    this.createdAt,
    this.fullName,
    this.phone,
    this.email, // Added to constructor
    this.address,
    this.idProofPath,
    this.farmAddress,
    this.farmGpsLat,
    this.farmGpsLong,
    this.landSize,
    this.numberOfHens,
    this.typeOfHens,
    this.farmProofPath,
    this.clinicName,
    this.experience,
    this.specialization,
    this.companyName,
    this.ownerName,
    this.companyAddress,
    this.supplyType,
    this.deliveryRadius,
    this.businessProofPath,
    this.vehicleType,
    // --- NEW: Meat Shop ---
    this.shopName,
    this.shopAddress,
    this.shopProofPath,
  });

  // A helper method to get the primary name based on role
  String get primaryName {
    switch (role) {
      case 'Farmer':
      case 'Veterinarian':
      case 'Chicks Delivery':
        return fullName ?? 'N/A';
      case 'Company':
        return companyName ?? 'N/A';
    // --- NEW: Meat Shop ---
      case 'Meat Shop':
        return shopName ?? 'N/A';
      default:
        return 'N/A';
    }
  }

  // --- NEW: toJson() method ---
  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'created_at': createdAt?.toIso8601String(),
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'address': address,
      'id_proof_path': idProofPath,
      'farm_address': farmAddress,
      'farm_gps_lat': farmGpsLat,
      'farm_gps_long': farmGpsLong,
      'land_size': landSize,
      'number_of_hens': numberOfHens,
      'type_of_hens': typeOfHens,
      'farm_proof_path': farmProofPath,
      'clinic_name': clinicName,
      'experience': experience,
      'specialization': specialization,
      'company_name': companyName,
      'owner_name': ownerName,
      'company_address': companyAddress,
      'supply_type': supplyType,
      'delivery_radius': deliveryRadius,
      'business_proof_path': businessProofPath,
      'vehicle_type': vehicleType,
      // --- NEW: Meat Shop ---
      'shop_name': shopName,
      'shop_address': shopAddress,
      'shop_proof_path': shopProofPath,
    };
  }
}