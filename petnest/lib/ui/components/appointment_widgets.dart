import 'package:material_ui/material_ui.dart';

import '../../model/appointment_type.dart';
import '../../theme/app_theme.dart';
import '../../theme/dimens.dart';

enum TypeBadgeStyle {
  /// Small round badge in the home screen rows.
  compact,

  /// Round badge in the vet's consultation rows.
  pill,

  /// A color per type, in the customer's appointment list.
  colored,
}

class TypeBadge extends StatelessWidget {
  const TypeBadge({
    super.key,
    required this.type,
    this.style = TypeBadgeStyle.compact,
  });

  /// Raw API value ("controle", "operatie", ...).
  final String type;
  final TypeBadgeStyle style;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final parsed = AppointmentType.fromValue(type);
    final isSurgery = parsed == AppointmentType.surgery;

    final (Color background, Color foreground) = switch (style) {
      TypeBadgeStyle.colored => switch (parsed) {
        AppointmentType.checkup => (
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
        ),
        AppointmentType.vaccination => (
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
        ),
        AppointmentType.surgery => (scheme.primary, scheme.onPrimary),
        _ => (
          PetNestColors.of(context).surfaceVariant,
          scheme.onSurfaceVariant,
        ),
      },
      _ =>
        isSurgery
            ? (scheme.primary, scheme.onPrimary)
            : (scheme.primaryContainer, scheme.onPrimaryContainer),
    };

    final (
      EdgeInsets padding,
      double radius,
      TextStyle textStyle,
    ) = switch (style) {
      TypeBadgeStyle.compact => (
        const EdgeInsets.symmetric(horizontal: spacerM, vertical: spacerXS),
        999.0,
        textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w600),
      ),
      TypeBadgeStyle.pill => (
        const EdgeInsets.symmetric(
          horizontal: badgeHorizontalPadding,
          vertical: badgeVerticalPadding,
        ),
        999.0,
        textTheme.labelMedium!.copyWith(fontWeight: FontWeight.w500),
      ),
      TypeBadgeStyle.colored => (
        const EdgeInsets.symmetric(
          horizontal: badgeHorizontalPadding,
          vertical: badgeVerticalPadding,
        ),
        radiusMedium,
        textTheme.labelSmall!,
      ),
    };

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        AppointmentType.labelFor(type),
        style: textStyle.copyWith(color: foreground),
      ),
    );
  }
}

/// Card row with a title, subtitle and type badge (home and consultation
/// lists).
class AppointmentRow extends StatelessWidget {
  const AppointmentRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.type,
    this.badgeStyle = TypeBadgeStyle.compact,
  });

  final String title;
  final String subtitle;
  final String type;
  final TypeBadgeStyle badgeStyle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: cardElevationLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: buttonHorizontalPadding,
          vertical: spacerL,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall!.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall!.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            TypeBadge(type: type, style: badgeStyle),
          ],
        ),
      ),
    );
  }
}

/// The "My appointments" / "My consultations today" card on both home
/// screens.
class AppointmentsSummaryCard extends StatelessWidget {
  const AppointmentsSummaryCard({
    super.key,
    required this.title,
    required this.emptyText,
    required this.buttonText,
    required this.isLoading,
    required this.rows,
    required this.onButtonPressed,
    this.error,
  });

  final String title;
  final String emptyText;
  final String buttonText;
  final bool isLoading;
  final String? error;
  final List<Widget> rows;
  final VoidCallback onButtonPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final Widget content;
    if (isLoading) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: spacerXL),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (error != null) {
      content = Text(
        error!,
        style: textTheme.bodySmall!.copyWith(color: scheme.error),
      );
    } else if (rows.isEmpty) {
      content = Padding(
        padding: const EdgeInsets.symmetric(vertical: spacerM),
        child: Text(
          emptyText,
          style: textTheme.bodySmall!.copyWith(
            fontStyle: FontStyle.italic,
            color: scheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
      );
    } else {
      content = Column(
        children: [
          for (final (i, row) in rows.take(3).indexed) ...[
            if (i > 0) const SizedBox(height: spacerM),
            row,
          ],
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: screenHorizontalPadding),
      child: Card(
        elevation: cardElevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(cardPaddingSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: textTheme.titleMedium!.copyWith(color: scheme.onSurface),
              ),
              const SizedBox(height: spacerM),
              content,
              const SizedBox(height: spacerM),
              Center(
                child: SizedBox(
                  width: buttonWidth,
                  child: FilledButton(
                    onPressed: onButtonPressed,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: spacerL),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(radiusMedium),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
