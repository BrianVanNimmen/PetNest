import 'package:material_ui/material_ui.dart';

import '../../strings.dart';
import '../../theme/app_theme.dart';

/// Center-aligned top bar in the PetNest top bar colors, with optional
/// back / accessibility (left) and logout (right) actions.
class PetNestAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PetNestAppBar({
    super.key,
    this.title = '',
    this.titleStyle,
    this.onBack,
    this.onAccessibility,
    this.onLogout,
    this.actions,
  });

  final String title;
  final TextStyle? titleStyle;
  final VoidCallback? onBack;
  final VoidCallback? onAccessibility;
  final VoidCallback? onLogout;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = PetNestColors.of(context);

    Widget? leading;
    if (onBack != null) {
      leading = IconButton(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back),
        tooltip: Strings.back,
      );
    } else if (onAccessibility != null) {
      leading = IconButton(
        onPressed: onAccessibility,
        icon: const Icon(Icons.settings),
        tooltip: Strings.accessibility,
      );
    }

    return AppBar(
      automaticallyImplyLeading: false,
      leading: leading,
      title: Text(title, style: titleStyle),
      actions: [
        ...?actions,
        if (onLogout != null)
          TextButton(
            onPressed: onLogout,
            child: Text(
              Strings.logout,
              style: TextStyle(color: colors.onTopBar),
            ),
          ),
      ],
    );
  }
}
