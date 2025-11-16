// models/user_model.dart

class UserModel {
  String? userId;
  String role;
  DateTime? createdAt;

  // Common Fields
  String? fullName;
  String? phone;
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

  UserModel({
    required this.role,
    this.userId,
    this.createdAt,
    this.fullName,
    this.phone,
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
      default:
        return 'N/A';
    }
  }
}