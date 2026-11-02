import 'package:material_ui/material_ui.dart';

import '../../theme/dimens.dart';

/// The rounded, lightly elevated card that holds the login/register forms.
class FormCard extends StatelessWidget {
  const FormCard({
    super.key,
    required this.children,
    this.padding = cardPadding,
  });

  final List<Widget> children;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: cardElevationDefault,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

/// Error text in the error color.
class ErrorText extends StatelessWidget {
  const ErrorText(this.message, {super.key, this.style});

  final String message;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      message,
      style: (style ?? theme.textTheme.labelMedium)!.copyWith(
        color: theme.colorScheme.error,
      ),
    );
  }
}
