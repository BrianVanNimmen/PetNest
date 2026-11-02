import '../../../data/models/appointment.dart';
import '../../../data/petnest_repository.dart';
import '../../../data/user_session.dart';
import '../../../strings.dart';
import '../view_model.dart';

class VetConsultationsViewModel extends ViewModel {
  VetConsultationsViewModel({PetNestRepository? repository})
    : _repository = repository ?? PetNestRepository.instance;

  final PetNestRepository _repository;

  List<Appointment> _appointments = const [];
  List<Appointment> get appointments => _appointments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// [date] is yyyy-MM-dd.
  Future<void> loadAppointments(String date) async {
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
        DateTime.parse(date),
      );
    } catch (e) {
      _appointments = const [];
      _error = Strings.somethingWentWrong(describeError(e));
    }
    _isLoading = false;
    notify();
  }
}
