import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/models/profiles.dart';
import '../../../data/models/pet.dart';
import '../../../strings.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dimens.dart';
import '../../../util/text.dart';
import '../../components/buttons.dart';
import '../../components/form_card.dart';
import '../../components/form_fields.dart';
import '../../viewmodels/shared/register_vet_view_model.dart';
import '../../viewmodels/shared/ui_state.dart';
import 'municipality_field.dart';

class RegisterVetScreen extends StatefulWidget {
  const RegisterVetScreen({
    super.key,
    required this.onBack,
    required this.onRegistrationSuccess,
    this.useSignedInAccount = false,
  });

  final VoidCallback onBack;
  final VoidCallback onRegistrationSuccess;

  /// Completes the profile of the signed-in Google account: no email or
  /// password fields.
  final bool useSignedInAccount;

  @override
  State<RegisterVetScreen> createState() => _RegisterVetScreenState();
}

class _RegisterVetScreenState extends State<RegisterVetScreen> {
  late final _viewModel = RegisterVetViewModel(
    useSignedInAccount: widget.useSignedInAccount,
  );
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _repeatPassword = TextEditingController();
  final _phone = TextEditingController();
  final _practiceName = TextEditingController();
  Municipality? _selectedMunicipality;
  PickedUpload? _certificate;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    // Prefill from the Google account
    final account = _viewModel.signedInAccount;
    if (account != null) {
      final names = (account.displayName ?? '').trim().split(RegExp(r'\s+'));
      _firstName.text = names.first;
      _lastName.text = names.skip(1).join(' ');
      _email.text = account.email ?? '';
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    for (final c in [
      _firstName,
      _lastName,
      _email,
      _password,
      _repeatPassword,
      _phone,
      _practiceName,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validate() {
    final newAccount = !widget.useSignedInAccount;
    if (_firstName.text.trim().isEmpty ||
        _lastName.text.trim().isEmpty ||
        (newAccount && _email.text.trim().isEmpty)) {
      return Strings.fillInAllFields;
    }
    if (newAccount && !isValidEmail(_email.text)) {
      return Strings.enterValidEmail;
    }
    if (_selectedMunicipality == null ||
        _phone.text.trim().isEmpty ||
        _practiceName.text.trim().isEmpty) {
      return Strings.fillInAllFields;
    }
    if (_certificate == null) return Strings.uploadCertificate;
    if (newAccount && _password.text.length < 6) {
      return Strings.passwordTooShort;
    }
    if (newAccount && _password.text != _repeatPassword.text) {
      return Strings.passwordsDoNotMatch;
    }
    return null;
  }

  Future<void> _pickCertificate() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _certificate = PickedUpload(name: file.name, bytes: bytes));
  }

  Future<void> _register() async {
    setState(() => _validationError = _validate());
    if (_validationError != null) return;

    await _viewModel.register(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      email: _email.text,
      password: _password.text,
      municipalityId: _selectedMunicipality!.id,
      phone: _phone.text.trim(),
      practiceName: _practiceName.text.trim(),
      certificate: _certificate!,
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
                Strings.vetRegistration,
                style: theme.textTheme.headlineSmall!.copyWith(
                  color: PetNestColors.of(context).onBackground,
                ),
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
                      if (!widget.useSignedInAccount) ...[
                        LabeledTextField(
                          label: Strings.email,
                          controller: _email,
                          hint: Strings.emailHint,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: spacerFormField),
                      ],
                      MunicipalityField(
                        municipalities: _viewModel.municipalities,
                        selected: _selectedMunicipality,
                        loadError: _viewModel.municipalitiesLoadError,
                        onChanged: (m) =>
                            setState(() => _selectedMunicipality = m),
                      ),
                      const SizedBox(height: spacerFormField),
                      LabeledTextField(
                        label: Strings.phone,
                        controller: _phone,
                        hint: Strings.phoneHint,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: spacerFormField),
                      LabeledTextField(
                        label: Strings.practiceName,
                        controller: _practiceName,
                        hint: Strings.practiceNameHint,
                      ),
                      const SizedBox(height: spacerFormField),
                      if (!widget.useSignedInAccount) ...[
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
                      ],
                      const SizedBox(height: spacerFormField),
                      if (_validationError != null) ...[
                        ErrorText(_validationError!),
                        const SizedBox(height: spacerXS),
                      ],
                      const SizedBox(height: spacerFormField),
                      _CertificatePicker(
                        fileName: _certificate?.name ?? Strings.noFileChosen,
                        onPick: _pickCertificate,
                      ),
                      const SizedBox(height: spacerXXL),
                      if (uiState is UiError)
                        Padding(
                          padding: const EdgeInsets.only(bottom: spacerM),
                          child: ErrorText(
                            uiState.message,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
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
              const SizedBox(height: spacerXXXL + spacerM),
            ],
          ),
        ),
      ),
    );
  }
}

class _CertificatePicker extends StatelessWidget {
  const _CertificatePicker({required this.fileName, required this.onPick});

  final String fileName;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Strings.certificateLabel, style: theme.textTheme.bodyLarge),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: buttonHorizontalPadding,
                  vertical: spacerL,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.outline, width: borderWidth),
                  borderRadius: BorderRadius.circular(radiusSmall),
                ),
                child: Text(
                  fileName,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
            const SizedBox(width: spacerFormField),
            FilledButton(
              onPressed: onPick,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: buttonHorizontalPadding,
                  vertical: buttonVerticalPadding,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radiusSmall),
                ),
              ),
              child: Text(
                Strings.choose,
                style: theme.textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
