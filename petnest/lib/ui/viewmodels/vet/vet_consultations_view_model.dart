import '../../../network/appointment.dart';
import '../../../network/user_session.dart';
import '../../../strings.dart';
import '../view_model.dart';
import 'vet_appointments.dart';

class VetConsultationsViewModel extends ViewModel {
  List<Appointment> _appointments = const [];
  List<Appointment> get appointments => _appointments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadAppointments(String date) async {
    final vetId = UserSession.vetId;
    if (vetId == null) {
      _error = Strings.invalidSession;
      notify();
      return;
    }
    _isLoading = true;
    _error = null;
    notify();

    try {
      _appointments = await loadVetAppointmentsForDay(vetId, date);
    } catch (e) {
      _appointments = const [];
      _error = Strings.networkError(e);
    }
    _isLoading = false;
    notify();
  }
}
