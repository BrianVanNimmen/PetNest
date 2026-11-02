import 'package:material_ui/material_ui.dart';

import '../../../data/models/profiles.dart';
import '../../../strings.dart';
import '../../components/form_fields.dart';

/// Searchable municipality picker: the first 5 names starting with the
/// typed text.
class MunicipalityField extends StatelessWidget {
  const MunicipalityField({
    super.key,
    required this.municipalities,
    required this.selected,
    required this.onChanged,
    this.loadError,
  });

  final List<Municipality> municipalities;
  final Municipality? selected;

  /// Called with the picked municipality, or null when the text is edited
  /// away from the selection.
  final ValueChanged<Municipality?> onChanged;
  final String? loadError;

  @override
  Widget build(BuildContext context) {
    return SearchSelectField<Municipality>(
      label: Strings.municipality,
      hint: Strings.searchMunicipality,
      errorText: loadError,
      options: municipalities,
      optionLabel: (m) => m.name,
      matches: (m, query) =>
          m.name.toLowerCase().startsWith(query.toLowerCase()),
      maxOptions: 5,
      onSelected: onChanged,
      onTextChanged: (text) {
        if (selected != null && text != selected!.name) onChanged(null);
      },
    );
  }
}
