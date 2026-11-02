import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/models/profiles.dart';
import '../../../data/petnest_repository.dart';
import '../../../data/user_session.dart';
import '../../../strings.dart';
import '../view_model.dart';
import 'ui_state.dart';

class RegisterCustomerViewModel extends ViewModel {
  /// With [useSignedInAccount], the profile is created for the account that
  /// is already signed in (Google) instead of a new email/password account.
  RegisterCustomerViewModel({
    this.useSignedInAccount = false,
    PetNestRepository? repository,
  }) : _repository = repository ?? PetNestRepository.instance {
    _loadMunicipalities();
  }

  final bool useSignedInAccount;
  final PetNestRepository _repository;

  UiState _uiState = const UiIdle();
  UiState get uiState => _uiState;

  List<Municipality> _municipalities = const [];
  List<Municipality> get municipalities => _municipalities;

  /// The signed-in Google account, to prefill the form.
  User? get signedInAccount =>
      useSignedInAccount ? _repository.currentUser : null;

  Future<void> _loadMunicipalities() async {
    try {
      _municipalities = await _repository.getMunicipalities();
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
    required String municipalityId,
  }) async {
    _uiState = const UiLoading();
    notify();

    final User user;
    try {
      user = useSignedInAccount
          ? _repository.currentUser!
          : await _repository.createAccount(email, password);
    } on FirebaseAuthException catch (e) {
      _uiState = UiError(e.message ?? Strings.registrationFailed);
      notify();
      return;
    }

    final customer = Customer(
      id: user.uid,
      firstName: firstName,
      lastName: lastName,
      email: user.email ?? email.trim(),
      birthDate: birthDate,
      municipalityId: municipalityId,
    );

    try {
      await _repository.createCustomer(customer);
    } catch (e) {
      // Don't leave an account without a profile behind
      if (!useSignedInAccount) await _repository.deleteCurrentUser();
      _uiState = UiError(Strings.somethingWentWrong(describeError(e)));
      notify();
      return;
    }

    if (useSignedInAccount) {
      // Google users go straight into the app
      UserSession.setCustomer(customer);
    } else {
      // Email users log in afterwards, as before
      await _repository.signOut();
    }
    _uiState = const UiSuccess();
    notify();
  }
}
