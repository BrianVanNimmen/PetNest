import 'package:material_ui/material_ui.dart';

import '../../../data/models/pet.dart';
import '../../../strings.dart';
import '../../../theme/dimens.dart';
import '../../components/bottom_bars.dart';
import '../../components/buttons.dart';
import '../../components/images.dart';
import '../../components/petnest_app_bar.dart';
import '../../viewmodels/vet/vet_medical_record_view_model.dart';

/// Editable medical record for the vet.
class VetMedicalRecordScreen extends StatefulWidget {
  const VetMedicalRecordScreen({
    super.key,
    required this.patient,
    required this.onBack,
    required this.onTabSelected,
  });

  final Pet patient;
  final VoidCallback onBack;
  final ValueChanged<VetTab> onTabSelected;

  @override
  State<VetMedicalRecordScreen> createState() => _VetMedicalRecordScreenState();
}

class _VetMedicalRecordScreenState extends State<VetMedicalRecordScreen> {
  final _viewModel = VetMedicalRecordViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.load(widget.patient.id);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await _viewModel.save();
    if (!mounted) return;
    final message = _viewModel.saveSucceeded
        ? Strings.recordSaved
        : _viewModel.error;
    if (message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
    _viewModel
      ..resetSaveSucceeded()
      ..clearError();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final patient = widget.patient;
    final birthDate = patient.birthDate;
    final secondary = theme.textTheme.bodyMedium!.copyWith(
      color: scheme.onSurface.withValues(alpha: 0.7),
    );

    return Scaffold(
      appBar: PetNestAppBar(
        title: Strings.medicalRecord,
        onBack: widget.onBack,
      ),
      bottomNavigationBar: VetBottomBar(
        selectedTab: VetTab.myPatients,
        onTabSelected: widget.onTabSelected,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: contentHorizontalPadding,
              vertical: contentVerticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_viewModel.error case final error?)
                  Padding(
                    padding: const EdgeInsets.only(bottom: spacerL),
                    child: Text(error, style: TextStyle(color: scheme.error)),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: spacerXXL),
                  child: Row(
                    children: [
                      PetPhoto(
                        url: patient.photoUrl,
                        size: patientPhotoSizeLarge,
                        fallbackAsset: logoAsset,
                      ),
                      const SizedBox(width: spacerXL),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient.name,
                              style: theme.textTheme.titleMedium!.copyWith(
                                color: scheme.onSurface,
                              ),
                            ),
                            Text(patient.species, style: secondary),
                            if (birthDate != null)
                              Text(
                                Strings.birthDateLabel(birthDate),
                                style: secondary,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _RecordField(
                  label: Strings.weightKg,
                  controller: _viewModel.weight,
                  hint: Strings.weightHint,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                _RecordField(
                  label: Strings.teethStatus,
                  controller: _viewModel.teethStatus,
                  hint: Strings.teethHint,
                ),
                _RecordField(
                  label: Strings.bonesStatus,
                  controller: _viewModel.bonesStatus,
                  hint: Strings.bonesHint,
                ),
                _RecordField(
                  label: Strings.musclesStatus,
                  controller: _viewModel.musclesStatus,
                  hint: Strings.musclesHint,
                ),
                _RecordField(
                  label: Strings.notes,
                  controller: _viewModel.notes,
                  hint: Strings.notesHint,
                  minLines: 3,
                ),
                const SizedBox(height: spacerXXXL),
                PrimaryButton(
                  text: Strings.saveUppercase,
                  loading: _viewModel.isSaving,
                  spinnerSize: progressIndicatorSizeLarge,
                  onPressed: _save,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RecordField extends StatelessWidget {
  const _RecordField({
    required this.label,
    required this.controller,
    required this.hint,
    this.minLines = 1,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final int minLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: spacerS),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: contentHorizontalPadding,
            vertical: spacerFormField,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium!.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              TextField(
                controller: controller,
                minLines: minLines,
                maxLines: minLines == 1 ? 1 : null,
                keyboardType: minLines > 1
                    ? TextInputType.multiline
                    : keyboardType,
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: scheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: theme.textTheme.bodyMedium!.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.4),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: spacerM),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
