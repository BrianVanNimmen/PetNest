import 'package:cloud_firestore/cloud_firestore.dart';

/// appointments/{slotId}
///
/// The document ID is the booked slot ([slotId]); bookedSlots/{slotId} is
/// written in the same batch so a slot can only be booked once.
class Appointment {
  const Appointment({
    required this.id,
    required this.petId,
    required this.petName,
    required this.customerId,
    required this.customerName,
    required this.vetId,
    required this.vetName,
    required this.date,
    required this.time,
    required this.scheduledAt,
    required this.type,
    this.notes,
  });

  factory Appointment.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return Appointment(
      id: doc.id,
      petId: data['petId'] as String? ?? '',
      petName: data['petName'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      vetId: data['vetId'] as String? ?? '',
      vetName: data['vetName'] as String? ?? '',
      date: data['date'] as String? ?? '',
      time: data['time'] as String? ?? '',
      scheduledAt:
          (data['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime(1970),
      type: data['type'] as String? ?? '',
      notes: data['notes'] as String?,
    );
  }

  static String slotId(String vetId, String date, String time) =>
      '${vetId}_${date}_$time';

  final String id;
  final String petId;
  final String petName;
  final String customerId;
  final String customerName;
  final String vetId;
  final String vetName;

  /// yyyy-MM-dd
  final String date;

  /// HH:mm
  final String time;
  final DateTime scheduledAt;

  /// See [AppointmentType].
  final String type;
  final String? notes;
}
