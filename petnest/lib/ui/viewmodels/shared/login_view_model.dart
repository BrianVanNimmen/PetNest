import 'package:firebase_auth/firebase_auth.dart';

import '../../../network/petnest_api.dart';
import '../../../network/user_session.dart';
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
  const CustomerLoggedIn({
    required this.customerId,
    required this.firstName,
    required this.lastName,
  });

  final int customerId;
  final String firstName;
  final String lastName;
}

class VetLoggedIn extends LoginUiState {
  const VetLoggedIn(this.vetId);

  final int vetId;
}

class LoginError extends LoginUiState {
  const LoginError(this.message);

  final String message;
}

// A single ViewModel for both roles: the role is only known after the API
// call (email + password → Firebase → UID → login.php → customer or vet).
class LoginViewModel extends ViewModel {
  LoginUiState _uiState = const LoginIdle();

  LoginUiState get uiState => _uiState;

  void _set(LoginUiState state) {
    _uiState = state;
    notify();
  }

  Future<void> login(String email, String password) async {
    _set(const LoginLoading());

    final String? uid;
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      uid = credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      _set(LoginError(e.message ?? Strings.loginFailed));
      return;
    }
    if (uid == null) {
      _set(const LoginError(Strings.couldNotGetUid));
      return;
    }

    try {
      final body = await PetNestApi.instance.login(uid);
      final data = body.data;
      if (body.type != null && data != null) {
        UserSession.id = data.id;
        UserSession.firstName = data.firstName;
        UserSession.lastName = data.lastName;
        UserSession.type = body.type;
      }
      if (body.type == 'arts') {
        UserSession.vetId = body.vetId;
      }
      _set(switch (body.type) {
        'klant' => CustomerLoggedIn(
          customerId: body.customerId ?? 0,
          firstName: body.firstName ?? '',
          lastName: body.lastName ?? '',
        ),
        'arts' => VetLoggedIn(body.vetId ?? 0),
        _ => LoginError(body.error ?? Strings.unknownError),
      });
    } catch (e) {
      _set(LoginError(Strings.networkError(e)));
    }
  }
}
