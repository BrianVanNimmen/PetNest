import '../../../network/medical_record.dart';
import '../../../network/petnest_api.dart';
import '../view_model.dart';

class MedicalRecordViewModel extends ViewModel {
  MedicalRecord? _record;
  MedicalRecord? get record => _record;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> load(int petId) async {
    _isLoading = true;
    notify();

    try {
      _record = await PetNestApi.instance.getMedicalRecord(petId);
    } catch (_) {
      _record = null;
    }
    _isLoading = false;
    notify();
  }
}
