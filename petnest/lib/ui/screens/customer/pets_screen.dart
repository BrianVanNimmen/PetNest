import 'package:material_ui/material_ui.dart';

import '../../../network/pet.dart';
import '../../../strings.dart';
import '../../../theme/dimens.dart';
import '../../components/bottom_bars.dart';
import '../../components/buttons.dart';
import '../../components/images.dart';
import '../../components/petnest_app_bar.dart';
import '../../viewmodels/customer/pets_view_model.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({
    super.key,
    required this.onAdd,
    required this.onEdit,
    required this.onMedicalRecord,
    required this.onLogout,
    required this.onTabSelected,
  });

  /// Resolve to true when a pet was saved, so the list reloads.
  final Future<bool?> Function() onAdd;
  final Future<bool?> Function(int petId) onEdit;
  final ValueChanged<int> onMedicalRecord;
  final VoidCallback onLogout;
  final ValueChanged<CustomerTab> onTabSelected;

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  final _viewModel = PetsViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.refresh();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _refreshAfter(Future<bool?> navigation) async {
    if (await navigation == true && mounted) _viewModel.refresh();
  }

  void _showPetDialog(Pet pet) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          title: Text(pet.name, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PetPhoto(url: pet.photoUrl, size: petCardPhotoSize),
              const SizedBox(height: spacerL),
              Text(
                Strings.speciesLabel(pet.species ?? Strings.unknown),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _refreshAfter(widget.onEdit(pet.id));
                  },
                  child: const Text(Strings.edit),
                ),
                const SizedBox(height: spacerM),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    widget.onMedicalRecord(pet.id);
                  },
                  child: const Text(Strings.medicalRecord),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(Strings.close),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: PetNestAppBar(title: Strings.pets, onLogout: widget.onLogout),
      bottomNavigationBar: CustomerBottomBar(
        selectedTab: CustomerTab.pets,
        onTabSelected: widget.onTabSelected,
      ),
      body: Padding(
        padding: const EdgeInsets.all(contentHorizontalPadding),
        child: Column(
          children: [
            PillButton(
              text: Strings.newPet,
              onPressed: () => _refreshAfter(widget.onAdd()),
            ),
            const SizedBox(height: spacerXL),
            Expanded(
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  final state = _viewModel.uiState;
                  if (state.isLoading) {
                    return ListView.separated(
                      itemCount: 3,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: spacerL),
                      itemBuilder: (_, _) => const _PetSkeletonCard(),
                    );
                  }
                  if (state.pets.isEmpty) {
                    return Text(
                      state.error ?? Strings.noPetsYet,
                      style: TextStyle(
                        color: state.error != null
                            ? scheme.error
                            : scheme.onSurfaceVariant,
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: _viewModel.refresh,
                    child: ListView.separated(
                      itemCount: state.pets.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: spacerL),
                      itemBuilder: (context, i) => _PetCard(
                        pet: state.pets[i],
                        onTap: () => _showPetDialog(state.pets[i]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({required this.pet, required this.onTap});

  final Pet pet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(spacerL),
          child: Row(
            children: [
              PetPhoto(url: pet.photoUrl, size: petCardPhotoSize),
              const SizedBox(width: spacerXL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: theme.textTheme.bodyLarge!.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    Text(
                      pet.species ?? Strings.unknown,
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PetSkeletonCard extends StatelessWidget {
  const _PetSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(spacerL),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: petCardPhotoSize,
              height: petCardPhotoSize,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(radiusMedium),
              ),
            ),
            const SizedBox(width: spacerXL),
            Expanded(
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.5,
                child: Container(
                  height: spacerXL,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(radiusExtraSmall),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
