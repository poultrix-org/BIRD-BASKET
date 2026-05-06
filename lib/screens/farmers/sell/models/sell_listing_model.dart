class SellListingModel {
  final String? listingId;
  final String farmerId;
  final int numberOfBirds;
  final double weightPerBird;
  final double totalQuantity;
  final double pricePerKg;
  final DateTime availableDate;
  final Map<String, dynamic> location;
  final String notes;
  final String imageUrl;
  final List<String> imageUrls;
  final String status;
  final bool acceptNegotiation;
  final String? deliveryType;
  final String? urgency;
  final String? demandScore;
  final int matchedBuyersCount;
  final DateTime? createdAt;

  SellListingModel({
    this.listingId,
    required this.farmerId,
    required this.numberOfBirds,
    required this.weightPerBird,
    required this.totalQuantity,
    required this.pricePerKg,
    required this.availableDate,
    required this.location,
    this.notes = '',
    this.imageUrl = '',
    this.imageUrls = const [],
    this.status = 'active',
    this.acceptNegotiation = false,
    this.deliveryType,
    this.urgency,
    this.demandScore,
    this.matchedBuyersCount = 0,
    this.createdAt,
  });

  // Convert from Database (JSON) Map to Dart Object
  factory SellListingModel.fromJson(Map<String, dynamic> json) {
    return SellListingModel(
      listingId: json['listing_id']?.toString(),
      farmerId: json['farmer_id']?.toString() ?? '',
      numberOfBirds: int.tryParse(json['number_of_birds']?.toString() ?? '0') ?? 0,
      weightPerBird: double.tryParse(json['weight_per_bird']?.toString() ?? '0') ?? 0.0,
      totalQuantity: double.tryParse(json['total_quantity']?.toString() ?? '0') ?? 0.0,
      pricePerKg: double.tryParse(json['price_per_kg']?.toString() ?? '0') ?? 0.0,
      availableDate: DateTime.tryParse(json['available_date']?.toString() ?? '') ?? DateTime.now(),
      location: json['location'] as Map<String, dynamic>? ?? {},
      notes: json['notes']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      imageUrls: (json['image_urls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      status: json['status']?.toString() ?? 'active',
      acceptNegotiation: json['accept_negotiation'] == true,
      deliveryType: json['delivery_type']?.toString(),
      urgency: json['urgency']?.toString(),
      demandScore: json['demand_score']?.toString(),
      matchedBuyersCount: int.tryParse(json['matched_buyers_count']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  // Convert from Dart Object back to Database (JSON) Map
  Map<String, dynamic> toJson() {
    return {
      if (listingId != null) 'listing_id': listingId,
      'farmer_id': farmerId,
      'number_of_birds': numberOfBirds,
      'weight_per_bird': weightPerBird,
      'total_quantity': totalQuantity,
      'price_per_kg': pricePerKg,
      'available_date': availableDate.toIso8601String(),
      'location': location,
      'notes': notes,
      'image_url': imageUrl,
      'image_urls': imageUrls,
      'status': status,
      'accept_negotiation': acceptNegotiation,
      'delivery_type': deliveryType,
      'urgency': urgency,
      'demand_score': demandScore,
      'matched_buyers_count': matchedBuyersCount,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
    };
  }
}
