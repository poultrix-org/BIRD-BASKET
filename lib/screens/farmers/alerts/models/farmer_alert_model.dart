class FarmerAlertModel {
  final String id;
  final String farmerId;
  final String type; // 'disease' or 'general'
  final String? category; // 'disease_type' or 'category'
  final String title;
  final String severity; // 'low', 'medium', 'high'
  final double radius; // Affected Radius in KM
  final List<String>? symptoms;
  final int? birdsAffected;
  final String description;
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final String? locationName;
  final DateTime createdAt;

  FarmerAlertModel({
    required this.id,
    required this.farmerId,
    required this.type,
    this.category,
    required this.title,
    required this.severity,
    required this.radius,
    this.symptoms,
    this.birdsAffected,
    required this.description,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.locationName,
    required this.createdAt,
  });

  factory FarmerAlertModel.fromJson(Map<String, dynamic> json) {
    List<String>? parsedSymptoms;
    if (json['symptoms'] != null) {
      if (json['symptoms'] is List) {
        parsedSymptoms = List<String>.from(json['symptoms']);
      } else if (json['symptoms'] is String) {
        parsedSymptoms = (json['symptoms'] as String).split(',');
      }
    }

    return FarmerAlertModel(
      id: json['alert_id'] ?? json['id'] ?? '',
      farmerId: json['user_id'] ?? json['farmer_id'] ?? '',
      type: json['alert_type'] ?? json['type'] ?? 'general',
      category: json['disease_type'] ?? json['category'],
      title: json['title'] ?? 'Unknown Alert',
      severity: json['severity'] ?? 'medium',
      radius: (json['affected_radius_km'] ?? json['radius'] ?? 5.0).toDouble(),
      symptoms: parsedSymptoms,
      birdsAffected: json['birds_affected'] != null
          ? int.tryParse(json['birds_affected'].toString())
          : null,
      description: json['description'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      locationName: json['location_name'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alert_id': id,
      'user_id': farmerId,
      'alert_type': type,
      if (type == 'disease') 'disease_type': category,
      if (type == 'general') 'category': category,
      'title': title,
      'severity': severity,
      'affected_radius_km': radius,
      if (symptoms != null) 'symptoms': symptoms,
      if (birdsAffected != null) 'birds_affected': birdsAffected,
      'description': description,
      'image_url': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
