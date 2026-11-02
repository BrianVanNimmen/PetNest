import 'package:material_ui/material_ui.dart';

import '../../../data/models/pet.dart';
import '../../../strings.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dimens.dart';
import '../../components/images.dart';
import '../../components/petnest_app_bar.dart';
import '../../viewmodels/customer/medical_record_view_model.dart';

/// Read-only medical record for the customer.
class MedicalRecordScreen extends StatefulWidget {
  const MedicalRecordScreen({
    super.key,
    required this.petId,
    required this.onBack,
  });

  final String petId;
  final VoidCallback onBack;

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  final _viewModel = MedicalRecordViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.load(widget.petId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PetNestAppBar(
        title: Strings.medicalRecord,
        onBack: widget.onBack,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final record = _viewModel.record;
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(contentHorizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PetHeader(pet: _viewModel.pet),
                const SizedBox(height: spacerXL),
                if (record == null)
                  const Text(Strings.noRecordFound)
                else
                  _RecordFields(record: record),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PetHeader extends StatelessWidget {
  const _PetHeader({required this.pet});

  final Pet? pet;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final birthDate = pet?.birthDate;
    return Row(
      children: [
        PetPhoto(
          url: pet?.photoUrl,
          size: patientPhotoSizeLarge,
          fallbackAsset: null,
        ),
        const SizedBox(width: spacerL),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pet?.name ?? Strings.unknownPet,
                style: textTheme.titleMedium,
              ),
              Text(
                pet?.species ?? Strings.unknownSpecies,
                style: textTheme.bodyLarge,
              ),
              if (birthDate != null && birthDate.isNotEmpty)
                Text(
                  Strings.birthDateLabel(birthDate),
                  style: textTheme.bodyLarge,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecordFields extends StatelessWidget {
  const _RecordFields({required this.record});

  final MedicalRecord record;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RecordField(label: Strings.weightKg, value: record.weight),
        _RecordField(label: Strings.teethStatus, value: record.teethStatus),
        _RecordField(label: Strings.bonesStatus, value: record.bonesStatus),
        _RecordField(label: Strings.musclesStatus, value: record.musclesStatus),
        _RecordField(label: Strings.notes, value: record.notes),
      ],
    );
  }
}

class _RecordField extends StatelessWidget {
  const _RecordField({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: spacerL),
      padding: const EdgeInsets.all(spacerL),
      decoration: BoxDecoration(
        color: PetNestColors.of(context).surfaceVariant,
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium!.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: spacerXS),
          Text(value ?? '-', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
