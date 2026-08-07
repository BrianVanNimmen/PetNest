package be.brianvannimmen.petnest.ui

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import be.brianvannimmen.petnest.network.UserSession
import be.brianvannimmen.petnest.ui.Screens.Arts.ArtsConsultatiesScreen
import be.brianvannimmen.petnest.ui.Screens.Arts.ArtsHomeScreen
import be.brianvannimmen.petnest.ui.Screens.Arts.ArtsMedischDossierScreen
import be.brianvannimmen.petnest.ui.Screens.Arts.ArtsPatientDetailsScreen
import be.brianvannimmen.petnest.ui.Screens.Arts.ArtsPatientenScreen
import be.brianvannimmen.petnest.ui.Screens.Arts.ArtsTab
import be.brianvannimmen.petnest.ui.Screens.Klant.AfsprakenScreen
import be.brianvannimmen.petnest.ui.Screens.Klant.EditHuisdierRoute
import be.brianvannimmen.petnest.ui.Screens.Klant.HuisdierenRoute
import be.brianvannimmen.petnest.ui.Screens.Klant.KlantTab
import be.brianvannimmen.petnest.ui.Screens.Shared.AccessibilityScreen
import be.brianvannimmen.petnest.ui.Screens.Shared.LoginScreen
import be.brianvannimmen.petnest.ui.Screens.Shared.RegisterArtsScreen
import be.brianvannimmen.petnest.ui.Screens.Shared.RegisterKlantScreen
import be.brianvannimmen.petnest.ui.Screens.Shared.RegisterScreen
import be.brianvannimmen.petnest.ui.Screens.Klant.KlantHomeScreen
import be.brianvannimmen.petnest.ui.Screens.Klant.MedischDossierScreen
import be.brianvannimmen.petnest.ui.Screens.Klant.NieuwHuisdierRoute
import be.brianvannimmen.petnest.ui.Screens.Klant.NieuweAfspraakRoute
import be.brianvannimmen.petnest.ui.artsViewmodel.ArtsConsultatiesViewModel
import be.brianvannimmen.petnest.ui.artsViewmodel.ArtsMedischDossierViewModel
import be.brianvannimmen.petnest.ui.artsViewmodel.ArtsPatientenViewModel

private enum class PetNestScreen {
    Login,
    Register,
    RegisterArts,
    RegisterKlant,
    ArtsHome,
    Accessibility
}

@Composable
fun PetNestApp(
    isDarkMode: Boolean = false,
    onToggleDarkMode: () -> Unit = {}
) {
    val navController = rememberNavController()
    val patientenViewModel: ArtsPatientenViewModel = viewModel()
    val dossierViewModel: ArtsMedischDossierViewModel = viewModel()
    val consultatiesViewModel: ArtsConsultatiesViewModel = viewModel()

    NavHost(
        navController = navController,
        startDestination = PetNestScreen.Login.name
    ) {
        composable(route = PetNestScreen.Login.name) {
            LoginScreen(
                onMaakAccount = { navController.navigate(PetNestScreen.Register.name) },
                onKlantLogin = {
                    navController.navigate(KlantTab.Home.route) {
                        popUpTo(PetNestScreen.Login.name) { inclusive = true }
                        launchSingleTop = true
                    }
                },
                onArtsLogin = {
                    navController.navigate(PetNestScreen.ArtsHome.name) {
                        popUpTo(PetNestScreen.Login.name) { inclusive = true }
                        launchSingleTop = true
                    }
                },
                onAccessibility = { navController.navigate(PetNestScreen.Accessibility.name) }
            )
        }

        composable(route = PetNestScreen.Register.name) {
            RegisterScreen(
                onRegisterArts = { navController.navigate(PetNestScreen.RegisterArts.name) },
                onRegisterKlant = { navController.navigate(PetNestScreen.RegisterKlant.name) },
                onTerug = { navController.popBackStack() }
            )
        }

        composable(route = PetNestScreen.RegisterArts.name) {
            RegisterArtsScreen(
                onTerug = { navController.popBackStack() },
                onRegistratieSucces = {
                    navController.navigate(PetNestScreen.Login.name) {
                        popUpTo(PetNestScreen.Login.name) { inclusive = true }
                    }
                }
            )
        }

        composable(route = PetNestScreen.RegisterKlant.name) {
            RegisterKlantScreen(
                onTerug = { navController.popBackStack() },
                onRegistratieSucces = {
                    navController.navigate(PetNestScreen.Login.name) {
                        popUpTo(PetNestScreen.Login.name) { inclusive = true }
                    }
                }
            )
        }

        // Klant routes
        composable(KlantTab.Home.route) {
            KlantHomeScreen(
                onAllAfsprakenClick = { navController.navigate(KlantTab.Afspraken.route) },
                onLogout = {
                    UserSession.clear()
                    navController.navigate(PetNestScreen.Login.name) {
                        popUpTo(PetNestScreen.Login.name) { inclusive = true }
                    }
                },
                onAccessibility = { navController.navigate(PetNestScreen.Accessibility.name) },
                onTabSelected = { tab -> navController.navigate(tab.route) {
                    popUpTo(KlantTab.Home.route) { saveState = true }
                    launchSingleTop = true
                    restoreState = true
                }}
            )
        }

        composable(KlantTab.Huisdieren.route) {
            HuisdierenRoute(
                onAddClick = { navController.navigate("nieuw_huisdier") },
                onEdit = { id -> navController.navigate("edit_huisdier/$id") },
                onMedisch = { id -> navController.navigate("medisch_dossier/$id") },
                onLogout = { UserSession.clear(); navController.navigate(PetNestScreen.Login.name) { popUpTo(0) { inclusive = true } } },
                onTabSelected = { tab -> navController.navigate(tab.route) { popUpTo(KlantTab.Home.route) { saveState = true }; launchSingleTop = true; restoreState = true } }
            )
        }

        composable("nieuw_huisdier") {
            NieuwHuisdierRoute(onBack = { navController.popBackStack() })
        }

        composable("edit_huisdier/{petId}") { backStackEntry ->
            val petId = backStackEntry.arguments?.getString("petId")?.toIntOrNull() ?: 0
            EditHuisdierRoute(petId = petId, onBack = { navController.popBackStack() })
        }

        composable(KlantTab.Afspraken.route) {
            AfsprakenScreen(
                onAddClick = { navController.navigate("nieuwe_afspraak") },
                onLogout = { UserSession.clear(); navController.navigate(PetNestScreen.Login.name) { popUpTo(0) { inclusive = true } } },
                onTabSelected = { tab -> navController.navigate(tab.route) { popUpTo(KlantTab.Home.route) { saveState = true }; launchSingleTop = true; restoreState = true } }
            )
        }

        composable("nieuwe_afspraak") {
            NieuweAfspraakRoute(navController = navController, onBack = { navController.popBackStack() })
        }

        composable("medisch_dossier/{petId}") { backStackEntry ->
            val petId = backStackEntry.arguments?.getString("petId")?.toIntOrNull()
            if (petId == null) { Text("Ongeldig dossier ID"); return@composable }
            MedischDossierScreen(petId = petId, onBack = { navController.popBackStack() })
        }

        // Arts routes
        composable(route = PetNestScreen.ArtsHome.name) {
            ArtsHomeScreen(
                onTabSelected = { tab ->
                    if (tab != ArtsTab.Home) navController.navigate(tab.route)
                },
                onLogout = {
                    UserSession.clear()
                    navController.navigate(PetNestScreen.Login.name) {
                        popUpTo(0) { inclusive = true }
                    }
                },
                onAccessibility = { navController.navigate(PetNestScreen.Accessibility.name) },
                onConsultaties = { navController.navigate(ArtsTab.Consultaties.route) }
            )
        }

        composable(route = ArtsTab.Consultaties.route) {
            ArtsConsultatiesScreen(
                viewModel = consultatiesViewModel,
                onTabSelected = { tab ->
                    if (tab == ArtsTab.Home) navController.navigate(PetNestScreen.ArtsHome.name)
                    else navController.navigate(tab.route)
                }
            )
        }

        composable(route = ArtsTab.MijnPatienten.route) {
            ArtsPatientenScreen(
                viewModel = patientenViewModel,
                onTabSelected = { tab ->
                    if (tab == ArtsTab.Home) navController.navigate(PetNestScreen.ArtsHome.name)
                    else navController.navigate(tab.route)
                },
                onLogout = {
                    UserSession.clear()
                    navController.navigate(PetNestScreen.Login.name) {
                        popUpTo(0) { inclusive = true }
                    }
                },
                onPatientClick = { patient ->
                    navController.navigate("arts/patient/${patient.id}")
                }
            )
        }

        composable(
            route = "arts/patient/{patientId}",
            arguments = listOf(navArgument("patientId") { type = NavType.IntType })
        ) { backStackEntry ->
            val patientId = backStackEntry.arguments?.getInt("patientId")
            val patient = patientenViewModel.patienten.find { it.id == patientId }
            if (patient != null) {
                ArtsPatientDetailsScreen(
                    patient = patient,
                    onSluiten = { navController.popBackStack() },
                    onTabSelected = { tab ->
                        if (tab == ArtsTab.Home) navController.navigate(PetNestScreen.ArtsHome.name)
                        else navController.navigate(tab.route)
                    },
                    onMedischDossier = { p ->
                        navController.navigate("arts/patient/${p.id}/dossier")
                    }
                )
            }
        }

        composable(
            route = "arts/patient/{patientId}/dossier",
            arguments = listOf(navArgument("patientId") { type = NavType.IntType })
        ) { backStackEntry ->
            val patientId = backStackEntry.arguments?.getInt("patientId")
            val patient = patientenViewModel.patienten.find { it.id == patientId }
            if (patient != null) {
                ArtsMedischDossierScreen(
                    patient = patient,
                    onBack = { navController.popBackStack() },
                    onTabSelected = { tab ->
                        if (tab == ArtsTab.Home) navController.navigate(PetNestScreen.ArtsHome.name)
                        else navController.navigate(tab.route)
                    },
                    viewModel = dossierViewModel
                )
            }
        }

        // Accessibility screen
        composable(route = PetNestScreen.Accessibility.name) {
            AccessibilityScreen(
                isDarkMode = isDarkMode,
                onToggleDarkMode = onToggleDarkMode,
                onBack = { navController.popBackStack() }
            )
        }
    }
}
