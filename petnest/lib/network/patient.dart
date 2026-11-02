import 'json.dart';

class Patient {
  const Patient({
    required this.id,
    required this.name,
    required this.species,
    this.birthDate,
    this.photoUrl,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
    id: asInt(json['id']) ?? 0,
    name: asString(json['naam']) ?? '',
    species: asString(json['soort']) ?? '',
    birthDate: asString(json['geboortedatum']),
    photoUrl: asString(json['foto_url']),
  );

  final int id;
  final String name;
  final String species;
  final String? birthDate;
  final String? photoUrl;
}
