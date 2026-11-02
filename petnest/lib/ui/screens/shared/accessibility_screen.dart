import 'package:material_ui/material_ui.dart';

import '../../../strings.dart';
import '../../../theme/app_theme.dart';
import '../../components/petnest_app_bar.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    required this.onBack,
  });

  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PetNestAppBar(title: Strings.accessibility, onBack: onBack),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.darkMode,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: PetNestColors.of(context).onBackground,
                    ),
                  ),
                  Switch(
                    value: isDarkMode,
                    onChanged: (_) => onToggleDarkMode(),
                  ),
                ],
              ),
            ),
            Divider(color: theme.colorScheme.outlineVariant),
          ],
        ),
      ),
    );
  }
}
