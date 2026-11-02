import 'package:material_ui/material_ui.dart';

import '../../../model/appointment_type.dart';
import '../../../model/simple_item.dart';
import '../../../model/time_slots.dart';
import '../../../strings.dart';
import '../../../theme/dimens.dart';
import '../../components/buttons.dart';
import '../../components/form_card.dart';
import '../../components/form_fields.dart';
import '../../components/petnest_app_bar.dart';
import '../../viewmodels/customer/appointments_view_model.dart';
import '../../viewmodels/customer/pets_view_model.dart';
import '../../viewmodels/customer/vets_view_model.dart';

/// Pops with `true` after the appointment was created.
class NewAppointmentScreen extends StatefulWidget {
  const NewAppointmentScreen({super.key});

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  final _petsViewModel = PetsViewModel();
  final _vetsViewModel = VetsViewModel();
  final _appointmentViewModel = AppointmentsViewModel();

  SimpleItem? _selectedPet;
  SimpleItem? _selectedVet;
  AppointmentType? _type;
  String _date = '';
  String _time = '';
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _petsViewModel.refresh();
  }

  @override
  void dispose() {
    _petsViewModel.dispose();
    _vetsViewModel.dispose();
    _appointmentViewModel.dispose();
    super.dispose();
  }

  void _loadOccupiedSlots() {
    final vet = _selectedVet;
    if (_date.isNotEmpty && vet != null) {
      _appointmentViewModel.loadOccupiedSlots(_date, vet.id);
    }
  }

  Future<void> _save() async {
    final pet = _selectedPet;
    final vet = _selectedVet;
    final type = _type;
    if (pet == null ||
        vet == null ||
        type == null ||
        _date.isEmpty ||
        _time.isEmpty) {
      setState(() => _error = Strings.fillInAllFields);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await _appointmentViewModel.createAppointment(
      pet: pet,
      vet: vet,
      date: _date,
      time: _time,
      type: type.value,
    );
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _saving = false;
        _error = error;
        // The slot may just have been taken
        if (_appointmentViewModel.occupiedSlots.contains(_time)) _time = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PetNestAppBar(
        title: Strings.newAppointment,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(contentHorizontalPadding),
        child: ListenableBuilder(
          listenable: Listenable.merge([
            _petsViewModel,
            _vetsViewModel,
            _appointmentViewModel,
          ]),
          builder: (context, _) {
            final pets = [
              for (final p in _petsViewModel.uiState.pets)
                SimpleItem(
                  id: p.id,
                  name: p.name.isEmpty ? Strings.unknown : p.name,
                ),
            ];
            final occupied = _appointmentViewModel.occupiedSlots;
            final availableSlots = [
              for (final slot in timeSlots)
                if (!occupied.contains(slot.start)) slot.start,
            ];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormCard(
                  padding: cardPaddingSmall,
                  children: [
                    DropdownField<SimpleItem>(
                      label: Strings.petLabel,
                      selected: _selectedPet,
                      items: pets,
                      itemLabel: (p) => p.name,
                      onItemSelected: (p) => setState(() => _selectedPet = p),
                    ),
                    const SizedBox(height: spacerL),
                    DropdownField<SimpleItem>(
                      label: Strings.vet,
                      selected: _selectedVet,
                      items: _vetsViewModel.vets,
                      itemLabel: (v) => v.name,
                      onItemSelected: (v) {
                        setState(() => _selectedVet = v);
                        _loadOccupiedSlots();
                      },
                    ),
                    const SizedBox(height: spacerL),
                    DropdownField<AppointmentType>(
                      label: Strings.appointmentType,
                      selected: _type,
                      items: AppointmentType.bookable,
                      itemLabel: (t) => t.label,
                      onItemSelected: (t) => setState(() => _type = t),
                    ),
                    const SizedBox(height: spacerL),
                    DateField(
                      label: Strings.dateLabel,
                      value: _date,
                      labelStyle: Theme.of(context).textTheme.labelMedium!
                          .copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      firstDate: DateUtils.dateOnly(DateTime.now()),
                      onDateSelected: (date) {
                        setState(() {
                          _date = date;
                          _time = '';
                        });
                        _loadOccupiedSlots();
                      },
                    ),
                    const SizedBox(height: spacerL),
                    DropdownField<String>(
                      label: Strings.timeSlot,
                      selected: _time.isEmpty ? null : _time,
                      items: availableSlots,
                      itemLabel: (t) => t,
                      enabled: _date.isNotEmpty,
                      onItemSelected: (t) => setState(() => _time = t),
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: spacerL),
                  ErrorText(_error!),
                ],
                const SizedBox(height: spacerXXL),
                PrimaryButton(
                  text: Strings.saveAppointment,
                  loading: _saving,
                  onPressed: _save,
                  textStyle: Theme.of(context).textTheme.bodyMedium,
                  verticalPadding: spacerL,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
