import 'package:material_ui/material_ui.dart';

import '../../../network/user_session.dart';
import '../../../strings.dart';
import '../../../theme/dimens.dart';
import '../../components/appointment_widgets.dart';
import '../../components/bottom_bars.dart';
import '../../components/images.dart';
import '../../components/petnest_app_bar.dart';
import '../../viewmodels/customer/customer_home_view_model.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({
    super.key,
    required this.onAllAppointments,
    required this.onLogout,
    required this.onAccessibility,
    required this.onTabSelected,
  });

  final VoidCallback onAllAppointments;
  final VoidCallback onLogout;
  final VoidCallback onAccessibility;
  final ValueChanged<CustomerTab> onTabSelected;

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  static const _maxReminders = 3;

  final _viewModel = CustomerHomeViewModel();
  final _newReminder = TextEditingController();
  List<String> _reminders = const [];

  @override
  void initState() {
    super.initState();
    final customerId = UserSession.id;
    if (customerId != null) _viewModel.loadAppointments(customerId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _newReminder.dispose();
    super.dispose();
  }

  void _addReminder() {
    final text = _newReminder.text.trim();
    if (text.isEmpty || _reminders.length >= _maxReminders) return;
    setState(() {
      _reminders = [text, ..._reminders.take(_maxReminders - 1)];
      _newReminder.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: PetNestAppBar(
        onAccessibility: widget.onAccessibility,
        onLogout: widget.onLogout,
      ),
      bottomNavigationBar: CustomerBottomBar(
        selectedTab: CustomerTab.home,
        onTabSelected: widget.onTabSelected,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(contentHorizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: spacerXXL),
            AppLogo(background: scheme.primaryContainer),
            const SizedBox(height: spacerM + spacerS),
            Text.rich(
              TextSpan(
                text: Strings.welcome,
                children: [
                  TextSpan(
                    text: UserSession.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              style: theme.textTheme.bodyMedium!.copyWith(
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: spacerXXL + spacerL),
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) => AppointmentsSummaryCard(
                title: Strings.myAppointments,
                emptyText: Strings.noScheduledAppointments,
                buttonText: Strings.viewAllAppointments,
                isLoading: _viewModel.isLoading,
                onButtonPressed: widget.onAllAppointments,
                rows: [
                  for (final a in _viewModel.appointments)
                    AppointmentRow(
                      title: a.pet,
                      subtitle: '${a.date}  ·  ${a.time.split(' ').last}',
                      type: a.type,
                    ),
                ],
              ),
            ),
            const SizedBox(height: spacerXL),
            _RemindersCard(
              reminders: _reminders,
              controller: _newReminder,
              canAdd: _reminders.length < _maxReminders,
              onAdd: _addReminder,
              onRemove: (index) => setState(() {
                _reminders = [..._reminders]..removeAt(index);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemindersCard extends StatelessWidget {
  const _RemindersCard({
    required this.reminders,
    required this.controller,
    required this.canAdd,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> reminders;
  final TextEditingController controller;
  final bool canAdd;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      elevation: cardElevationHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(cardPaddingSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Strings.myReminders,
              style: theme.textTheme.titleMedium!.copyWith(
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: spacerM),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (_) => onAdd(),
                    decoration: InputDecoration(
                      hintText: Strings.newReminder,
                      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                      filled: true,
                      fillColor: scheme.surfaceContainer,
                      border: const UnderlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: spacerM),
                ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) => FilledButton(
                    onPressed: controller.text.trim().isNotEmpty && canAdd
                        ? onAdd
                        : null,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(radiusMedium),
                      ),
                    ),
                    child: Text(Strings.add, style: theme.textTheme.bodyMedium),
                  ),
                ),
              ],
            ),
            const SizedBox(height: spacerM),
            if (reminders.isEmpty)
              Text(
                Strings.noReminders,
                style: TextStyle(color: scheme.onSurfaceVariant),
              )
            else
              for (final (index, reminder) in reminders.indexed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: spacerXS),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          reminder,
                          style: TextStyle(color: scheme.onSurface),
                        ),
                      ),
                      TextButton(
                        onPressed: () => onRemove(index),
                        child: Text(
                          Strings.delete,
                          style: TextStyle(color: scheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
