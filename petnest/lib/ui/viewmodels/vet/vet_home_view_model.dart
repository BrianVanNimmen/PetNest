import '../../../data/models/appointment.dart';
import '../../../data/petnest_repository.dart';
import '../../../data/user_session.dart';
import '../../../strings.dart';
import '../view_model.dart';

class VetHomeViewModel extends ViewModel {
  VetHomeViewModel({PetNestRepository? repository})
    : _repository = repository ?? PetNestRepository.instance {
    loadTodayAppointments();
  }

  final PetNestRepository _repository;

  final String vetName = UserSession.fullName;

  List<Appointment> _appointments = const [];
  List<Appointment> get appointments => _appointments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadTodayAppointments() async {
    final vetId = UserSession.uid;
    if (vetId == null) {
      _error = Strings.invalidSession;
      notify();
      return;
    }
    _isLoading = true;
    _error = null;
    notify();

    try {
      _appointments = await _repository.getVetAppointmentsForDay(
        vetId,
        DateTime.now(),
      );
    } catch (e) {
      _error = Strings.somethingWentWrong(describeError(e));
    }
    _isLoading = false;
    notify();
  }
}
