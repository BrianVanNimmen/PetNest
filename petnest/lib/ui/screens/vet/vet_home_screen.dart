import 'package:material_ui/material_ui.dart';

import '../../../strings.dart';
import '../../../theme/dimens.dart';
import '../../components/appointment_widgets.dart';
import '../../components/bottom_bars.dart';
import '../../components/images.dart';
import '../../components/petnest_app_bar.dart';
import '../../viewmodels/vet/vet_home_view_model.dart';

class VetHomeScreen extends StatefulWidget {
  const VetHomeScreen({
    super.key,
    required this.onTabSelected,
    required this.onLogout,
    required this.onAccessibility,
    required this.onConsultations,
  });

  final ValueChanged<VetTab> onTabSelected;
  final VoidCallback onLogout;
  final VoidCallback onAccessibility;
  final VoidCallback onConsultations;

  @override
  State<VetHomeScreen> createState() => _VetHomeScreenState();
}

class _VetHomeScreenState extends State<VetHomeScreen> {
  final _viewModel = VetHomeViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PetNestAppBar(
        onAccessibility: widget.onAccessibility,
        onLogout: widget.onLogout,
      ),
      bottomNavigationBar: VetBottomBar(
        selectedTab: VetTab.home,
        onTabSelected: widget.onTabSelected,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(contentHorizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: spacerXXL),
            const AppLogo(),
            const SizedBox(height: spacerM + spacerS),
            Text.rich(
              TextSpan(
                text: Strings.welcomeDr,
                children: [
                  TextSpan(
                    text: _viewModel.vetName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: spacerXL + spacerS),
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) => AppointmentsSummaryCard(
                title: Strings.myConsultationsToday,
                emptyText: Strings.noConsultationsToday,
                buttonText: Strings.viewAllConsultations,
                isLoading: _viewModel.isLoading,
                error: _viewModel.error,
                onButtonPressed: widget.onConsultations,
                rows: [
                  for (final a in _viewModel.appointments)
                    AppointmentRow(
                      title: a.pet,
                      subtitle: a.time.split(' ').last,
                      type: a.type,
                      badgeStyle: TypeBadgeStyle.pill,
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
