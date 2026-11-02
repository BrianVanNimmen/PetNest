import '../../../network/patient.dart';
import '../../../network/petnest_api.dart';
import '../../../network/user_session.dart';
import '../../../strings.dart';
import '../view_model.dart';

class VetPatientsViewModel extends ViewModel {
  List<Patient> _patients = const [];
  List<Patient> get patients => _patients;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Patient? findPatient(int id) =>
      _patients.where((p) => p.id == id).firstOrNull;

  Future<void> loadPatients() async {
    final vetId = UserSession.vetId;
    if (vetId == null) {
      _error = Strings.invalidSessionLoginAgain;
      notify();
      return;
    }
    _isLoading = true;
    _error = null;
    notify();

    try {
      _patients = await PetNestApi.instance.getPatientsForVet(vetId);
    } catch (e) {
      _error = Strings.networkError(e);
    }
    _isLoading = false;
    notify();
  }

  void clear() {
    _patients = const [];
    _error = null;
    notify();
  }
}
