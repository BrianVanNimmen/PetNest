package be.brianvannimmen.petnest.ui.Screens.Arts
import be.brianvannimmen.petnest.ui.theme.*

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CenterAlignedTopAppBar
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DatePicker
import androidx.compose.material3.DatePickerDialog
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.MaterialTheme.colorScheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.rememberDatePickerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import be.brianvannimmen.petnest.R
import be.brianvannimmen.petnest.network.Afspraak
import be.brianvannimmen.petnest.ui.artsViewmodel.ArtsConsultatiesViewModel
import java.util.Calendar



private fun vandaagIso(): String {
    val cal = Calendar.getInstance()
    return "%04d-%02d-%02d".format(
        cal.get(Calendar.YEAR),
        cal.get(Calendar.MONTH) + 1,
        cal.get(Calendar.DAY_OF_MONTH)
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ArtsConsultatiesScreen(
    onLogout: () -> Unit = {},
    viewModel: ArtsConsultatiesViewModel,
    onTabSelected: (ArtsTab) -> Unit = {}
) {
    val extended = LocalExtendedColors.current
    var geselecteerdeDatum by remember { mutableStateOf(vandaagIso()) }
    var toonDatePicker by remember { mutableStateOf(false) }
    val datePickerState = rememberDatePickerState()

    LaunchedEffect(geselecteerdeDatum) {
        viewModel.laadAfspraken(geselecteerdeDatum)
    }

    if (toonDatePicker) {
        DatePickerDialog(
            onDismissRequest = { toonDatePicker = false },
            confirmButton = {
                TextButton(onClick = {
                    datePickerState.selectedDateMillis?.let { millis ->
                        val cal = Calendar.getInstance()
                        cal.timeInMillis = millis
                        geselecteerdeDatum = "%04d-%02d-%02d".format(
                            cal.get(Calendar.YEAR),
                            cal.get(Calendar.MONTH) + 1,
                            cal.get(Calendar.DAY_OF_MONTH)
                        )
                    }
                    toonDatePicker = false
                }) { Text(stringResource(R.string.ok)) }
            },
            dismissButton = {
                TextButton(onClick = { toonDatePicker = false }) { Text(stringResource(R.string.annuleer)) }
            }
        ) {
            DatePicker(state = datePickerState)
        }
    }

    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = { Text(stringResource(R.string.consultaties)) },
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
                selectedTab = ArtsTab.Consultaties,
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
                .padding(horizontal = contentHorizontalPadding, vertical = contentVerticalPadding),
            verticalArrangement = Arrangement.spacedBy(spacerM)
        ) {
            OutlinedTextField(
                value = geselecteerdeDatum,
                onValueChange = {},
                readOnly = true,
                placeholder = {
                    Text(
                        stringResource(R.string.datum_placeholder),
                        color = colorScheme.onSurface.copy(alpha = 0.4f),
                        style = MaterialTheme.typography.bodyMedium
                    )
                },
                trailingIcon = {
                    IconButton(onClick = { toonDatePicker = true }) {
                        Icon(Icons.Default.CalendarMonth, contentDescription = stringResource(R.string.kies_datum))
                    }
                },
                modifier = Modifier.fillMaxWidth(),
                shape = MaterialTheme.shapes.medium,
                colors = OutlinedTextFieldDefaults.colors(
                    focusedContainerColor = colorScheme.surface,
                    unfocusedContainerColor = colorScheme.surface,
                    focusedBorderColor = colorScheme.outline,
                    unfocusedBorderColor = colorScheme.outline
                )
            )

            Spacer(modifier = Modifier.height(spacerXS))

            when {
                viewModel.isLoading -> {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = spacerXXXL),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator()
                    }
                }
                viewModel.error != null -> {
                    Text(
                        text = viewModel.error!!,
                        color = colorScheme.error,
                        style = MaterialTheme.typography.bodyMedium,
                        modifier = Modifier.padding(vertical = spacerXL)
                    )
                }
                viewModel.afspraken.isEmpty() -> {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = spacerXXXL),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = stringResource(R.string.geen_afspraken_voor_dag),
                            style = MaterialTheme.typography.bodyMedium,
                            fontStyle = FontStyle.Italic,
                            color = colorScheme.onSurface.copy(alpha = 0.45f)
                        )
                    }
                }
                else -> {
                    viewModel.afspraken.forEach { afspraak ->
                        ConsultatieRij(afspraak = afspraak)
                    }
                }
            }
        }
    }
}

@Composable
fun ConsultatieRij(afspraak: Afspraak) {
    val tijdstip = afspraak.tijd.substringAfterLast(" ")

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = MaterialTheme.shapes.medium,
        colors = CardDefaults.cardColors(containerColor = colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = cardElevationLow)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = buttonHorizontalPadding, vertical = spacerL),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = afspraak.dier,
                    style = MaterialTheme.typography.titleSmall,
                    color = colorScheme.onSurface
                )
                Text(
                    text = tijdstip,
                    style = MaterialTheme.typography.bodySmall,
                    color = colorScheme.onSurface.copy(alpha = 0.6f)
                )
            }
            TypeBadge(type = afspraak.type)
        }
    }
}

@Composable
fun TypeBadge(type: String) {
    val isDonker = type.equals("Operatie", ignoreCase = true)
    val achtergrond = if (isDonker) colorScheme.primary else colorScheme.primaryContainer
    val tekstKleur = if (isDonker) colorScheme.onPrimary else colorScheme.onPrimaryContainer

    Box(
        modifier = Modifier
            .clip(CircleShape)
            .background(achtergrond)
            .padding(horizontal = badgeHorizontalPadding, vertical = badgeVerticalPadding)
    ) {
        Text(
            text = type,
            style = MaterialTheme.typography.labelMedium,
            fontWeight = FontWeight.Medium,
            color = tekstKleur
        )
    }
}

@Preview(showBackground = true)
@Composable
fun ArtsConsultatiesLightScreenPreview() {
    PetNestTheme(darkTheme = false) {
        ArtsConsultatiesScreen(viewModel = ArtsConsultatiesViewModel())
    }
}

@Preview(showBackground = true)
@Composable
fun ArtsConsultatiesDarkScreenPreview() {
    PetNestTheme(darkTheme = true) {
        ArtsConsultatiesScreen(viewModel = ArtsConsultatiesViewModel())
    }
}