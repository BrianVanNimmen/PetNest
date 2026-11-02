import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../model/simple_item.dart';
import '../../../data/models/pet.dart';
import '../../../strings.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dimens.dart';
import '../../components/form_card.dart';
import '../../components/form_fields.dart';
import '../../components/images.dart';
import '../../components/petnest_app_bar.dart';

typedef PetFormSave = Future<bool> Function({
  required String name,
  required String species,
  required String birthDate,
  required SimpleItem? vet,
  required PickedUpload? photo,
});

/// The new / edit pet form. Pops with `true` after a successful save.
class PetForm extends StatefulWidget {
  const PetForm({
    super.key,
    required this.title,
    required this.vets,
    required this.onSave,
    this.initial,
    this.requireVet = false,
  });

  final String title;
  final List<SimpleItem> vets;
  final PetFormSave onSave;
  final Pet? initial;
  final bool requireVet;

  @override
  State<PetForm> createState() => _PetFormState();
}

class _PetFormState extends State<PetForm> {
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late final _species = TextEditingController(
    text: widget.initial?.species ?? '',
  );
  late String _birthDate = widget.initial?.birthDate ?? '';
  SimpleItem? _selectedVet;
  bool _vetTouched = false;
  PickedUpload? _photo;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _species.dispose();
    super.dispose();
  }

  /// The pet's current vet, until the user picks another one. The vet list
  /// can arrive after the form opens.
  SimpleItem? get _vet {
    if (_vetTouched) return _selectedVet;
    final vetId = widget.initial?.vetId;
    return widget.vets.where((v) => v.id == vetId).firstOrNull;
  }

  Future<void> _pickPhoto() async {
    final file = await FilePicker.pickFile(type: FileType.image);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _photo = PickedUpload(name: file.name, bytes: bytes));
  }

  Future<void> _save() async {
    if (widget.requireVet && _vet == null) {
      setState(() => _error = Strings.fillInAllFields);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final ok = await widget.onSave(
      name: _name.text.trim(),
      species: _species.text.trim(),
      birthDate: _birthDate,
      vet: _vet,
      photo: _photo,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _saving = false;
        _error = Strings.saveFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodyMedium;

    return Scaffold(
      appBar: PetNestAppBar(
        title: widget.title,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(contentHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _PhotoPicker(
                photo: _photo?.bytes,
                fallbackUrl: widget.initial?.photoUrl,
                onPick: _pickPhoto,
              ),
            ),
            const SizedBox(height: spacerL),
            LabeledTextField(
              label: Strings.name,
              controller: _name,
              hint: Strings.petNameHint,
              labelStyle: labelStyle,
            ),
            const SizedBox(height: spacerL),
            LabeledTextField(
              label: Strings.speciesBreed,
              controller: _species,
              hint: Strings.petBreedHint,
              labelStyle: labelStyle,
            ),
            const SizedBox(height: spacerL),
            DateField(
              label: Strings.birthDate,
              value: _birthDate,
              labelStyle: labelStyle,
              lastDate: DateTime.now(),
              onDateSelected: (date) => setState(() => _birthDate = date),
            ),
            const SizedBox(height: spacerL),
            SearchSelectField<SimpleItem>(
              label: Strings.vet,
              hint: Strings.selectVet,
              labelStyle: labelStyle,
              options: widget.vets,
              optionLabel: (v) => v.name,
              initialText: _vet?.name ?? '',
              showAllWhenEmpty: true,
              onSelected: (vet) => setState(() {
                _vetTouched = true;
                _selectedVet = vet;
              }),
            ),
            if (_error != null) ...[
              const SizedBox(height: spacerL),
              ErrorText(_error!),
            ],
            const SizedBox(height: spacerL),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox.square(
                      dimension: progressIndicatorSize,
                      child: CircularProgressIndicator(
                        strokeWidth: progressIndicatorStroke,
                      ),
                    )
                  : const Text(Strings.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.photo,
    required this.fallbackUrl,
    required this.onPick,
  });

  final Uint8List? photo;
  final String? fallbackUrl;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (photo != null) {
      content = Image.memory(
        photo!,
        fit: BoxFit.cover,
        width: photoPickerSize,
        height: photoPickerSize,
        semanticLabel: Strings.chosenPhoto,
      );
    } else if (fallbackUrl != null && fallbackUrl!.isNotEmpty) {
      content = PetPhoto(
        url: fallbackUrl,
        size: photoPickerSize,
        radius: 0,
        semanticLabel: Strings.currentPhoto,
      );
    } else {
      content = Center(
        child: Text(
          Strings.addPhoto,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radiusMedium),
      child: Material(
        color: PetNestColors.of(context).surfaceVariant,
        child: InkWell(
          onTap: onPick,
          child: SizedBox.square(dimension: photoPickerSize, child: content),
        ),
      ),
    );
  }
}
