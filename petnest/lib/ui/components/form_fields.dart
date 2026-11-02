import 'package:material_ui/material_ui.dart';

import '../../strings.dart';
import '../../theme/dimens.dart';
import '../../util/text.dart';

/// A label above an outlined text field.
class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.labelStyle,
    this.obscureText = false,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextStyle? labelStyle;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle ?? Theme.of(context).textTheme.bodyLarge),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

/// Read-only date field (yyyy-MM-dd) that opens a date picker.
class DateField extends StatefulWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onDateSelected,
    this.labelStyle,
    this.firstDate,
    this.lastDate,
  });

  final String label;
  final String value;
  final ValueChanged<String> onDateSelected;
  final TextStyle? labelStyle;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  late final _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(DateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) _controller.text = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final picked = await showPetNestDatePicker(
      context,
      initial: DateTime.tryParse(widget.value),
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );
    if (picked != null) widget.onDateSelected(isoDate(picked));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: widget.labelStyle ?? Theme.of(context).textTheme.bodyLarge,
        ),
        TextField(
          controller: _controller,
          readOnly: true,
          onTap: _pick,
          decoration: InputDecoration(
            hintText: Strings.dateHint,
            suffixIcon: IconButton(
              onPressed: _pick,
              icon: const Icon(Icons.calendar_month),
              tooltip: Strings.pickDate,
            ),
          ),
        ),
      ],
    );
  }
}

Future<DateTime?> showPetNestDatePicker(
  BuildContext context, {
  DateTime? initial,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final first = firstDate ?? DateTime(1900);
  final last = lastDate ?? DateTime(2100);
  var initialDate = initial ?? DateTime.now();
  if (initialDate.isBefore(first)) initialDate = first;
  if (initialDate.isAfter(last)) initialDate = last;
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: first,
    lastDate: last,
    confirmText: Strings.ok,
    cancelText: Strings.cancel,
  );
}

/// Label + box that opens a menu of [items] (the Compose DropdownField).
class DropdownField<T> extends StatelessWidget {
  const DropdownField({
    super.key,
    required this.label,
    required this.selected,
    required this.items,
    required this.itemLabel,
    required this.onItemSelected,
    this.enabled = true,
  });

  final String label;
  final T? selected;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T> onItemSelected;
  final bool enabled;

  static const _disabledAlpha = 0.38;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final disabledColor = scheme.onSurface.withValues(alpha: _disabledAlpha);
    final selectedItem = selected;

    return Padding(
      padding: const EdgeInsets.only(bottom: spacerFormField),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium!.copyWith(
              color: enabled ? scheme.primary : disabledColor,
            ),
          ),
          const SizedBox(height: spacerXS),
          MenuAnchor(
            style: const MenuStyle(
              maximumSize: WidgetStatePropertyAll(Size.fromHeight(320)),
            ),
            menuChildren: [
              for (final item in items)
                MenuItemButton(
                  onPressed: () => onItemSelected(item),
                  child: Text(itemLabel(item)),
                ),
            ],
            builder: (context, controller, _) => Material(
              color: scheme.surfaceContainerHighest.withValues(
                alpha: enabled ? 1 : 0.5,
              ),
              borderRadius: BorderRadius.circular(radiusSmall),
              child: InkWell(
                borderRadius: BorderRadius.circular(radiusSmall),
                onTap: enabled && items.isNotEmpty
                    ? () => controller.isOpen
                          ? controller.close()
                          : controller.open()
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    selectedItem == null
                        ? Strings.select
                        : itemLabel(selectedItem),
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: enabled ? scheme.onSurface : disabledColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Text field with a filtered suggestion list (the Compose
/// ExposedDropdownMenuBox with an editable anchor).
class SearchSelectField<T extends Object> extends StatelessWidget {
  const SearchSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.optionLabel,
    required this.onSelected,
    this.matches,
    this.onTextChanged,
    this.initialText = '',
    this.hint,
    this.errorText,
    this.maxOptions,
    this.showAllWhenEmpty = false,
    this.labelStyle,
  });

  final String label;
  final List<T> options;
  final String Function(T) optionLabel;
  final ValueChanged<T> onSelected;

  /// Filter for a search term; defaults to a case-insensitive "contains".
  final bool Function(T option, String query)? matches;
  final ValueChanged<String>? onTextChanged;
  final String initialText;
  final String? hint;
  final String? errorText;
  final int? maxOptions;
  final bool showAllWhenEmpty;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle ?? Theme.of(context).textTheme.bodyLarge),
        Autocomplete<T>(
          // Re-create when the preselected text arrives asynchronously
          key: ValueKey(initialText),
          initialValue: TextEditingValue(text: initialText),
          displayStringForOption: optionLabel,
          optionsBuilder: (value) {
            final query = value.text;
            if (query.isEmpty && !showAllWhenEmpty) return const [];
            final filter =
                matches ??
                (T option, String q) =>
                    optionLabel(option).toLowerCase().contains(q.toLowerCase());
            final filtered = options.where((o) => filter(o, query));
            return maxOptions == null ? filtered : filtered.take(maxOptions!);
          },
          onSelected: onSelected,
          fieldViewBuilder: (context, controller, focusNode, onSubmitted) =>
              TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onTextChanged,
                onSubmitted: (_) => onSubmitted(),
                decoration: InputDecoration(
                  hintText: hint,
                  errorText: errorText,
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
              ),
        ),
      ],
    );
  }
}
