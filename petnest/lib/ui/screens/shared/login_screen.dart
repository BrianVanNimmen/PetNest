import 'package:material_ui/material_ui.dart';

import '../../../strings.dart';
import '../../../theme/dimens.dart';
import '../../components/buttons.dart';
import '../../components/form_card.dart';
import '../../components/form_fields.dart';
import '../../components/images.dart';
import '../../viewmodels/shared/login_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onCreateAccount,
    required this.onCustomerLogin,
    required this.onVetLogin,
    required this.onAccessibility,
  });

  final VoidCallback onCreateAccount;
  final VoidCallback onCustomerLogin;
  final ValueChanged<int> onVetLogin;
  final VoidCallback onAccessibility;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _viewModel = LoginViewModel();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _viewModel.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    await _viewModel.login(_email.text, _password.text);
    if (!mounted) return;
    switch (_viewModel.uiState) {
      case CustomerLoggedIn():
        widget.onCustomerLogin();
      case VetLoggedIn(:final vetId):
        widget.onVetLogin(vetId);
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: screenHorizontalPadding,
              ),
              child: Column(
                children: [
                  const SizedBox(height: spacerTopLarge),
                  const AppLogo(),
                  const SizedBox(height: spacerXXXL),
                  Text(Strings.login, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: spacerS),
                  Text(
                    Strings.areYouVetOrOwner,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: spacerXXXL),
                  ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, _) {
                      final uiState = _viewModel.uiState;
                      return FormCard(
                        children: [
                          LabeledTextField(
                            label: Strings.email,
                            controller: _email,
                            hint: Strings.loginEmailHint,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: spacerL),
                          LabeledTextField(
                            label: Strings.password,
                            controller: _password,
                            hint: Strings.enterYourPassword,
                            obscureText: true,
                          ),
                          if (uiState is LoginError) ...[
                            const SizedBox(height: spacerM),
                            ErrorText(uiState.message),
                          ],
                          const SizedBox(height: spacerXXL),
                          PrimaryButton(
                            text: Strings.login,
                            loading: uiState is LoginLoading,
                            onPressed: _login,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  Strings.noAccountYet,
                                  style: theme.textTheme.labelMedium,
                                ),
                              ),
                              TextButton(
                                onPressed: widget.onCreateAccount,
                                child: Text(
                                  Strings.createAccount,
                                  style: theme.textTheme.labelMedium!.copyWith(
                                    color: scheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: spacerXXXL),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: IconButton(
                onPressed: widget.onAccessibility,
                icon: Icon(Icons.settings, color: scheme.primary),
                tooltip: Strings.accessibility,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
