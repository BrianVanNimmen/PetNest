import 'package:material_ui/material_ui.dart';

import '../../../network/account.dart';
import '../../../strings.dart';
import '../../../theme/dimens.dart';
import '../../../util/text.dart';
import '../../components/buttons.dart';
import '../../components/form_card.dart';
import '../../components/form_fields.dart';
import '../../viewmodels/shared/register_customer_view_model.dart';
import '../../viewmodels/shared/ui_state.dart';
import 'municipality_field.dart';

class RegisterCustomerScreen extends StatefulWidget {
  const RegisterCustomerScreen({
    super.key,
    required this.onBack,
    required this.onRegistrationSuccess,
  });

  final VoidCallback onBack;
  final VoidCallback onRegistrationSuccess;

  @override
  State<RegisterCustomerScreen> createState() => _RegisterCustomerScreenState();
}

class _RegisterCustomerScreenState extends State<RegisterCustomerScreen> {
  final _viewModel = RegisterCustomerViewModel();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _repeatPassword = TextEditingController();
  String _birthDate = '';
  Municipality? _selectedMunicipality;
  String? _validationError;

  @override
  void dispose() {
    _viewModel.dispose();
    for (final c in [
      _firstName,
      _lastName,
      _email,
      _password,
      _repeatPassword,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validate() {
    if (_firstName.text.trim().isEmpty ||
        _lastName.text.trim().isEmpty ||
        _email.text.trim().isEmpty) {
      return Strings.fillInAllFields;
    }
    if (!isValidEmail(_email.text)) return Strings.enterValidEmail;
    if (_birthDate.isEmpty || _selectedMunicipality == null) {
      return Strings.fillInAllFields;
    }
    if (_password.text.length < 6) return Strings.passwordTooShort;
    if (_password.text != _repeatPassword.text) {
      return Strings.passwordsDoNotMatch;
    }
    return null;
  }

  Future<void> _register() async {
    setState(() => _validationError = _validate());
    if (_validationError != null) return;

    await _viewModel.register(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      email: _email.text,
      password: _password.text,
      birthDate: _birthDate,
      municipalityId: _selectedMunicipality!.id,
    );
    if (mounted && _viewModel.uiState is UiSuccess) {
      widget.onRegistrationSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: screenHorizontalPadding,
          ),
          child: Column(
            children: [
              const SizedBox(height: spacerTop),
              Text(
                Strings.customerRegistration,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: spacerL),
              ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  final uiState = _viewModel.uiState;
                  return FormCard(
                    children: [
                      LabeledTextField(
                        label: Strings.firstName,
                        controller: _firstName,
                        hint: Strings.firstNameHint,
                      ),
                      const SizedBox(height: spacerFormField),
                      LabeledTextField(
                        label: Strings.lastName,
                        controller: _lastName,
                        hint: Strings.lastNameHint,
                      ),
                      const SizedBox(height: spacerFormField),
                      LabeledTextField(
                        label: Strings.email,
                        controller: _email,
                        hint: Strings.emailHint,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: spacerFormField),
                      DateField(
                        label: Strings.birthDate,
                        value: _birthDate,
                        lastDate: DateTime.now(),
                        onDateSelected: (date) =>
                            setState(() => _birthDate = date),
                      ),
                      const SizedBox(height: spacerFormField),
                      MunicipalityField(
                        municipalities: _viewModel.municipalities,
                        selected: _selectedMunicipality,
                        onChanged: (m) =>
                            setState(() => _selectedMunicipality = m),
                      ),
                      const SizedBox(height: spacerFormField),
                      LabeledTextField(
                        label: Strings.password,
                        controller: _password,
                        hint: Strings.passwordHint,
                        obscureText: true,
                      ),
                      const SizedBox(height: spacerFormField),
                      LabeledTextField(
                        label: Strings.repeatPassword,
                        controller: _repeatPassword,
                        hint: Strings.passwordHint,
                        obscureText: true,
                      ),
                      const SizedBox(height: spacerL),
                      if (_validationError != null) ...[
                        ErrorText(_validationError!),
                        const SizedBox(height: spacerXS),
                      ],
                      if (uiState is UiError) ...[
                        ErrorText(uiState.message),
                        const SizedBox(height: spacerXS),
                      ],
                      const SizedBox(height: spacerM),
                      PrimaryButton(
                        text: Strings.registerUppercase,
                        loading: uiState is UiLoading,
                        onPressed: _register,
                      ),
                      const SizedBox(height: spacerXS),
                      Center(
                        child: TextButton(
                          onPressed: widget.onBack,
                          child: Text(
                            Strings.backUppercase,
                            style: theme.textTheme.labelMedium!.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: spacerXXXL),
            ],
          ),
        ),
      ),
    );
  }
}
