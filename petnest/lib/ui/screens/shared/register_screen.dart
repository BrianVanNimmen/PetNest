import 'package:material_ui/material_ui.dart';

import '../../../strings.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dimens.dart';
import '../../components/form_card.dart';
import '../../components/images.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({
    super.key,
    required this.onRegisterVet,
    required this.onRegisterCustomer,
    required this.onBack,
  });

  final VoidCallback onRegisterVet;
  final VoidCallback onRegisterCustomer;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: screenHorizontalPadding,
          ),
          child: Column(
            children: [
              const SizedBox(height: spacerTopLarge),
              const AppLogo(),
              const SizedBox(height: spacerXXXL),
              Text(
                Strings.register,
                style: theme.textTheme.headlineMedium!.copyWith(
                  color: PetNestColors.of(context).onBackground,
                ),
              ),
              const SizedBox(height: spacerS),
              Text(
                Strings.chooseAccountType,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: spacerXXXL),
              FormCard(
                children: [
                  _ChoiceButton(
                    text: Strings.registerAsVet,
                    onPressed: onRegisterVet,
                  ),
                  const SizedBox(height: spacerL),
                  _ChoiceButton(
                    text: Strings.registerAsCustomer,
                    onPressed: onRegisterCustomer,
                  ),
                  const SizedBox(height: spacerXS),
                  Center(
                    child: TextButton(
                      onPressed: onBack,
                      child: Text(
                        Strings.backToLogin,
                        style: theme.textTheme.labelMedium!.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.primary, width: borderWidth),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
