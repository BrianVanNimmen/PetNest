import 'json.dart';
import 'pet.dart';

class MedicalRecord {
  const MedicalRecord({
    required this.id,
    required this.petId,
    this.weight,
    this.teethStatus,
    this.bonesStatus,
    this.musclesStatus,
    this.notes,
    this.pet,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    final pet = asMap(json['pet']);
    return MedicalRecord(
      id: asInt(json['id']) ?? 0,
      petId: asInt(json['dier_id']) ?? 0,
      weight: asString(json['gewicht']),
      teethStatus: asString(json['gebit_status']),
      bonesStatus: asString(json['botten_status']),
      musclesStatus: asString(json['spieren_status']),
      notes: asString(json['opmerking']),
      pet: pet == null ? null : PetDetail.fromJson(pet),
    );
  }

  final int id;
  final int petId;
  final String? weight;
  final String? teethStatus;
  final String? bonesStatus;
  final String? musclesStatus;
  final String? notes;
  final PetDetail? pet;
}

class MedicalRecordUpdateRequest {
  const MedicalRecordUpdateRequest({
    required this.petId,
    required this.weight,
    required this.teethStatus,
    required this.bonesStatus,
    required this.musclesStatus,
    required this.notes,
  });

  final int petId;
  final String? weight;
  final String teethStatus;
  final String bonesStatus;
  final String musclesStatus;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'dier_id': petId,
    'gewicht': weight,
    'gebit_status': teethStatus,
    'botten_status': bonesStatus,
    'spieren_status': musclesStatus,
    'opmerking': notes,
  };
}
