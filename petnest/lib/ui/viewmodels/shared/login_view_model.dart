import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/models/profiles.dart';
import '../../../data/petnest_repository.dart';
import '../../../data/user_session.dart';
import '../../../strings.dart';
import '../view_model.dart';

sealed class LoginUiState {
  const LoginUiState();
}

class LoginIdle extends LoginUiState {
  const LoginIdle();
}

class LoginLoading extends LoginUiState {
  const LoginLoading();
}

class CustomerLoggedIn extends LoginUiState {
  const CustomerLoggedIn();
}

class VetLoggedIn extends LoginUiState {
  const VetLoggedIn();
}

/// Signed in with Google, but there is no PetNest profile for the account
/// yet: the user still has to register as a customer or vet.
class ProfileRequired extends LoginUiState {
  const ProfileRequired();
}

class LoginError extends LoginUiState {
  const LoginError(this.message);

  final String message;
}

// A single ViewModel for both roles: the role is only known after signing in
// (Firebase Auth → customers/{uid} or vets/{uid}).
class LoginViewModel extends ViewModel {
  LoginViewModel({PetNestRepository? repository})
    : _repository = repository ?? PetNestRepository.instance;

  final PetNestRepository _repository;

  LoginUiState _uiState = const LoginIdle();
  LoginUiState get uiState => _uiState;

  void _set(LoginUiState state) {
    _uiState = state;
    notify();
  }

  Future<void> login(String email, String password) async {
    _set(const LoginLoading());
    try {
      final user = await _repository.signInWithEmail(email, password);
      await _loadProfile(user, viaGoogle: false);
    } on FirebaseAuthException catch (e) {
      _set(LoginError(e.message ?? Strings.loginFailed));
    } catch (e) {
      _set(LoginError(Strings.somethingWentWrong(describeError(e))));
    }
  }

  Future<void> loginWithGoogle() async {
    _set(const LoginLoading());
    try {
      final user = await _repository.signInWithGoogle();
      if (user == null) {
        _set(const LoginIdle()); // cancelled
        return;
      }
      await _loadProfile(user, viaGoogle: true);
    } catch (e) {
      _set(LoginError(describeError(e)));
    }
  }

  Future<void> _loadProfile(User user, {required bool viaGoogle}) async {
    final customer = await _repository.getCustomer(user.uid);
    if (customer != null) {
      UserSession.setCustomer(customer);
      _set(const CustomerLoggedIn());
      return;
    }

    final vet = await _repository.getVet(user.uid);
    if (vet == null) {
      if (viaGoogle) {
        // Stay signed in: the registration screens use this account
        _set(const ProfileRequired());
      } else {
        await _repository.signOut();
        _set(const LoginError(Strings.noUserFound));
      }
      return;
    }
    if (vet.status != VetStatus.approved) {
      await _repository.signOut();
      _set(
        LoginError(
          vet.status == VetStatus.rejected
              ? Strings.accountRejected
              : Strings.accountNotApproved,
        ),
      );
      return;
    }
    UserSession.setVet(vet);
    _set(const VetLoggedIn());
  }
}
