import 'package:flutter/foundation.dart';

import '../../../data/models/appointment.dart';
import '../../../data/petnest_repository.dart';
import '../../../data/user_session.dart';
import '../../../model/simple_item.dart';
import '../../../strings.dart';
import '../view_model.dart';

class AppointmentsViewModel extends ViewModel {
  AppointmentsViewModel({PetNestRepository? repository})
    : _repository = repository ?? PetNestRepository.instance;

  final PetNestRepository _repository;

  List<Appointment> _appointments = const [];
  List<Appointment> get appointments => _appointments;

  /// Booked times ("HH:mm") for the chosen vet and date.
  Set<String> _occupiedSlots = const {};
  Set<String> get occupiedSlots => _occupiedSlots;

  Future<void> loadOccupiedSlots(String date, String vetId) async {
    try {
      _occupiedSlots = await _repository.getBookedTimes(vetId, date);
      notify();
    } catch (e) {
      debugPrint('APPOINTMENT: loading booked slots: ${describeError(e)}');
    }
  }

  Future<void> loadAppointments() async {
    final customerId = UserSession.uid;
    if (customerId == null) return;

    try {
      _appointments = await _repository.getCustomerAppointments(customerId);
      notify();
    } catch (e) {
      debugPrint('APPOINTMENT: loading appointments: ${describeError(e)}');
    }
  }

  /// Returns an error message, or null on success.
  Future<String?> cancelAppointment(Appointment appointment) async {
    try {
      await _repository.cancelAppointment(appointment);
      await loadAppointments();
      return null;
    } catch (e) {
      return Strings.somethingWentWrong(describeError(e));
    }
  }

  /// Returns an error message, or null on success.
  Future<String?> createAppointment({
    required SimpleItem pet,
    required SimpleItem vet,
    required String date,
    required String time,
    required String type,
  }) async {
    final customerId = UserSession.uid;
    if (customerId == null) return Strings.invalidSession;

    try {
      await _repository.createAppointment(
        petId: pet.id,
        petName: pet.name,
        customerId: customerId,
        customerName: UserSession.fullName,
        vetId: vet.id,
        vetName: vet.name,
        date: date,
        time: time,
        type: type,
      );
      return null;
    } on SlotTakenException {
      // Show the slot as taken right away
      await loadOccupiedSlots(date, vet.id);
      return Strings.slotTaken;
    } catch (e) {
      return Strings.somethingWentWrong(describeError(e));
    }
  }
}
