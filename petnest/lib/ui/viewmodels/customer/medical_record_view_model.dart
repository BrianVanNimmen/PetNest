import '../../../data/models/pet.dart';
import '../../../data/petnest_repository.dart';
import '../view_model.dart';

/// The customer's read-only view of a pet's medical record.
class MedicalRecordViewModel extends ViewModel {
  MedicalRecordViewModel({PetNestRepository? repository})
    : _repository = repository ?? PetNestRepository.instance;

  final PetNestRepository _repository;

  Pet? _pet;
  Pet? get pet => _pet;

  /// Null until the vet fills in a record.
  MedicalRecord? _record;
  MedicalRecord? get record => _record;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> load(String petId) async {
    _isLoading = true;
    notify();

    try {
      final (pet, record) = await (
        _repository.getPet(petId),
        _repository.getMedicalRecord(petId),
      ).wait;
      _pet = pet;
      _record = record;
    } catch (_) {
      _pet = null;
      _record = null;
    }
    _isLoading = false;
    notify();
  }
}
