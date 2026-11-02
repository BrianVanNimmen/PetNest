import '../../../data/models/pet.dart';
import '../../../data/petnest_repository.dart';
import '../../../data/user_session.dart';
import '../../../strings.dart';
import '../view_model.dart';

/// The vet's patients: the pets that have this vet as their vet.
class VetPatientsViewModel extends ViewModel {
  VetPatientsViewModel({PetNestRepository? repository})
    : _repository = repository ?? PetNestRepository.instance;

  final PetNestRepository _repository;

  List<Pet> _patients = const [];
  List<Pet> get patients => _patients;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Pet? findPatient(String id) => _patients.where((p) => p.id == id).firstOrNull;

  Future<void> loadPatients() async {
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
      _patients = await _repository.getPetsForVet(vetId);
    } catch (e) {
      _error = Strings.somethingWentWrong(describeError(e));
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
