import 'package:firebase_auth/firebase_auth.dart';

import '../../../network/account.dart';
import '../../../network/petnest_api.dart';
import '../../../strings.dart';
import '../view_model.dart';
import 'ui_state.dart';

class RegisterCustomerViewModel extends ViewModel {
  RegisterCustomerViewModel() {
    _loadMunicipalities();
  }

  UiState _uiState = const UiIdle();
  UiState get uiState => _uiState;

  List<Municipality> _municipalities = const [];
  List<Municipality> get municipalities => _municipalities;

  Future<void> _loadMunicipalities() async {
    try {
      _municipalities = await PetNestApi.instance.getMunicipalities();
      notify();
    } catch (_) {
      // The municipality field simply stays empty
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String birthDate,
    required int municipalityId,
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

    final request = CustomerRegisterRequest(
      firstName: firstName,
      lastName: lastName,
      email: email.trim(),
      firebaseUid: uid,
      birthDate: birthDate,
      municipalityId: municipalityId,
    );

    try {
      final response = await PetNestApi.instance.registerCustomer(request);
      _uiState = response.isSuccessful
          ? const UiSuccess()
          : UiError(response.message ?? Strings.unknownServerError);
    } catch (e) {
      _uiState = UiError(Strings.networkError(e));
    }
    notify();
  }
}
