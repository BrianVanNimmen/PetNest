import '../../../network/appointment.dart';
import '../../../network/petnest_api.dart';

/// Loads one day of appointments for a vet (shared by the vet home and
/// consultations screens).
Future<List<Appointment>> loadVetAppointmentsForDay(
  int vetId,
  String date,
) async {
  final items = await PetNestApi.instance.getVetAppointments(
    vetId: vetId,
    from: date,
    to: date,
    limit: 50,
  );
  return [
    for (final it in items)
      Appointment(id: it.id, pet: it.petName, type: it.type, time: it.time),
  ];
}
