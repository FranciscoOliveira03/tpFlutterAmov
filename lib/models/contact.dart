import 'location.dart';

class Contact {
  final int id; // ID único para identificar o contato
  final String name;
  final String email;
  final String phone;
  final DateTime? birthDate;
  final String? imagePath; // Caminho para a imagem (galeria ou capturada)
  final List<Location> locations; // Lista de localizações associadas

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.birthDate,
    this.imagePath,
    this.locations = const [],
  });

  // Método para converter para JSON (exemplo para persistência local)
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

  // Método para criar um objeto Contact a partir de JSON
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : null,
      imagePath: json['imagePath'],
      locations: (json['locations'] as List<dynamic>?)
          ?.map((loc) => Location.fromJson(loc))
          .toList() ??
          [],
    );
  }
}
