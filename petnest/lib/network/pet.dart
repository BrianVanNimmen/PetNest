import 'dart:typed_data';

import 'json.dart';

class Pet {
  const Pet({
    required this.id,
    required this.name,
    this.species,
    this.photoUrl,
  });

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
    id: asInt(json['id']) ?? 0,
    name: asString(json['naam']) ?? '',
    species: asString(json['soort']),
    photoUrl: asString(json['foto_url']),
  );

  final int id;
  final String name;
  final String? species;
  final String? photoUrl;
}

class PetDetail {
  const PetDetail({
    required this.id,
    this.name,
    this.species,
    this.birthDate,
    this.photoUrl,
    this.vetId,
  });

  factory PetDetail.fromJson(Map<String, dynamic> json) => PetDetail(
    id: asInt(json['id']) ?? 0,
    name: asString(json['naam']),
    species: asString(json['soort']),
    birthDate: asString(json['geboortedatum']),
    photoUrl: asString(json['foto_url']),
    vetId: asInt(json['dierenarts_id']),
  );

  final int id;
  final String? name;
  final String? species;
  final String? birthDate;
  final String? photoUrl;
  final int? vetId;
}

class PetUpdateRequest {
  const PetUpdateRequest({
    required this.id,
    required this.name,
    required this.species,
    required this.birthDate,
    required this.customerId,
    required this.vetId,
  });

  final int id;
  final String name;
  final String species;
  final String birthDate;
  final int customerId;
  final int vetId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'naam': name,
    'soort': species,
    'geboortedatum': birthDate,
    'klant_id': customerId,
    'dierenarts_id': vetId,
  };
}

/// A file picked by the user, ready to upload.
class PickedUpload {
  const PickedUpload({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}
