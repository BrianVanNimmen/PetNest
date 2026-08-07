package be.brianvannimmen.petnest.ui.Screens.Klant
import be.brianvannimmen.petnest.ui.theme.*

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import coil.compose.AsyncImage
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.navigation.compose.rememberNavController
import be.brianvannimmen.petnest.R
import be.brianvannimmen.petnest.network.MedischDossier
import be.brianvannimmen.petnest.network.PetInfo
import be.brianvannimmen.petnest.network.RetrofitClient
import be.brianvannimmen.petnest.ui.klantViewmodel.MedischDossierViewModel


@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MedischDossierScreen(
    petId: Int,
    onBack: () -> Unit,
    viewModel: MedischDossierViewModel = remember { MedischDossierViewModel() }
) {
    val dossier = viewModel.dossier
    val isLoading = viewModel.isLoading

    LaunchedEffect(petId) {
        viewModel.load(petId)
    }

    Scaffold(
        topBar = {
            PetNestAppBar(
                title = stringResource(R.string.medisch_dossier),
                onBack = onBack
            )
        }
    ) { padding ->

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(contentHorizontalPadding)
        ) {
            when {
                isLoading -> CircularProgressIndicator()
                dossier == null -> Text(stringResource(R.string.geen_dossier_gevonden))
                else -> {
                    val d = dossier!!
                    PetHeader(d.pet)
                    Spacer(Modifier.height(spacerXL))
                    DossierForm(d)
                }
            }
        }
    }
}

@Composable
fun PetHeader(
    pet: PetInfo?
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        PetImage(
            url = pet?.fotoUrl
        )
        Spacer(
            modifier = Modifier.width(spacerL)
        )
        Column {

            Text(
                text = pet?.naam ?: stringResource(R.string.onbekend_dier),
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )

            Text(
                text = pet?.soort ?: stringResource(R.string.onbekend_soort)
            )

            if (!pet?.geboortedatum.isNullOrEmpty()) {

                Text(
                    text = stringResource(R.string.geboortedatum_label, pet!!.geboortedatum)
                )
            }
        }
    }
}

@Composable
fun PetImage(
    url: String?
) {
    Box(
        modifier = Modifier
            .size(patientPhotoSizeLarge)
            .clip(MaterialTheme.shapes.medium)
            .background(MaterialTheme.colorScheme.surfaceVariant),
        contentAlignment = Alignment.Center
    ) {
        AsyncImage(
            model = url?.let { if (!it.startsWith("http")) RetrofitClient.BASE_URL + it else it },
            contentDescription = null,
            contentScale = ContentScale.Crop,
            modifier = Modifier.fillMaxSize()
        )
    }
}

@Composable
fun DossierForm(
    d: MedischDossier
) {
    Column {
        DossierField(
            label = stringResource(R.string.gewicht_kg),
            value = d.gewicht
        )
        DossierField(
            label = stringResource(R.string.gebit_status),
            value = d.gebitStatus
        )
        DossierField(
            label = stringResource(R.string.botten_status),
            value = d.bottenStatus
        )
        DossierField(
            label = stringResource(R.string.spieren_status),
            value = d.spierenStatus
        )
        DossierField(
            label = stringResource(R.string.opmerking),
            value = d.opmerking
        )
    }
}
@Composable
fun DossierField(
    label: String,
    value: String?
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(bottom = spacerL)
            .clip(MaterialTheme.shapes.medium)
            .background(MaterialTheme.colorScheme.surfaceVariant)
            .padding(spacerL)
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.labelMedium,
            color = MaterialTheme.colorScheme.primary
        )
        Spacer(
            modifier = Modifier.height(spacerXS)
        )
        Text(
            text = value ?: "-",
            style = MaterialTheme.typography.bodyMedium
        )
    }
}

private fun fakeLoadDossier(dummy: MedischDossier): suspend (Int) -> MedischDossier? {
    return { _: Int -> dummy }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun MedischDossierLightPreview() {

    val dummy = MedischDossier(
        pet = PetInfo(
            naam = "Bobby",
            soort = "Hond",
            geboortedatum = "2020-05-10",
            fotoUrl = null
        ),
        gewicht = "5.3",
        gebitStatus = "Goed",
        bottenStatus = "Normaal",
        spierenStatus = "Sterk",
        opmerking = "Gezond dier"
    )

    val navController = rememberNavController()

    PetNestTheme(darkTheme = false) {
        MedischDossierScreen(
            petId = 1,
            onBack = {navController.popBackStack()},
        )
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun MedischDossierDarkPreview() {

    val dummy = MedischDossier(
        pet = PetInfo(
            naam = "Bobby",
            soort = "Hond",
            geboortedatum = "2020-05-10",
            fotoUrl = null
        ),
        gewicht = "5.3",
        gebitStatus = "Goed",
        bottenStatus = "Normaal",
        spierenStatus = "Sterk",
        opmerking = "Gezond dier"
    )

    val navController = rememberNavController()

    PetNestTheme(darkTheme = true) {
        MedischDossierScreen(
            petId = 1,
            onBack = { navController.popBackStack()},
        )
    }
}