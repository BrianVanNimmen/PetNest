import 'package:material_ui/material_ui.dart';

import '../../../network/patient.dart';
import '../../../strings.dart';
import '../../../theme/dimens.dart';
import '../../components/bottom_bars.dart';
import '../../components/buttons.dart';
import '../../components/images.dart';
import '../../components/petnest_app_bar.dart';

class VetPatientDetailsScreen extends StatelessWidget {
  const VetPatientDetailsScreen({
    super.key,
    required this.patient,
    required this.onClose,
    required this.onTabSelected,
    required this.onMedicalRecord,
  });

  final Patient patient;
  final VoidCallback onClose;
  final ValueChanged<VetTab> onTabSelected;
  final ValueChanged<Patient> onMedicalRecord;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onTopBar = theme.appBarTheme.foregroundColor;
    final birthDate = patient.birthDate;

    return Scaffold(
      appBar: PetNestAppBar(
        title: Strings.patientDetails,
        titleStyle: theme.textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.w600,
          color: onTopBar,
        ),
        actions: [
          TextButton(
            onPressed: onClose,
            child: Text(
              Strings.closeUppercase,
              style: theme.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: onTopBar,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: VetBottomBar(
        selectedTab: VetTab.myPatients,
        onTabSelected: onTabSelected,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: contentHorizontalPaddingLarge,
          vertical: spacerXXL,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: PetPhoto(
                url: patient.photoUrl,
                size: detailPhotoSize,
                radius: radiusExtraLarge,
                fallbackAsset: logoAsset,
                semanticLabel: Strings.photoOfPatient(patient.name),
              ),
            ),
            const SizedBox(height: spacerXXXL),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radiusLarge),
                side: BorderSide(color: scheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(cardPaddingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: theme.textTheme.titleLarge!.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: spacerM),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: Strings.speciesBreedLabel,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: patient.species),
                        ],
                      ),
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    if (birthDate != null) ...[
                      const SizedBox(height: spacerXS),
                      Text(
                        Strings.birthDateLabel(birthDate),
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: spacerXXXL),
            PrimaryButton(
              text: Strings.medicalRecordUppercase,
              onPressed: () => onMedicalRecord(patient),
            ),
          ],
        ),
      ),
    );
  }
}
