import 'package:material_ui/material_ui.dart';

import '../../../data/models/pet.dart';
import '../../../data/petnest_repository.dart';
import '../../../data/user_session.dart';
import '../../../strings.dart';
import '../view_model.dart';

/// The vet's editable view of a patient's medical record.
class VetMedicalRecordViewModel extends ViewModel {
  VetMedicalRecordViewModel({PetNestRepository? repository})
    : _repository = repository ?? PetNestRepository.instance;

  final PetNestRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _error;
  String? get error => _error;

  bool _saveSucceeded = false;
  bool get saveSucceeded => _saveSucceeded;

  final weight = TextEditingController();
  final teethStatus = TextEditingController();
  final bonesStatus = TextEditingController();
  final musclesStatus = TextEditingController();
  final notes = TextEditingController();

  String? _currentPetId;

  void resetSaveSucceeded() {
    _saveSucceeded = false;
  }

  void clearError() {
    _error = null;
  }

  Future<void> load(String petId) async {
    _currentPetId = petId;
    _isLoading = true;
    _error = null;
    _saveSucceeded = false;
    notify();

    try {
      // No record yet → the fields stay empty
      final record = await _repository.getMedicalRecord(petId);
      weight.text = record?.weight ?? '';
      teethStatus.text = record?.teethStatus ?? '';
      bonesStatus.text = record?.bonesStatus ?? '';
      musclesStatus.text = record?.musclesStatus ?? '';
      notes.text = record?.notes ?? '';
    } catch (e) {
      _error = Strings.somethingWentWrong(describeError(e));
    }
    _isLoading = false;
    notify();
  }

  Future<void> save() async {
    final petId = _currentPetId;
    final vetId = UserSession.uid;
    if (petId == null || vetId == null) return;
    _isSaving = true;
    _error = null;
    _saveSucceeded = false;
    notify();

    String? orNull(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();

    try {
      await _repository.saveMedicalRecord(
        petId,
        MedicalRecord(
          weight: orNull(weight),
          teethStatus: teethStatus.text.trim(),
          bonesStatus: bonesStatus.text.trim(),
          musclesStatus: musclesStatus.text.trim(),
          notes: orNull(notes),
        ),
        vetId: vetId,
      );
      _saveSucceeded = true;
    } catch (e) {
      _error = Strings.somethingWentWrong(describeError(e));
    }
    _isSaving = false;
    notify();
  }

  @override
  void dispose() {
    weight.dispose();
    teethStatus.dispose();
    bonesStatus.dispose();
    musclesStatus.dispose();
    notes.dispose();
    super.dispose();
  }
}
