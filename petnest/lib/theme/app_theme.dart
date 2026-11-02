import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'dimens.dart';

/// Colors that don't exist in Flutter's [ColorScheme] (the Compose app's
/// ExtendedColorScheme plus the M3 background/surfaceVariant roles).
@immutable
class PetNestColors extends ThemeExtension<PetNestColors> {
  const PetNestColors({
    required this.topBar,
    required this.onTopBar,
    required this.background,
    required this.onBackground,
    required this.surfaceVariant,
  });

  final Color topBar;
  final Color onTopBar;
  final Color background;
  final Color onBackground;
  final Color surfaceVariant;

  static const light = PetNestColors(
    topBar: topBarLight,
    onTopBar: onTopBarLight,
    background: backgroundLight,
    onBackground: onBackgroundLight,
    surfaceVariant: surfaceVariantLight,
  );

  static const dark = PetNestColors(
    topBar: topBarDark,
    onTopBar: onTopBarDark,
    background: backgroundDark,
    onBackground: onBackgroundDark,
    surfaceVariant: surfaceVariantDark,
  );

  static PetNestColors of(BuildContext context) =>
      Theme.of(context).extension<PetNestColors>()!;

  @override
  PetNestColors copyWith({
    Color? topBar,
    Color? onTopBar,
    Color? background,
    Color? onBackground,
    Color? surfaceVariant,
  }) => PetNestColors(
    topBar: topBar ?? this.topBar,
    onTopBar: onTopBar ?? this.onTopBar,
    background: background ?? this.background,
    onBackground: onBackground ?? this.onBackground,
    surfaceVariant: surfaceVariant ?? this.surfaceVariant,
  );

  @override
  PetNestColors lerp(PetNestColors? other, double t) {
    if (other == null) return this;
    return PetNestColors(
      topBar: Color.lerp(topBar, other.topBar, t)!,
      onTopBar: Color.lerp(onTopBar, other.onTopBar, t)!,
      background: Color.lerp(background, other.background, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
    );
  }
}

const _lightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: primaryLight,
  onPrimary: onPrimaryLight,
  primaryContainer: primaryContainerLight,
  onPrimaryContainer: onPrimaryContainerLight,
  secondary: secondaryLight,
  onSecondary: onSecondaryLight,
  secondaryContainer: secondaryContainerLight,
  onSecondaryContainer: onSecondaryContainerLight,
  tertiary: tertiaryLight,
  onTertiary: onTertiaryLight,
  tertiaryContainer: tertiaryContainerLight,
  onTertiaryContainer: onTertiaryContainerLight,
  error: errorLight,
  onError: onErrorLight,
  errorContainer: errorContainerLight,
  onErrorContainer: onErrorContainerLight,
  surface: surfaceLight,
  onSurface: onSurfaceLight,
  onSurfaceVariant: onSurfaceVariantLight,
  outline: outlineLight,
  outlineVariant: outlineVariantLight,
  scrim: scrimLight,
  inverseSurface: inverseSurfaceLight,
  onInverseSurface: inverseOnSurfaceLight,
  inversePrimary: inversePrimaryLight,
  surfaceDim: surfaceDimLight,
  surfaceBright: surfaceBrightLight,
  surfaceContainerLowest: surfaceContainerLowestLight,
  surfaceContainerLow: surfaceContainerLowLight,
  surfaceContainer: surfaceContainerLight,
  surfaceContainerHigh: surfaceContainerHighLight,
  surfaceContainerHighest: surfaceContainerHighestLight,
  surfaceTint: Colors.transparent,
);

const _darkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: primaryDark,
  onPrimary: onPrimaryDark,
  primaryContainer: primaryContainerDark,
  onPrimaryContainer: onPrimaryContainerDark,
  secondary: secondaryDark,
  onSecondary: onSecondaryDark,
  secondaryContainer: secondaryContainerDark,
  onSecondaryContainer: onSecondaryContainerDark,
  tertiary: tertiaryDark,
  onTertiary: onTertiaryDark,
  tertiaryContainer: tertiaryContainerDark,
  onTertiaryContainer: onTertiaryContainerDark,
  error: errorDark,
  onError: onErrorDark,
  errorContainer: errorContainerDark,
  onErrorContainer: onErrorContainerDark,
  surface: surfaceDark,
  onSurface: onSurfaceDark,
  onSurfaceVariant: onSurfaceVariantDark,
  outline: outlineDark,
  outlineVariant: outlineVariantDark,
  scrim: scrimDark,
  inverseSurface: inverseSurfaceDark,
  onInverseSurface: inverseOnSurfaceDark,
  inversePrimary: inversePrimaryDark,
  surfaceDim: surfaceDimDark,
  surfaceBright: surfaceBrightDark,
  surfaceContainerLowest: surfaceContainerLowestDark,
  surfaceContainerLow: surfaceContainerLowDark,
  surfaceContainer: surfaceContainerDark,
  surfaceContainerHigh: surfaceContainerHighDark,
  surfaceContainerHighest: surfaceContainerHighestDark,
  surfaceTint: Colors.transparent,
);

const _textTheme = TextTheme(
  // Screen titles (login/registration)
  headlineMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
  headlineSmall: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
  // Card titles
  titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
  titleMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
  titleSmall: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
  // Body text
  bodyLarge: TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: 0.5,
  ),
  bodyMedium: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
  bodySmall: TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
  // Labels / buttons
  labelLarge: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
    letterSpacing: 1,
  ),
  labelMedium: TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.5,
  ),
  labelSmall: TextStyle(fontWeight: FontWeight.normal, fontSize: 11),
);

ThemeData buildPetNestTheme({required bool darkTheme}) {
  final scheme = darkTheme ? _darkScheme : _lightScheme;
  final extended = darkTheme ? PetNestColors.dark : PetNestColors.light;

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: _textTheme,
    scaffoldBackgroundColor: extended.background,
    extensions: [extended],
    appBarTheme: AppBarTheme(
      backgroundColor: extended.topBar,
      foregroundColor: extended.onTopBar,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: _textTheme.titleLarge!.copyWith(
        color: extended.onTopBar,
        fontWeight: FontWeight.normal,
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
      ),
      hintStyle: _textTheme.bodyMedium!.copyWith(
        color: scheme.onSurface.withValues(alpha: 0.35),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: scheme.primary.withValues(alpha: 0.12),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return _textTheme.labelSmall!.copyWith(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected
              ? scheme.primary
              : scheme.onSurface.withValues(alpha: 0.6),
        );
      }),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
