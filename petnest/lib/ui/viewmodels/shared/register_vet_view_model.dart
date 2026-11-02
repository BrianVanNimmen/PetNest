import 'package:firebase_auth/firebase_auth.dart';

import '../../../network/account.dart';
import '../../../network/pet.dart';
import '../../../network/petnest_api.dart';
import '../../../strings.dart';
import '../view_model.dart';
import 'ui_state.dart';

class RegisterVetViewModel extends ViewModel {
  RegisterVetViewModel() {
    _loadMunicipalities();
  }

  UiState _uiState = const UiIdle();
  UiState get uiState => _uiState;

  List<Municipality> _municipalities = const [];
  List<Municipality> get municipalities => _municipalities;

  String? _municipalitiesLoadError;
  String? get municipalitiesLoadError => _municipalitiesLoadError;

  Future<void> _loadMunicipalities() async {
    try {
      _municipalities = await PetNestApi.instance.getMunicipalities();
    } on HttpStatusException catch (e) {
      _municipalitiesLoadError = Strings.couldNotLoadMunicipalities(
        e.statusCode,
      );
    } catch (e) {
      _municipalitiesLoadError = Strings.noServerConnection(e);
    }
    notify();
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required int municipalityId,
    required String phone,
    required String practiceName,
    required PickedUpload certificate,
  }) async {
    _uiState = const UiLoading();
    notify();

    final String? uid;
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
      uid = credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      _uiState = UiError(e.message ?? Strings.firebaseRegistrationFailed);
      notify();
      return;
    }
    if (uid == null) {
      _uiState = const UiError(Strings.couldNotGetUid);
      notify();
      return;
    }

    try {
      final response = await PetNestApi.instance.registerVet(
        firstName: firstName,
        lastName: lastName,
        email: email.trim(),
        firebaseUid: uid,
        phone: phone,
        practiceName: practiceName,
        municipalityId: municipalityId,
        certificate: certificate,
      );
      _uiState = response.isSuccessful && response.id != null
          ? const UiSuccess()
          : UiError(response.message ?? Strings.unknownServerError);
    } catch (e) {
      _uiState = UiError(Strings.networkError(e));
    }
    notify();
  }
}
