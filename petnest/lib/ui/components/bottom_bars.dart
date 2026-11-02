import 'package:material_ui/material_ui.dart';

import '../../routes.dart';
import '../../strings.dart';

enum CustomerTab {
  home(Strings.home, Icons.home_outlined, Routes.customerHome),
  pets(Strings.myPets, Icons.pets_outlined, Routes.customerPets),
  appointments(
    Strings.appointments,
    Icons.calendar_month_outlined,
    Routes.customerAppointments,
  );

  const CustomerTab(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}

enum VetTab {
  home(Strings.home, Icons.home_outlined, Routes.vetHome),
  myPatients(Strings.myPatients, Icons.pets_outlined, Routes.vetPatients),
  consultations(
    Strings.consultations,
    Icons.calendar_month_outlined,
    Routes.vetConsultations,
  );

  const VetTab(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}

class CustomerBottomBar extends StatelessWidget {
  const CustomerBottomBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final CustomerTab selectedTab;
  final ValueChanged<CustomerTab> onTabSelected;

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: selectedTab.index,
    onDestinationSelected: (i) => onTabSelected(CustomerTab.values[i]),
    destinations: [
      for (final tab in CustomerTab.values)
        NavigationDestination(icon: Icon(tab.icon), label: tab.label),
    ],
  );
}

class VetBottomBar extends StatelessWidget {
  const VetBottomBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final VetTab selectedTab;
  final ValueChanged<VetTab> onTabSelected;

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: selectedTab.index,
    onDestinationSelected: (i) => onTabSelected(VetTab.values[i]),
    destinations: [
      for (final tab in VetTab.values)
        NavigationDestination(icon: Icon(tab.icon), label: tab.label),
    ],
  );
}
