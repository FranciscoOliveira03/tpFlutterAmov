import 'location.dart';

class Contact {
  final int id;
  String name;
  String email;
  String phone;
  DateTime? birthDate;
  String? imagePath;
  List<Location> locations;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.birthDate,
    this.imagePath,
    this.locations = const [],
  });


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'birthDate': birthDate?.toIso8601String(),
      'imagePath': imagePath,
      'locations': locations.map((location) => location.toJson()).toList(),
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      imagePath: json['imagePath'],
      locations: (json['locations'] as List)
          .map((locationJson) => Location.fromJson(locationJson))
          .toList(),
    );
  }
}
