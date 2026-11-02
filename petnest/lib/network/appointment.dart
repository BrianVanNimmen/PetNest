import 'json.dart';

/// UI model for an appointment.
class Appointment {
  const Appointment({
    required this.id,
    required this.pet,
    required this.time,
    required this.type,
    this.date = '',
    this.vet = '',
  });

  final int id;
  final String pet;
  final String time;

  /// Raw API value, see [AppointmentType].
  final String type;
  final String date;
  final String vet;
}

class AppointmentApiItem {
  const AppointmentApiItem({
    required this.id,
    required this.pet,
    required this.name,
    required this.type,
    required this.owner,
    required this.time,
    required this.scheduledDateTime,
    required this.vetId,
  });

  factory AppointmentApiItem.fromJson(Map<String, dynamic> json) =>
      AppointmentApiItem(
        id: asInt(json['id']) ?? 0,
        pet: asString(json['dier']) ?? '',
        name: asString(json['naam']) ?? '', // pet name (customer-side)
        type: asString(json['type']) ?? '',
        owner: asString(json['eigenaar']) ?? '',
        time: asString(json['tijd']) ?? '',
        scheduledDateTime: asString(json['geplande_datumtijd']) ?? '',
        vetId: asInt(json['dierenarts_id']) ?? 0,
      );

  final int id;
  final String pet;
  final String name;
  final String type;
  final String owner;

  /// Formatted by the API as "dd/MM/yyyy HH:mm".
  final String time;

  /// Raw MySQL datetime, "yyyy-MM-dd HH:mm:ss".
  final String scheduledDateTime;
  final int vetId;

  // Pet name: use "naam" when "dier" is empty (customer API variant)
  String get petName => name.isEmpty ? pet : name;
}

class AppointmentCreateRequest {
  const AppointmentCreateRequest({
    required this.petId,
    required this.customerId,
    required this.vetId,
    required this.scheduledDateTime,
    required this.type,
  });

  final int petId;
  final int customerId;
  final int vetId;
  final String scheduledDateTime;
  final String type;

  Map<String, dynamic> toJson() => {
    'dier_id': petId,
    'klant_id': customerId,
    'dierenarts_id': vetId,
    'geplande_datumtijd': scheduledDateTime,
    'type': type,
  };
}
