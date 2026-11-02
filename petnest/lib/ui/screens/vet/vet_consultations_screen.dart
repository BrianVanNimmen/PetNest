import 'package:material_ui/material_ui.dart';

import '../../../strings.dart';
import '../../../theme/dimens.dart';
import '../../../util/text.dart';
import '../../components/appointment_widgets.dart';
import '../../components/bottom_bars.dart';
import '../../components/form_card.dart';
import '../../components/form_fields.dart';
import '../../components/petnest_app_bar.dart';
import '../../viewmodels/vet/vet_consultations_view_model.dart';

class VetConsultationsScreen extends StatefulWidget {
  const VetConsultationsScreen({
    super.key,
    required this.onLogout,
    required this.onTabSelected,
  });

  final VoidCallback onLogout;
  final ValueChanged<VetTab> onTabSelected;

  @override
  State<VetConsultationsScreen> createState() => _VetConsultationsScreenState();
}

class _VetConsultationsScreenState extends State<VetConsultationsScreen> {
  final _viewModel = VetConsultationsViewModel();
  final _dateController = TextEditingController(text: todayIso());

  @override
  void initState() {
    super.initState();
    _viewModel.loadAppointments(_dateController.text);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showPetNestDatePicker(
      context,
      initial: DateTime.tryParse(_dateController.text),
    );
    if (picked == null) return;
    _dateController.text = isoDate(picked);
    _viewModel.loadAppointments(_dateController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: BorderSide(color: scheme.outline),
    );

    return Scaffold(
      appBar: PetNestAppBar(
        title: Strings.consultations,
        onLogout: widget.onLogout,
      ),
      bottomNavigationBar: VetBottomBar(
        selectedTab: VetTab.consultations,
        onTabSelected: widget.onTabSelected,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: contentHorizontalPadding,
          vertical: contentVerticalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: _pickDate,
              decoration: InputDecoration(
                hintText: Strings.dateHint,
                filled: true,
                fillColor: scheme.surface,
                border: border,
                enabledBorder: border,
                focusedBorder: border,
                suffixIcon: IconButton(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_month),
                  tooltip: Strings.pickDate,
                ),
              ),
            ),
            const SizedBox(height: spacerM + spacerXS),
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                if (_viewModel.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: spacerXXXL),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final error = _viewModel.error;
                if (error != null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: spacerXL),
                    child: ErrorText(error, style: theme.textTheme.bodyMedium),
                  );
                }
                if (_viewModel.appointments.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: spacerXXXL),
                    child: Center(
                      child: Text(
                        Strings.noAppointmentsForDay,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          fontStyle: FontStyle.italic,
                          color: scheme.onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  );
                }
                return Column(
                  spacing: spacerM,
                  children: [
                    for (final a in _viewModel.appointments)
                      AppointmentRow(
                        title: a.pet,
                        subtitle: a.time.split(' ').last,
                        type: a.type,
                        badgeStyle: TypeBadgeStyle.pill,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
