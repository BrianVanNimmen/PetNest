import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'data/models/pet.dart';
import 'data/petnest_repository.dart';
import 'data/user_session.dart';
import 'routes.dart';
import 'strings.dart';
import 'theme/app_theme.dart';
import 'ui/screens/customer/appointments_screen.dart';
import 'ui/screens/customer/customer_home_screen.dart';
import 'ui/screens/customer/edit_pet_screen.dart';
import 'ui/screens/customer/medical_record_screen.dart';
import 'ui/screens/customer/new_appointment_screen.dart';
import 'ui/screens/customer/new_pet_screen.dart';
import 'ui/screens/customer/pets_screen.dart';
import 'ui/screens/shared/accessibility_screen.dart';
import 'ui/screens/shared/login_screen.dart';
import 'ui/screens/shared/register_customer_screen.dart';
import 'ui/screens/shared/register_screen.dart';
import 'ui/screens/shared/register_vet_screen.dart';
import 'ui/screens/vet/vet_consultations_screen.dart';
import 'ui/screens/vet/vet_home_screen.dart';
import 'ui/screens/vet/vet_medical_record_screen.dart';
import 'ui/screens/vet/vet_patient_details_screen.dart';
import 'ui/screens/vet/vet_patients_screen.dart';
import 'ui/viewmodels/shared/theme_view_model.dart';
import 'ui/viewmodels/vet/vet_patients_view_model.dart';

class PetNestApp extends StatefulWidget {
  const PetNestApp({super.key});

  @override
  State<PetNestApp> createState() => _PetNestAppState();
}

class _PetNestAppState extends State<PetNestApp> {
  final _themeViewModel = ThemeViewModel();
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  // App-scoped so the patient detail routes can look patients up by id
  final _patientsViewModel = VetPatientsViewModel();

  late final GoRouter _router = GoRouter(
    initialLocation: Routes.login,
    redirect: (context, state) {
      final path = state.uri.path;
      // Logged-out users can only reach the login/register/settings screens
      final customerOnly = path.startsWith('/customer');
      if (customerOnly && !UserSession.isCustomer) return Routes.login;
      if (path.startsWith('/vet') && !UserSession.isVet) return Routes.login;
      final completingProfile = path.startsWith(Routes.completeProfile);
      if (completingProfile && PetNestRepository.instance.currentUser == null) {
        return Routes.login;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) => LoginScreen(
          onCreateAccount: () => context.push(Routes.register),
          onCustomerLogin: () => context.go(Routes.customerHome),
          onVetLogin: () => context.go(Routes.vetHome),
          onProfileRequired: () => context.push(Routes.completeProfile),
          onAccessibility: () => context.push(Routes.accessibility),
        ),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => RegisterScreen(
          onRegisterVet: () => context.push(Routes.registerVet),
          onRegisterCustomer: () => context.push(Routes.registerCustomer),
          onBack: () => context.pop(),
        ),
      ),
      GoRoute(
        path: Routes.registerVet,
        builder: (context, state) => RegisterVetScreen(
          onBack: () => context.pop(),
          onRegistrationSuccess: () =>
              _goToLogin(context, message: Strings.registeredVet),
        ),
      ),
      GoRoute(
        path: Routes.registerCustomer,
        builder: (context, state) => RegisterCustomerScreen(
          onBack: () => context.pop(),
          onRegistrationSuccess: () =>
              _goToLogin(context, message: Strings.registeredCustomer),
        ),
      ),

      // After a Google sign-in for an account without a PetNest profile
      GoRoute(
        path: Routes.completeProfile,
        builder: (context, state) => RegisterScreen(
          completingProfile: true,
          onRegisterVet: () => context.push(Routes.completeProfileVet),
          onRegisterCustomer: () =>
              context.push(Routes.completeProfileCustomer),
          onBack: () => _logout(context),
        ),
      ),
      GoRoute(
        path: Routes.completeProfileVet,
        builder: (context, state) => RegisterVetScreen(
          useSignedInAccount: true,
          onBack: () => context.pop(),
          onRegistrationSuccess: () =>
              _goToLogin(context, message: Strings.registeredVet),
        ),
      ),
      GoRoute(
        path: Routes.completeProfileCustomer,
        builder: (context, state) => RegisterCustomerScreen(
          useSignedInAccount: true,
          onBack: () => context.pop(),
          onRegistrationSuccess: () => context.go(Routes.customerHome),
        ),
      ),
      GoRoute(
        path: Routes.accessibility,
        builder: (context, state) => ListenableBuilder(
          listenable: _themeViewModel,
          builder: (context, _) => AccessibilityScreen(
            isDarkMode: _themeViewModel.isDarkMode,
            onToggleDarkMode: _themeViewModel.toggleDarkMode,
            onBack: () => context.pop(),
          ),
        ),
      ),

      // Customer routes
      GoRoute(
        path: Routes.customerHome,
        builder: (context, state) => CustomerHomeScreen(
          onAllAppointments: () => context.go(Routes.customerAppointments),
          onLogout: () => _logout(context),
          onAccessibility: () => context.push(Routes.accessibility),
          onTabSelected: (tab) => context.go(tab.route),
        ),
      ),
      GoRoute(
        path: Routes.customerPets,
        builder: (context, state) => PetsScreen(
          onAdd: () => context.push<bool>(Routes.newPet),
          onEdit: (id) => context.push<bool>(Routes.editPet(id)),
          onMedicalRecord: (id) => context.push(Routes.medicalRecord(id)),
          onLogout: () => _logout(context),
          onTabSelected: (tab) => context.go(tab.route),
        ),
      ),
      GoRoute(
        path: Routes.newPet,
        builder: (context, state) => const NewPetScreen(),
      ),
      GoRoute(
        path: '/customer/pets/:petId/edit',
        builder: (context, state) =>
            EditPetScreen(petId: state.pathParameters['petId']!),
      ),
      GoRoute(
        path: '/customer/pets/:petId/record',
        builder: (context, state) => MedicalRecordScreen(
          petId: state.pathParameters['petId']!,
          onBack: () => context.pop(),
        ),
      ),
      GoRoute(
        path: Routes.customerAppointments,
        builder: (context, state) => AppointmentsScreen(
          onAdd: () => context.push<bool>(Routes.newAppointment),
          onLogout: () => _logout(context),
          onTabSelected: (tab) => context.go(tab.route),
        ),
      ),
      GoRoute(
        path: Routes.newAppointment,
        builder: (context, state) => const NewAppointmentScreen(),
      ),

      // Vet routes
      GoRoute(
        path: Routes.vetHome,
        builder: (context, state) => VetHomeScreen(
          onTabSelected: (tab) => context.go(tab.route),
          onLogout: () => _logout(context),
          onAccessibility: () => context.push(Routes.accessibility),
          onConsultations: () => context.go(Routes.vetConsultations),
        ),
      ),
      GoRoute(
        path: Routes.vetConsultations,
        builder: (context, state) => VetConsultationsScreen(
          onLogout: () => _logout(context),
          onTabSelected: (tab) => context.go(tab.route),
        ),
      ),
      GoRoute(
        path: Routes.vetPatients,
        builder: (context, state) => VetPatientsScreen(
          viewModel: _patientsViewModel,
          onLogout: () => _logout(context),
          onTabSelected: (tab) => context.go(tab.route),
          onPatientTap: (patient) =>
              context.push(Routes.vetPatient(patient.id), extra: patient),
        ),
      ),
      GoRoute(
        path: '/vet/patients/:patientId',
        redirect: (context, state) =>
            _patient(state) == null ? Routes.vetPatients : null,
        builder: (context, state) => VetPatientDetailsScreen(
          patient: _patient(state)!,
          onClose: () => context.pop(),
          onTabSelected: (tab) => context.go(tab.route),
          onMedicalRecord: (patient) =>
              context.push(Routes.vetMedicalRecord(patient.id), extra: patient),
        ),
      ),
      GoRoute(
        path: '/vet/patients/:patientId/record',
        redirect: (context, state) =>
            _patient(state) == null ? Routes.vetPatients : null,
        builder: (context, state) => VetMedicalRecordScreen(
          patient: _patient(state)!,
          onBack: () => context.pop(),
          onTabSelected: (tab) => context.go(tab.route),
        ),
      ),
    ],
  );

  Pet? _patient(GoRouterState state) =>
      state.extra as Pet? ??
      _patientsViewModel.findPatient(state.pathParameters['patientId']!);

  void _goToLogin(BuildContext context, {required String message}) {
    context.go(Routes.login);
    _messengerKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  void _logout(BuildContext context) {
    UserSession.clear();
    _patientsViewModel.clear();
    PetNestRepository.instance.signOut();
    context.go(Routes.login);
  }

  @override
  void dispose() {
    _router.dispose();
    _themeViewModel.dispose();
    _patientsViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeViewModel,
      builder: (context, _) => MaterialApp.router(
        title: Strings.appName,
        debugShowCheckedModeBanner: false,
        theme: buildPetNestTheme(darkTheme: false),
        darkTheme: buildPetNestTheme(darkTheme: true),
        themeMode: _themeViewModel.isDarkMode
            ? ThemeMode.dark
            : ThemeMode.light,
        scaffoldMessengerKey: _messengerKey,
        routerConfig: _router,
      ),
    );
  }
}
