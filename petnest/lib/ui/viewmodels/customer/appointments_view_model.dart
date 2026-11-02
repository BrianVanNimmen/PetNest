import 'package:flutter/foundation.dart';

import '../../../model/simple_item.dart';
import '../../../network/appointment.dart';
import '../../../network/petnest_api.dart';
import '../../../network/user_session.dart';
import '../../../util/text.dart';
import '../view_model.dart';

class AppointmentsViewModel extends ViewModel {
  List<Appointment> _appointments = const [];
  List<Appointment> get appointments => _appointments;

  Set<String> _occupiedSlots = const {};
  Set<String> get occupiedSlots => _occupiedSlots;

  List<SimpleItem> _vets = const [];

  void setVets(List<SimpleItem> vets) {
    _vets = vets;
    loadAppointments();
  }

  Future<void> loadOccupiedSlots(String date, int vetId) async {
    try {
      final items = await PetNestApi.instance.getVetAppointments(
        vetId: vetId,
        from: date,
        to: date,
        limit: 50,
      );
      // "2026-05-26 09:00:00" -> "09:00"
      _occupiedSlots = {
        for (final it in items)
          if (it.scheduledDateTime.split(' ') case [_, final time, ...])
            time.take(5),
      };
      notify();
    } catch (e) {
      debugPrint('APPOINTMENT: loading occupied slots failed: $e');
    }
  }

  void clearOccupiedSlots() {
    _occupiedSlots = const {};
    notify();
  }

  Future<void> loadAppointments() async {
    final customerId = UserSession.id;
    if (customerId == null) return;

    try {
      final items = await PetNestApi.instance.getCustomerAppointments(
        customerId: customerId,
        limit: 50,
      );
      _appointments = [for (final it in items) _toAppointment(it)];
      notify();
    } catch (e) {
      debugPrint('APPOINTMENT: error loading appointments: $e');
    }
  }

  Appointment _toAppointment(AppointmentApiItem it) {
    final parts = it.scheduledDateTime.split(' ');
    final date = parts.first;
    final time = parts.length > 1 ? parts[1].take(5) : '';
    final vetName =
        _vets.where((vet) => vet.id == it.vetId).firstOrNull?.name ?? '';
    return Appointment(
      id: it.id,
      pet: it.petName,
      time: time,
      type: it.type,
      date: date,
      vet: vetName,
    );
  }

  Future<bool> deleteAppointment(int id) async {
    try {
      final response = await PetNestApi.instance.deleteAppointment(id);
      if (response.isSuccessful && response.status == 200) {
        await loadAppointments();
        return true;
      }
      debugPrint('APPOINTMENT: delete failed: ${response.message}');
    } catch (e) {
      debugPrint('APPOINTMENT: network error on delete: $e');
    }
    return false;
  }

  Future<bool> createAppointment({
    required int petId,
    required int vetId,
    required String date,
    required String time,
    required String type,
  }) async {
    final customerId = UserSession.id;
    if (customerId == null) {
      debugPrint('APPOINTMENT: no customer id in session');
      return false;
    }
    if (date.trim().isEmpty || time.trim().isEmpty) {
      debugPrint('APPOINTMENT: date or time missing');
      return false;
    }

    final safeTime = time.take(5);
    final request = AppointmentCreateRequest(
      petId: petId,
      customerId: customerId,
      vetId: vetId,
      scheduledDateTime: '$date $safeTime:00',
      type: type,
    );

    try {
      final response = await PetNestApi.instance.createAppointment(request);
      if (response.isSuccessful) {
        await loadAppointments();
        return true;
      }
      debugPrint('APPOINTMENT: ${response.message}');
    } catch (e) {
      debugPrint('APPOINTMENT: network error: $e');
    }
    return false;
  }
}
