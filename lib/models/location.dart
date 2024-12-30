class Location {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  Location({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  // Método para converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Método para criar um objeto Location a partir de JSON
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'],
      longitude: json['longitude'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
