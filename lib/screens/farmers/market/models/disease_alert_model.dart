class DiseaseAlertModel {
  final String alertId;
  final String title;
  final String description;
  final String severity; // high, medium, low
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  DiseaseAlertModel({
    required this.alertId,
    required this.title,
    required this.description,
    required this.severity,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  factory DiseaseAlertModel.fromJson(Map<String, dynamic> json) {
    return DiseaseAlertModel(
      alertId: json['alert_id'] ?? '',
      title: json['title'] ?? 'Unknown Alert',
      description: json['description'] ?? '',
      severity: json['severity'] ?? 'low',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alert_id': alertId,
      'title': title,
      'description': description,
      'severity': severity,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
