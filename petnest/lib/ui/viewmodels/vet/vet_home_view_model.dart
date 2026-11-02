import '../../../network/appointment.dart';
import '../../../network/user_session.dart';
import '../../../strings.dart';
import '../../../util/text.dart';
import '../view_model.dart';
import 'vet_appointments.dart';

class VetHomeViewModel extends ViewModel {
  VetHomeViewModel() {
    loadTodayAppointments();
  }

  final String vetName = UserSession.fullName;

  List<Appointment> _appointments = const [];
  List<Appointment> get appointments => _appointments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadTodayAppointments() async {
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
      _appointments = await loadVetAppointmentsForDay(vetId, todayIso());
    } catch (e) {
      _error = Strings.networkError(e);
    }
    _isLoading = false;
    notify();
  }
}
