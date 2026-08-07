package be.brianvannimmen.petnest.ui.Screens.Arts
import be.brianvannimmen.petnest.ui.theme.*

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CenterAlignedTopAppBar
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.MaterialTheme.colorScheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.lifecycle.viewmodel.compose.viewModel
import be.brianvannimmen.petnest.R
import be.brianvannimmen.petnest.network.Patient
import be.brianvannimmen.petnest.network.RetrofitClient
import be.brianvannimmen.petnest.ui.artsViewmodel.ArtsMedischDossierViewModel
import coil.compose.AsyncImage

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ArtsMedischDossierScreen(
    patient: Patient,
    onBack: () -> Unit = {},
    onTabSelected: (ArtsTab) -> Unit = {},
    viewModel: ArtsMedischDossierViewModel = viewModel()
) {
    val extended = LocalExtendedColors.current
    val snackbarHostState = remember { SnackbarHostState() }
    val dossierOpgeslagenText = stringResource(R.string.dossier_opgeslagen)

    LaunchedEffect(patient.id) {
        viewModel.laad(patient.id)
    }

    LaunchedEffect(viewModel.opslaanSucces) {
        if (viewModel.opslaanSucces) {
            snackbarHostState.showSnackbar(dossierOpgeslagenText)
            viewModel.resetOpslaanSucces()
        }
    }

    LaunchedEffect(viewModel.error) {
        val err = viewModel.error
        if (err != null && !viewModel.isLoading) {
            snackbarHostState.showSnackbar(err)
        }
    }

    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = { Text(stringResource(R.string.medisch_dossier)) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = stringResource(R.string.terug),
                            tint = extended.topBar.onColor
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
        containerColor = colorScheme.background,
        snackbarHost = { SnackbarHost(snackbarHostState) }
    ) { innerPadding ->
        if (viewModel.isLoading) {
            Box(
                Modifier
                    .fillMaxSize()
                    .padding(innerPadding),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator()
            }
        } else Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding)
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = contentHorizontalPadding, vertical = contentVerticalPadding)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.padding(bottom = spacerXXL)
                ) {
                    AsyncImage(
                        model = patient.fotoUrl?.let { if (!it.startsWith("http")) RetrofitClient.BASE_URL + it else it },
                        contentDescription = null,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier
                            .size(patientPhotoSizeLarge)
                            .clip(MaterialTheme.shapes.medium)
                            .background(colorScheme.surfaceVariant),
                        error = painterResource(R.drawable.petnest_logo),
                        placeholder = painterResource(R.drawable.petnest_logo)
                    )

                    Spacer(modifier = Modifier.width(spacerXL))

                    Column {
                        Text(
                            text = patient.naam,
                            style = MaterialTheme.typography.titleMedium,
                            color = colorScheme.onSurface
                        )
                        Text(
                            text = patient.soort,
                            style = MaterialTheme.typography.bodyMedium,
                            color = colorScheme.onSurface.copy(alpha = 0.7f)
                        )
                        if (patient.geboortedatum != null) {
                            Text(
                                text = stringResource(R.string.geboortedatum_label, patient.geboortedatum),
                                style = MaterialTheme.typography.bodyMedium,
                                color = colorScheme.onSurface.copy(alpha = 0.7f)
                            )
                        }
                    }
                }

                DossierField(
                    label = stringResource(R.string.gewicht_kg),
                    value = viewModel.gewicht,
                    onValueChange = { viewModel.gewicht = it },
                    placeholder = stringResource(R.string.placeholder_gewicht)
                )
                DossierField(
                    label = stringResource(R.string.gebit_status),
                    value = viewModel.gebitStatus,
                    onValueChange = { viewModel.gebitStatus = it },
                    placeholder = stringResource(R.string.placeholder_gebit)
                )
                DossierField(
                    label = stringResource(R.string.botten_status),
                    value = viewModel.bottenStatus,
                    onValueChange = { viewModel.bottenStatus = it },
                    placeholder = stringResource(R.string.placeholder_botten)
                )
                DossierField(
                    label = stringResource(R.string.spieren_status),
                    value = viewModel.spierenStatus,
                    onValueChange = { viewModel.spierenStatus = it },
                    placeholder = stringResource(R.string.placeholder_spieren)
                )
                DossierField(
                    label = stringResource(R.string.opmerking),
                    value = viewModel.opmerking,
                    onValueChange = { viewModel.opmerking = it },
                    placeholder = stringResource(R.string.placeholder_opmerking),
                    singleLine = false,
                    minLines = 3
                )

                Spacer(modifier = Modifier.height(spacerXXXL))

                Button(
                    onClick = { viewModel.opslaan() },
                    enabled = !viewModel.isSaving,
                    modifier = Modifier.fillMaxWidth(),
                    shape = MaterialTheme.shapes.medium,
                    colors = ButtonDefaults.buttonColors(
                        containerColor = colorScheme.primary,
                        contentColor = colorScheme.onPrimary
                    ),
                    contentPadding = PaddingValues(vertical = buttonVerticalPadding)
                ) {
                    if (viewModel.isSaving) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(progressIndicatorSizeLarge),
                            color = colorScheme.onPrimary,
                            strokeWidth = progressIndicatorStroke
                        )
                    } else {
                        Text(
                            text = stringResource(R.string.opslaan_uppercase),
                            style = MaterialTheme.typography.labelLarge
                        )
                    }
                }
            }
    }
}

@Composable
fun DossierField(
    label: String,
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String = "",
    singleLine: Boolean = true,
    minLines: Int = 1
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = spacerS),
        shape = MaterialTheme.shapes.medium,
        colors = CardDefaults.cardColors(containerColor = colorScheme.surface),
        border = CardDefaults.outlinedCardBorder()
    ) {
        Column(
            modifier = Modifier.padding(horizontal = contentHorizontalPadding, vertical = spacerFormField)
        ) {
            Text(
                text = label,
                style = MaterialTheme.typography.labelMedium,
                color = colorScheme.onSurface.copy(alpha = 0.6f)
            )
            OutlinedTextField(
                value = value,
                onValueChange = onValueChange,
                placeholder = {
                    Text(
                        text = placeholder,
                        style = MaterialTheme.typography.bodyMedium,
                        color = colorScheme.onSurface.copy(alpha = 0.4f)
                    )
                },
                singleLine = singleLine,
                minLines = minLines,
                modifier = Modifier.fillMaxWidth(),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = colorScheme.surface,
                    unfocusedBorderColor = colorScheme.surface,
                    focusedContainerColor = colorScheme.surface,
                    unfocusedContainerColor = colorScheme.surface
                ),
                textStyle = MaterialTheme.typography.bodyLarge.copy(color = colorScheme.onSurface)
            )
        }
    }
}

private val previewPatient = Patient(1, "Hubert", "Chihuahua", "09/09/2019")

@Preview(showBackground = true)
@Composable
fun ArtsMedischDossierLightScreenPreview() {
    PetNestTheme(darkTheme = false) {
        ArtsMedischDossierScreen(patient = previewPatient)
    }
}

@Preview(showBackground = true)
@Composable
fun ArtsMedischDossierDarkScreenPreview() {
    PetNestTheme(darkTheme = true) {
        ArtsMedischDossierScreen(patient = previewPatient)
    }
}
