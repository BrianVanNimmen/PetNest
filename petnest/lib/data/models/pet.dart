import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

/// pets/{petId}
class Pet {
  const Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    this.vetId,
    this.birthDate,
    this.photoUrl,
  });

  factory Pet.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Pet(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      vetId: data['vetId'] as String?,
      name: data['name'] as String? ?? '',
      species: data['species'] as String? ?? '',
      birthDate: data['birthDate'] as String?,
      photoUrl: data['photoUrl'] as String?,
    );
  }

  final String id;

  /// UID of the customer who owns the pet.
  final String ownerId;

  /// UID of the pet's vet, if one was chosen.
  final String? vetId;
  final String name;
  final String species;

  /// yyyy-MM-dd
  final String? birthDate;

  /// Cloud Storage download URL.
  final String? photoUrl;
}

/// medicalRecords/{petId}
class MedicalRecord {
  const MedicalRecord({
    this.weight,
    this.teethStatus = '',
    this.bonesStatus = '',
    this.musclesStatus = '',
    this.notes,
  });

  factory MedicalRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return MedicalRecord(
      weight: data['weight'] as String?,
      teethStatus: data['teethStatus'] as String? ?? '',
      bonesStatus: data['bonesStatus'] as String? ?? '',
      musclesStatus: data['musclesStatus'] as String? ?? '',
      notes: data['notes'] as String?,
    );
  }

  final String? weight;
  final String teethStatus;
  final String bonesStatus;
  final String musclesStatus;
  final String? notes;
}

/// A file picked by the user, ready to upload.
class PickedUpload {
  const PickedUpload({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;

  String get contentType => switch (name.split('.').last.toLowerCase()) {
    'jpg' || 'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'gif' => 'image/gif',
    'webp' => 'image/webp',
    'heic' => 'image/heic',
    'pdf' => 'application/pdf',
    _ => 'application/octet-stream',
  };
}
