package be.brianvannimmen.petnest.ui.Screens.Arts
import be.brianvannimmen.petnest.ui.theme.*

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CenterAlignedTopAppBar
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.MaterialTheme.colorScheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
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
import be.brianvannimmen.petnest.ui.artsViewmodel.ArtsPatientenViewModel
import coil.compose.AsyncImage

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ArtsPatientenScreen(
    onLogout: () -> Unit = {},
    onTabSelected: (ArtsTab) -> Unit = {},
    onPatientClick: (Patient) -> Unit = {},
    viewModel: ArtsPatientenViewModel = viewModel()
) {
    val extended = LocalExtendedColors.current

    LaunchedEffect(Unit) {
        viewModel.laadPatienten()
    }

    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = { Text(stringResource(R.string.patienten)) },
                actions = {
                    TextButton(onClick = onLogout) {
                        Text(stringResource(R.string.afmelden), color = extended.topBar.onColor)
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
        Box(modifier = Modifier.padding(innerPadding)) {
            ArtsPatientenContent(
                patienten = viewModel.patienten,
                isLoading = viewModel.isLoading,
                error = viewModel.error,
                onPatientClick = onPatientClick
            )
        }
    }
}

@Composable
fun ArtsPatientenContent(
    patienten: List<Patient>,
    isLoading: Boolean,
    error: String?,
    onPatientClick: (Patient) -> Unit = {}
) {
    when {
        isLoading -> Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            CircularProgressIndicator()
        }
        error != null -> Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text(text = error, color = colorScheme.error)
        }
        patienten.isEmpty() -> Box(Modifier.fillMaxSize(), contentAlignment = Alignment.TopCenter) {
            Text(
                text = stringResource(R.string.geen_actieve_patienten),
                modifier = Modifier.padding(top = spacerTop),
                style = MaterialTheme.typography.bodyLarge,
                color = colorScheme.onBackground.copy(alpha = 0.5f)
            )
        }
        else -> LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = contentHorizontalPadding, vertical = spacerM)
        ) {
            items(patienten) { dier ->
                PatientCard(
                    patient = dier,
                    onClick = { onPatientClick(dier) }
                )
            }
        }
    }
}



@Composable
fun PatientCard(
    patient: Patient,
    onClick: () -> Unit = {}
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = spacerS)
            .clickable { onClick() },
        shape = MaterialTheme.shapes.medium,
        colors = CardDefaults.cardColors(containerColor = colorScheme.surface),
        border = CardDefaults.outlinedCardBorder()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(spacerL),
            verticalAlignment = Alignment.CenterVertically
        ) {
            AsyncImage(
                model = patient.fotoUrl?.let { if (!it.startsWith("http")) RetrofitClient.BASE_URL + it else it },
                contentDescription = stringResource(R.string.foto_van_patient, patient.naam),
                modifier = Modifier
                    .size(patientPhotoSize)
                    .clip(MaterialTheme.shapes.extraSmall),
                contentScale = ContentScale.Crop,
                error = painterResource(R.drawable.petnest_logo),
                placeholder = painterResource(R.drawable.petnest_logo)
            )

            Spacer(modifier = Modifier.width(spacerXL))

            Column {
                Text(
                    text = patient.naam,
                    style = MaterialTheme.typography.bodyLarge,
                    fontWeight = FontWeight.Bold,
                    color = colorScheme.onSurface
                )
                Text(
                    text = patient.soort,
                    style = MaterialTheme.typography.bodySmall,
                    color = colorScheme.onSurface.copy(alpha = 0.7f)
                )
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun ArtsPatientenLightScreenPreview() {
    PetNestTheme(darkTheme = false) {
        ArtsPatientenScreen()
    }
}

@Preview(showBackground = true)
@Composable
fun ArtsPatientenDarkScreenPreview() {
    PetNestTheme(darkTheme = true) {
        ArtsPatientenScreen()
    }
}
