import 'package:cloud_firestore/cloud_firestore.dart';

/// customers/{uid}
class Customer {
  const Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.birthDate,
    required this.municipalityId,
  });

  factory Customer.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Customer(
      id: doc.id,
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      birthDate: data['birthDate'] as String? ?? '',
      municipalityId: data['municipalityId'] as String? ?? '',
    );
  }

  /// Firebase Auth UID.
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  /// yyyy-MM-dd
  final String birthDate;
  final String municipalityId;

  String get fullName => '$firstName $lastName'.trim();

  Map<String, dynamic> toNewDocument() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'birthDate': birthDate,
    'municipalityId': municipalityId,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

enum VetStatus { pending, approved, rejected }

/// vets/{uid}
class Vet {
  const Vet({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.practiceName,
    required this.municipalityId,
    required this.status,
    this.certificatePath,
  });

  factory Vet.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Vet(
      id: doc.id,
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      practiceName: data['practiceName'] as String? ?? '',
      municipalityId: data['municipalityId'] as String? ?? '',
      status: VetStatus.values.asNameMap()[data['status']] ?? VetStatus.pending,
      certificatePath: data['certificatePath'] as String?,
    );
  }

  /// Firebase Auth UID.
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String practiceName;
  final String municipalityId;
  final VetStatus status;

  /// Cloud Storage path of the uploaded certificate.
  final String? certificatePath;

  String get fullName => '$firstName $lastName'.trim();

  /// New vets always start as pending; an admin approves them.
  Map<String, dynamic> toNewDocument() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'practiceName': practiceName,
    'municipalityId': municipalityId,
    'status': VetStatus.pending.name,
    'certificatePath': certificatePath,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

/// municipalities/{id}
class Municipality {
  const Municipality({
    required this.id,
    required this.name,
    this.postalCode = '',
  });

  factory Municipality.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return Municipality(
      id: doc.id,
      name: data['name'] as String? ?? '',
      postalCode: data['postalCode'] as String? ?? '',
    );
  }

  final String id;
  final String name;
  final String postalCode;
}
