import '../../../network/appointment.dart';
import '../../../network/petnest_api.dart';
import '../view_model.dart';

class CustomerHomeViewModel extends ViewModel {
  List<Appointment> _appointments = const [];
  List<Appointment> get appointments => _appointments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadAppointments(int customerId) async {
    _isLoading = true;
    notify();

    try {
      final items = await PetNestApi.instance.getCustomerAppointments(
        customerId: customerId,
        limit: 5,
      );
      _appointments = [
        for (final it in items)
          Appointment(
            id: it.id,
            pet: it.petName,
            type: it.type,
            time: it.time,
            date: it.scheduledDateTime.split(' ').first,
          ),
      ];
    } catch (_) {
      _appointments = const [];
    }
    _isLoading = false;
    notify();
  }
}
