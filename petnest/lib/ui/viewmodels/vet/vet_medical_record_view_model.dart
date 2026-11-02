import 'package:material_ui/material_ui.dart';

import '../../../network/medical_record.dart';
import '../../../network/petnest_api.dart';
import '../../../strings.dart';
import '../view_model.dart';

class VetMedicalRecordViewModel extends ViewModel {
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

  int? _currentPetId;

  void resetSaveSucceeded() {
    _saveSucceeded = false;
  }

  void clearError() {
    _error = null;
  }

  Future<void> load(int petId) async {
    _currentPetId = petId;
    _isLoading = true;
    _error = null;
    _saveSucceeded = false;
    notify();

    try {
      // No record yet → the fields stay empty
      final record = await PetNestApi.instance.getMedicalRecord(petId);
      weight.text = record?.weight ?? '';
      teethStatus.text = record?.teethStatus ?? '';
      bonesStatus.text = record?.bonesStatus ?? '';
      musclesStatus.text = record?.musclesStatus ?? '';
      notes.text = record?.notes ?? '';
    } catch (e) {
      _error = Strings.networkError(e);
    }
    _isLoading = false;
    notify();
  }

  Future<void> save() async {
    final petId = _currentPetId;
    if (petId == null) return;
    _isSaving = true;
    _error = null;
    _saveSucceeded = false;
    notify();

    final request = MedicalRecordUpdateRequest(
      petId: petId,
      weight: weight.text.trim().isEmpty ? null : weight.text,
      teethStatus: teethStatus.text,
      bonesStatus: bonesStatus.text,
      musclesStatus: musclesStatus.text,
      notes: notes.text.trim().isEmpty ? null : notes.text,
    );

    try {
      final response = await PetNestApi.instance.saveMedicalRecord(request);
      // An empty body after saving also counts as success
      final emptyBody =
          response.isSuccessful &&
          response.status == null &&
          response.message == null;
      if (response.status == 200 || emptyBody) {
        _saveSucceeded = true;
      } else {
        _error = response.message ?? Strings.saveFailed;
      }
    } catch (e) {
      _error = Strings.networkError(e);
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
