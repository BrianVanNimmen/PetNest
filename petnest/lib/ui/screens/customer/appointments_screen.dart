import 'package:material_ui/material_ui.dart';

import '../../../network/appointment.dart';
import '../../../strings.dart';
import '../../../theme/dimens.dart';
import '../../components/appointment_widgets.dart';
import '../../components/bottom_bars.dart';
import '../../components/buttons.dart';
import '../../components/petnest_app_bar.dart';
import '../../viewmodels/customer/appointments_view_model.dart';
import '../../viewmodels/customer/vets_view_model.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({
    super.key,
    required this.onAdd,
    required this.onLogout,
    required this.onTabSelected,
  });

  /// Resolves to true when an appointment was created.
  final Future<bool?> Function() onAdd;
  final VoidCallback onLogout;
  final ValueChanged<CustomerTab> onTabSelected;

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _appointmentsViewModel = AppointmentsViewModel();
  final _vetsViewModel = VetsViewModel();

  @override
  void initState() {
    super.initState();
    // Load right away; reload with vet names once the vets arrive
    _appointmentsViewModel.loadAppointments();
    _vetsViewModel.addListener(_onVetsLoaded);
  }

  void _onVetsLoaded() {
    if (_vetsViewModel.vets.isNotEmpty) {
      _appointmentsViewModel.setVets(_vetsViewModel.vets);
    }
  }

  @override
  void dispose() {
    _vetsViewModel.removeListener(_onVetsLoaded);
    _appointmentsViewModel.dispose();
    _vetsViewModel.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (await widget.onAdd() == true && mounted) {
      _appointmentsViewModel.loadAppointments();
    }
  }

  Future<void> _showDetails(Appointment a) async {
    final cancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final divider = Divider(
          height: 1,
          color: theme.colorScheme.outlineVariant,
        );
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(a.pet, style: theme.textTheme.titleLarge)),
              TypeBadge(type: a.type, style: TypeBadgeStyle.colored),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacerL,
            children: [
              divider,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _DetailBlock(label: Strings.dateLabel, value: a.date),
                  _DetailBlock(label: Strings.timeLabel, value: a.time),
                ],
              ),
              divider,
              _DetailBlock(
                label: Strings.vet,
                value: a.vet.isEmpty ? Strings.unknown : a.vet,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                Strings.cancel,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(Strings.close),
            ),
          ],
        );
      },
    );
    if (cancel == true && mounted) await _confirmCancel(a);
  }

  Future<void> _confirmCancel(Appointment a) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(Strings.cancelAppointment),
        content: const Text(Strings.confirmCancel),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(Strings.back),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              Strings.yesCancel,
              style: TextStyle(
                color: Theme.of(dialogContext).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) await _appointmentsViewModel.deleteAppointment(a.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PetNestAppBar(
        title: Strings.appointments,
        onLogout: widget.onLogout,
      ),
      bottomNavigationBar: CustomerBottomBar(
        selectedTab: CustomerTab.appointments,
        onTabSelected: widget.onTabSelected,
      ),
      body: Padding(
        padding: const EdgeInsets.all(contentHorizontalPadding),
        child: Column(
          children: [
            PillButton(text: Strings.newAppointment, onPressed: _add),
            const SizedBox(height: spacerXL),
            Expanded(
              child: ListenableBuilder(
                listenable: _appointmentsViewModel,
                builder: (context, _) {
                  final appointments = _appointmentsViewModel.appointments;
                  if (appointments.isEmpty) {
                    return const Align(
                      alignment: Alignment.topLeft,
                      child: Text(Strings.noAppointmentsYet),
                    );
                  }
                  return ListView.separated(
                    itemCount: appointments.length,
                    separatorBuilder: (_, _) => const SizedBox(height: spacerL),
                    itemBuilder: (context, i) => _AppointmentCard(
                      appointment: appointments[i],
                      onTap: () => _showDetails(appointments[i]),
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

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment, required this.onTap});

  final Appointment appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(cardPaddingSmall),
          child: Row(
            children: [
              Expanded(
                child: Text(appointment.pet, style: theme.textTheme.bodyMedium),
              ),
              Expanded(
                child: Text(
                  appointment.time,
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TypeBadge(
                    type: appointment.type,
                    style: TypeBadgeStyle.colored,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall!.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge!.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
