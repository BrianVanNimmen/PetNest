import 'package:material_ui/material_ui.dart';

import '../../../data/models/pet.dart';
import '../../../strings.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dimens.dart';
import '../../components/bottom_bars.dart';
import '../../components/form_card.dart';
import '../../components/images.dart';
import '../../components/petnest_app_bar.dart';
import '../../viewmodels/vet/vet_patients_view_model.dart';

class VetPatientsScreen extends StatefulWidget {
  const VetPatientsScreen({
    super.key,
    required this.viewModel,
    required this.onLogout,
    required this.onTabSelected,
    required this.onPatientTap,
  });

  /// App-scoped, so the detail screens can look patients up.
  final VetPatientsViewModel viewModel;
  final VoidCallback onLogout;
  final ValueChanged<VetTab> onTabSelected;
  final ValueChanged<Pet> onPatientTap;

  @override
  State<VetPatientsScreen> createState() => _VetPatientsScreenState();
}

class _VetPatientsScreenState extends State<VetPatientsScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadPatients();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = widget.viewModel;

    return Scaffold(
      appBar: PetNestAppBar(title: Strings.patients, onLogout: widget.onLogout),
      bottomNavigationBar: VetBottomBar(
        selectedTab: VetTab.myPatients,
        onTabSelected: widget.onTabSelected,
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final error = viewModel.error;
          if (error != null) {
            return Center(
              child: ErrorText(error, style: theme.textTheme.bodyMedium),
            );
          }
          if (viewModel.patients.isEmpty) {
            return Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: spacerTop),
                child: Text(
                  Strings.noActivePatients,
                  style: theme.textTheme.bodyLarge!.copyWith(
                    color: PetNestColors.of(context).onBackground
                        .withValues(alpha: 0.5),
                  ),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: viewModel.loadPatients,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: contentHorizontalPadding,
                vertical: spacerM,
              ),
              itemCount: viewModel.patients.length,
              itemBuilder: (context, i) {
                final patient = viewModel.patients[i];
                return _PatientCard(
                  patient: patient,
                  onTap: () => widget.onPatientTap(patient),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient, required this.onTap});

  final Pet patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: spacerS),
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(spacerL),
            child: Row(
              children: [
                PetPhoto(
                  url: patient.photoUrl,
                  size: patientPhotoSize,
                  radius: radiusExtraSmall,
                  fallbackAsset: logoAsset,
                  semanticLabel: Strings.photoOfPatient(patient.name),
                ),
                const SizedBox(width: spacerXL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: theme.textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      Text(
                        patient.species,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
