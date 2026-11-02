import 'package:material_ui/material_ui.dart';

import '../../strings.dart';
import '../../theme/app_theme.dart';
import '../../theme/dimens.dart';

const logoAsset = 'assets/images/petnest_logo.png';
const defaultPetAsset = 'assets/images/default_pet.png';

/// Round PetNest logo.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.background});

  final Color? background;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: logoSize,
        height: logoSize,
        color: background,
        child: Image.asset(
          logoAsset,
          fit: BoxFit.cover,
          semanticLabel: Strings.petnestLogo,
        ),
      ),
    );
  }
}

/// Photo from Cloud Storage (a download URL), with an asset fallback for
/// missing or broken images.
class PetPhoto extends StatelessWidget {
  const PetPhoto({
    super.key,
    required this.url,
    required this.size,
    this.radius = radiusMedium,
    this.fallbackAsset = defaultPetAsset,
    this.semanticLabel,
  });

  final String? url;
  final double size;
  final double radius;

  /// Shown when [url] is missing or fails to load; null shows an empty box.
  final String? fallbackAsset;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final resolved = url == null || url!.isEmpty ? null : url;
    final fallback = fallbackAsset == null
        ? const SizedBox.shrink()
        : Image.asset(fallbackAsset!, fit: BoxFit.cover);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        color: PetNestColors.of(context).surfaceVariant,
        child: resolved == null
            ? fallback
            : Image.network(
                resolved,
                fit: BoxFit.cover,
                semanticLabel: semanticLabel,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : fallback,
                errorBuilder: (context, error, stackTrace) => fallback,
              ),
      ),
    );
  }
}
