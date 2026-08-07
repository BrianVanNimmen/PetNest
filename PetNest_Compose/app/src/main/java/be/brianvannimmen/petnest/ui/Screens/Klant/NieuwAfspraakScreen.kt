package be.brianvannimmen.petnest.ui.Screens.Klant
import be.brianvannimmen.petnest.ui.theme.*

import android.util.Log
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import be.brianvannimmen.petnest.model.SimpleItem
import be.brianvannimmen.petnest.model.TIJD_SLOTEN
import be.brianvannimmen.petnest.ui.components.DropdownField
import be.brianvannimmen.petnest.ui.klantViewmodel.DierenartsViewModel
import be.brianvannimmen.petnest.ui.klantViewmodel.HuisdierenViewModel
import be.brianvannimmen.petnest.ui.klantViewmodel.AfspraakViewModel
import java.util.Calendar
import be.brianvannimmen.petnest.R

@Composable
fun NieuweAfspraakRoute(
    navController: NavHostController,
    onBack: () -> Unit
) {
    val huisdierenViewModel: HuisdierenViewModel = viewModel()
    val dierenartsViewModel: DierenartsViewModel = viewModel()
    val afspraakViewModel: AfspraakViewModel = viewModel()

    val huisdierenState by huisdierenViewModel.uiState.collectAsState()
    val artsen by dierenartsViewModel.artsen.collectAsState()

    val dieren = huisdierenState.dieren.map {
        SimpleItem(it.id, it.naam ?: "Onbekend")
    }

    LaunchedEffect(Unit) {
        huisdierenViewModel.refresh()
    }

    NieuweAfspraakScreen(
        dieren = dieren,
        artsen = artsen,
        navController = navController,
        onBack = onBack,
        afspraakViewModel = afspraakViewModel,
        onSuccess = {
            afspraakViewModel.loadAfspraken()
            navController.popBackStack()
        }
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NieuweAfspraakScreen(
    dieren: List<SimpleItem> = emptyList(),
    artsen: List<SimpleItem> = emptyList(),
    onBack: () -> Unit = {},
    onSuccess: () -> Unit = {},
    navController: NavHostController,
    afspraakViewModel: AfspraakViewModel
) {
    val currentRoute =
        navController.currentBackStackEntryAsState().value?.destination?.route

    val selectedTab =
        KlantTab.entries.find { it.route == currentRoute } ?: KlantTab.Afspraken

    var selectedDier by remember { mutableStateOf<SimpleItem?>(null) }
    var selectedArts by remember { mutableStateOf<SimpleItem?>(null) }

    var type by remember { mutableStateOf("") }
    var datum by remember { mutableStateOf("") }
    var tijd by remember { mutableStateOf("") }

    Scaffold(
        topBar = {
            PetNestAppBar(
                title = stringResource(R.string.nieuwe_afspraak),
                onBack = onBack
            )
        }
    ) { padding ->

        Column(
            modifier = Modifier
                .padding(padding)
                .fillMaxSize()
                .padding(contentHorizontalPadding)
        ) {

            AfspraakFormCard(
                afspraakViewModel = afspraakViewModel,
                dieren = dieren,
                artsen = artsen,
                selectedDier = selectedDier,
                selectedArts = selectedArts,
                type = type,
                datum = datum,
                tijd = tijd,

                onDierChange = { selectedDier = it },
                onArtsChange = { selectedArts = it },
                onTypeChange = { type = it },
                onDatumChange = { datum = it },
                onTijdChange = { tijd = it }
            )

            Spacer(modifier = Modifier.height(spacerXXL))

            Button(
                onClick = {
                    afspraakViewModel.createAfspraak(
                        dierId = selectedDier?.id ?: return@Button,
                        artsId = selectedArts?.id ?: return@Button,
                        datum = datum,
                        tijd = tijd,
                        type = type,
                        onSuccess = {
                            onSuccess()
                        }
                    )
                },
                modifier = Modifier.fillMaxWidth(),
                shape = MaterialTheme.shapes.medium
            ) {
                Text(stringResource(R.string.afspraak_opslaan), style = MaterialTheme.typography.bodyMedium)
            }
        }
    }
}

@Composable
fun AfspraakFormCard(
    afspraakViewModel: AfspraakViewModel,
    dieren: List<SimpleItem>,
    artsen: List<SimpleItem>,
    selectedDier: SimpleItem?,
    selectedArts: SimpleItem?,
    type: String,
    datum: String,
    tijd: String,
    onDierChange: (SimpleItem) -> Unit,
    onArtsChange: (SimpleItem) -> Unit,
    onTypeChange: (String) -> Unit,
    onDatumChange: (String) -> Unit,
    onTijdChange: (String) -> Unit
) {

    val bezetteSlots by afspraakViewModel.bezetteSlots.collectAsState()

    LaunchedEffect(datum, selectedArts) {
        Log.d("AFSPRAAK", "LaunchedEffect: datum=$datum arts=$selectedArts")
        if (datum.isNotBlank() && selectedArts != null) {
            afspraakViewModel.loadBezetteSlots(datum, selectedArts.id)
        }
    }

    val beschikbareSloten = TIJD_SLOTEN.filter { it.start !in bezetteSlots }
    val datumGekozen = datum.isNotBlank()

    val onbekendDierText = stringResource(R.string.onbekend_dier_kort)
    val onbekendArtsText = stringResource(R.string.onbekende_arts)
    val controleText = stringResource(R.string.afspraak_type_controle)
    val vaccinatieText = stringResource(R.string.afspraak_type_vaccinatie)
    val operatieText = stringResource(R.string.afspraak_type_operatie)

    Card(
        shape = MaterialTheme.shapes.large,
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = cardElevationDefault)
    ) {
        Column(modifier = Modifier.padding(cardPaddingSmall)) {

            DropdownField(
                label = stringResource(R.string.dier_label),
                selectedText = selectedDier?.naam,
                items = dieren.map { it.naam ?: onbekendDierText },
                onItemSelected = { naam ->
                    dieren.find { it.naam == naam }?.let { onDierChange(it) }
                }
            )

            Spacer(modifier = Modifier.height(spacerL))

            DropdownField(
                label = stringResource(R.string.dierenarts),
                selectedText = selectedArts?.naam,
                items = artsen.map { it.naam ?: onbekendArtsText },
                onItemSelected = { naam ->
                    artsen.find { it.naam == naam }?.let { onArtsChange(it) }
                }
            )

            Spacer(modifier = Modifier.height(spacerL))

            DropdownField(
                label = stringResource(R.string.type_afspraak),
                selectedText = type,
                items = listOf(controleText, vaccinatieText, operatieText),
                onItemSelected = onTypeChange
            )

            Spacer(modifier = Modifier.height(spacerL))

            DatumPickerField(
                value = datum,
                onDateSelected = {
                    onDatumChange(it)
                    onTijdChange("")
                }
            )

            Spacer(modifier = Modifier.height(spacerL))

            DropdownField(
                label = stringResource(R.string.tijdslot),
                selectedText = tijd.ifBlank { null },
                items = beschikbareSloten.map { it.start },
                onItemSelected = onTijdChange,
                enabled = datumGekozen
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DatumPickerField(
    value: String,
    onDateSelected: (String) -> Unit
) {
    var open by remember { mutableStateOf(false) }
    val state = rememberDatePickerState()

    Column {
        Text(
            text = stringResource(R.string.datum_label),
            style = MaterialTheme.typography.labelMedium,
            color = MaterialTheme.colorScheme.primary
        )

        OutlinedTextField(
            value = value,
            onValueChange = {},
            readOnly = true,
            placeholder = { Text(stringResource(R.string.datum_placeholder)) },
            trailingIcon = {
                IconButton(onClick = { open = true }) {
                    Icon(Icons.Default.CalendarMonth, contentDescription = null)
                }
            },
            modifier = Modifier.fillMaxWidth(),
            shape = MaterialTheme.shapes.small
        )
    }

    if (open) {
        DatePickerDialog(
            onDismissRequest = { open = false },
            confirmButton = {
                TextButton(onClick = {
                    state.selectedDateMillis?.let {
                        val cal = Calendar.getInstance()
                        cal.timeInMillis = it

                        val formatted = "%04d-%02d-%02d".format(
                            cal.get(Calendar.YEAR),
                            cal.get(Calendar.MONTH) + 1,
                            cal.get(Calendar.DAY_OF_MONTH)
                        )

                        onDateSelected(formatted)
                    }
                    open = false
                }) {
                    Text(stringResource(R.string.ok))
                }
            },
            dismissButton = {
                TextButton(onClick = { open = false }) {
                    Text(stringResource(R.string.annuleer))
                }
            }
        ) {
            DatePicker(state = state)
        }
    }
}


@Preview(showBackground = true, showSystemUi = true)
@Composable
fun NieuweAfspraakLightPreview() {
    PetNestTheme(darkTheme = false) {
        val navController = rememberNavController()
        val afspraakViewModel: AfspraakViewModel = viewModel()
        NieuweAfspraakScreen(
            dieren = listOf(
                SimpleItem(1, "Luna"),
                SimpleItem(2, "Max")
            ),
            artsen = listOf(
                SimpleItem(1, "Dr. Peeters"),
                SimpleItem(2, "Dr. Janssens")
            ),
            navController = navController,
            afspraakViewModel = afspraakViewModel
        )
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun NieuweAfspraakDarkPreview() {
    val navController = rememberNavController()
    val afspraakViewModel: AfspraakViewModel = viewModel()
    PetNestTheme(darkTheme = true) {
        NieuweAfspraakScreen(
            dieren = listOf(
                SimpleItem(1, "Luna"),
                SimpleItem(2, "Max")
            ),
            artsen = listOf(
                SimpleItem(1, "Dr. Peeters"),
                SimpleItem(2, "Dr. Janssens")
            ),
            navController = navController,
            afspraakViewModel = afspraakViewModel
        )
    }
}