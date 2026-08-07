package be.brianvannimmen.petnest.ui.Screens.Arts
import be.brianvannimmen.petnest.ui.theme.*

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CenterAlignedTopAppBar
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.MaterialTheme.colorScheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.tooling.preview.Preview
import be.brianvannimmen.petnest.R
import be.brianvannimmen.petnest.network.Patient
import be.brianvannimmen.petnest.network.RetrofitClient
import coil.compose.AsyncImage

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ArtsPatientDetailsScreen(
    patient: Patient,
    onSluiten: () -> Unit = {},
    onTabSelected: (ArtsTab) -> Unit = {},
    onMedischDossier: (Patient) -> Unit = {}
) {
    val extended = LocalExtendedColors.current

    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = {
                    Text(
                        text = stringResource(R.string.patient_details),
                        style = MaterialTheme.typography.bodyLarge,
                        fontWeight = FontWeight.SemiBold
                    )
                },
                actions = {
                    TextButton(onClick = onSluiten) {
                        Text(
                            text = stringResource(R.string.sluiten_uppercase),
                            style = MaterialTheme.typography.bodySmall,
                            fontWeight = FontWeight.SemiBold,
                            color = extended.topBar.onColor
                        )
                    }
                },
                colors = TopAppBarDefaults.centerAlignedTopAppBarColors(
                    containerColor = extended.topBar.color,
                    titleContentColor = extended.topBar.onColor
                )
            )
        },
        bottomBar = {
            PetNestBottomBarArts(
                selectedTab = ArtsTab.MijnPatienten,
                onTabSelected = onTabSelected
            )
        },
        containerColor = colorScheme.background
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = contentHorizontalPaddingLarge, vertical = spacerXXL),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(
                modifier = Modifier
                    .size(detailPhotoSize)
                    .clip(MaterialTheme.shapes.extraLarge)
                    .background(colorScheme.surfaceVariant),
                contentAlignment = Alignment.Center
            ) {
                AsyncImage(
                    model = patient.fotoUrl?.let { if (!it.startsWith("http")) RetrofitClient.BASE_URL + it else it },
                    contentDescription = stringResource(R.string.foto_van_patient, patient.naam),
                    modifier = Modifier
                        .size(detailPhotoSize)
                        .clip(MaterialTheme.shapes.extraLarge),
                    contentScale = ContentScale.Crop,
                    error = painterResource(R.drawable.petnest_logo),
                    placeholder = painterResource(R.drawable.petnest_logo)
                )
            }

            Spacer(modifier = Modifier.height(spacerXXXL))

            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = MaterialTheme.shapes.large,
                colors = CardDefaults.cardColors(containerColor = colorScheme.surface),
                border = CardDefaults.outlinedCardBorder()
            ) {
                Column(modifier = Modifier.padding(cardPaddingSmall)) {
                    Text(
                        text = patient.naam,
                        style = MaterialTheme.typography.titleLarge,
                        color = colorScheme.onSurface
                    )

                    Spacer(modifier = Modifier.height(spacerM))

                    val soortRasLabel = stringResource(R.string.soort_ras_label)
                    Text(
                        buildAnnotatedString {
                            withStyle(SpanStyle(fontWeight = FontWeight.Bold)) {
                                append(soortRasLabel)
                            }
                            append(patient.soort)
                        },
                        style = MaterialTheme.typography.bodyMedium,
                        color = colorScheme.onSurface
                    )

                    if (patient.geboortedatum != null) {
                        Spacer(modifier = Modifier.height(spacerXS))
                        val geboortedatumLabel = stringResource(R.string.geboortedatum_label, patient.geboortedatum)
                        Text(
                            text = geboortedatumLabel,
                            style = MaterialTheme.typography.bodyMedium,
                            color = colorScheme.onSurface
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(spacerXXXL))

            Button(
                onClick = { onMedischDossier(patient) },
                modifier = Modifier.fillMaxWidth(),
                shape = MaterialTheme.shapes.medium,
                colors = ButtonDefaults.buttonColors(
                    containerColor = colorScheme.primary,
                    contentColor = colorScheme.onPrimary
                ),
                contentPadding = PaddingValues(vertical = buttonVerticalPadding)
            ) {
                Text(
                    text = stringResource(R.string.medisch_dossier_uppercase),
                    style = MaterialTheme.typography.labelLarge
                )
            }
        }
    }
}

private val previewPatient = Patient(1, "Hubert", "Chihuahua", "09/09/2019")

@Preview(showBackground = true)
@Composable
fun ArtsPatientDetailsLightScreenPreview() {
    PetNestTheme(darkTheme = false) {
        ArtsPatientDetailsScreen(patient = previewPatient)
    }
}

@Preview(showBackground = true)
@Composable
fun ArtsPatientDetailsDarkScreenPreview() {
    PetNestTheme(darkTheme = true) {
        ArtsPatientDetailsScreen(patient = previewPatient)
    }
}
