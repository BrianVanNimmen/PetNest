import 'package:material_ui/material_ui.dart';

import '../../theme/dimens.dart';

/// Full-width primary button that shows a spinner while [loading].
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
    this.textStyle,
    this.verticalPadding = buttonVerticalPadding,
    this.spinnerSize = progressIndicatorSize,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final TextStyle? textStyle;
  final double verticalPadding;
  final double spinnerSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(0),
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      child: loading
          ? SizedBox.square(
              dimension: spinnerSize,
              child: CircularProgressIndicator(
                color: scheme.primary,
                strokeWidth: progressIndicatorStroke,
              ),
            )
          : Text(
              text,
              style: textStyle ?? Theme.of(context).textTheme.labelLarge,
            ),
    );
  }
}

/// Small centered pill button used above lists ("New pet", "New appointment").
class PillButton extends StatelessWidget {
  const PillButton({super.key, required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(
        onPressed: onPressed,
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
