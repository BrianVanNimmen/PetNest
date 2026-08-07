package be.brianvannimmen.petnest.ui.Screens.Klant
import be.brianvannimmen.petnest.ui.theme.*

import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material3.Button
import androidx.compose.material3.DatePicker
import androidx.compose.material3.DatePickerDialog
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberDatePickerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import be.brianvannimmen.petnest.model.SimpleItem
import be.brianvannimmen.petnest.ui.klantViewmodel.DierenartsViewModel
import be.brianvannimmen.petnest.ui.klantViewmodel.HuisdierenViewModel
import coil.compose.rememberAsyncImagePainter
import java.util.Calendar
import be.brianvannimmen.petnest.R

@Composable
fun NieuwHuisdierRoute(
    huisdierenViewModel: HuisdierenViewModel = androidx.lifecycle.viewmodel.compose.viewModel(),
    artsenViewModel: DierenartsViewModel = androidx.lifecycle.viewmodel.compose.viewModel(),
    onBack: () -> Unit
) {
    val artsen by artsenViewModel.artsen.collectAsState()

    NieuwHuisdierScreen(
        artsen = artsen,
        onBack = onBack,
        onSave = { naam, ras, datum, arts, foto ->
            huisdierenViewModel.saveHuisdier(
                naam = naam,
                soort = ras,
                geboortedatum = datum,
                artsId = arts?.id ?: 0,
                fotoUri = foto
            )
            // refresh lijst meteen
            huisdierenViewModel.refresh()

            onBack()
        }
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NieuwHuisdierScreen(
    artsen: List<SimpleItem> = emptyList(),
    onBack: () -> Unit = {},
    onSave: (String, String, String, SimpleItem?, Uri?) -> Unit = { _, _, _, _, _ -> }
) {

    var naam by remember { mutableStateOf("") }
    var ras by remember { mutableStateOf("") }
    var geboortedatum by remember { mutableStateOf("") }
    var selectedArts by remember { mutableStateOf<SimpleItem?>(null) }
    var photo by remember { mutableStateOf<Uri?>(null) }

    Scaffold(
        topBar = {
            PetNestAppBar(
                title = stringResource(R.string.nieuw_huisdier),
                onBack = onBack
            )
        }
    ) { padding ->

        Column(
            modifier = Modifier
                .padding(padding)
                .padding(contentHorizontalPadding),
            verticalArrangement = Arrangement.spacedBy(spacerL)
        ) {

            HuisdierFotoPicker(photo = photo, onPick = { photo = it })

            HuisdierNaamVeld(naam) { naam = it }

            HuisdierRasVeld(ras) { ras = it }

            HuisdierGeboortedatumVeld(
                value = geboortedatum,
                onDateSelected = { geboortedatum = it }
            )

            DierenartsVeld(
                artsen = artsen,
                selected = selectedArts,
                onSelected = { selectedArts = it }
            )

            Button(
                onClick = {
                    onSave(
                        naam,
                        ras,
                        geboortedatum,
                        selectedArts,
                        photo
                    )
                },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(stringResource(R.string.opslaan))
            }
        }
    }
}

@Composable
fun HuisdierFotoPicker(
    photo: Uri?,
    onPick: (Uri) -> Unit
) {
    val launcher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri ->
        uri?.let(onPick)
    }

    Box(
        modifier = Modifier
            .size(photoPickerSize)
            .clip(MaterialTheme.shapes.medium)
            .background(MaterialTheme.colorScheme.surfaceVariant)
            .clickable { launcher.launch("image/*") },
        contentAlignment = Alignment.Center
    ) {

        if (photo != null) {
            Image(
                painter = rememberAsyncImagePainter(photo),
                contentDescription = stringResource(R.string.gekozen_foto),
                modifier = Modifier.fillMaxSize()
            )
        } else {
            Text(stringResource(R.string.foto), style = MaterialTheme.typography.bodyMedium)
        }
    }
}

@Composable
fun HuisdierNaamVeld(
    value: String,
    onChange: (String) -> Unit
) {
    Column {
        Text(stringResource(R.string.naam), style = MaterialTheme.typography.bodyMedium)

        OutlinedTextField(
            value = value,
            onValueChange = onChange,
            placeholder = { Text(stringResource(R.string.placeholder_naam_dier)) },
            modifier = Modifier.fillMaxWidth(),
            shape = MaterialTheme.shapes.small
        )
    }
}

@Composable
fun HuisdierRasVeld(
    value: String,
    onChange: (String) -> Unit
) {
    Column {
        Text(stringResource(R.string.soort_ras), style = MaterialTheme.typography.bodyMedium)

        OutlinedTextField(
            value = value,
            onValueChange = onChange,
            placeholder = { Text(stringResource(R.string.placeholder_ras_dier)) },
            modifier = Modifier.fillMaxWidth(),
            shape = MaterialTheme.shapes.small
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HuisdierGeboortedatumVeld(
    value: String,
    onDateSelected: (String) -> Unit
) {
    var open by remember { mutableStateOf(false) }
    val state = rememberDatePickerState()

    Column {
        Text(stringResource(R.string.geboortedatum), style = MaterialTheme.typography.bodyMedium)

        OutlinedTextField(
            value = value,
            onValueChange = {},
            readOnly = true,
            placeholder = { Text(stringResource(R.string.datum_placeholder)) },
            trailingIcon = {
                IconButton(onClick = { open = true }) {
                    Icon(Icons.Default.CalendarMonth, null)
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

                        onDateSelected(
                            "%04d-%02d-%02d".format(
                                cal.get(Calendar.YEAR),
                                cal.get(Calendar.MONTH) + 1,
                                cal.get(Calendar.DAY_OF_MONTH)
                            )
                        )
                    }
                    open = false
                }) { Text(stringResource(R.string.ok)) }
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

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DierenartsVeld(
    artsen: List<SimpleItem>,
    selected: SimpleItem?,
    onSelected: (SimpleItem) -> Unit
) {
    var expanded by remember { mutableStateOf(false) }

    var search by remember { mutableStateOf("") }

    // sync UI when selected changes
    LaunchedEffect(selected) {
        search = selected?.naam ?: ""
    }

    val filtered = remember(search, artsen) {
        if (search.isBlank()) {
            artsen
        } else {
            artsen.filter {
                it.naam.contains(search, ignoreCase = true)
            }
        }
    }

    Column {
        Text(stringResource(R.string.dierenarts), style = MaterialTheme.typography.bodyMedium)

        ExposedDropdownMenuBox(
            expanded = expanded,
            onExpandedChange = { expanded = it }
        ) {

            OutlinedTextField(
                value = search,
                onValueChange = {
                    search = it
                    expanded = true
                },
                placeholder = { Text(stringResource(R.string.selecteer_dierenarts)) },
                modifier = Modifier
                    .fillMaxWidth()
                    .menuAnchor(),
                shape = MaterialTheme.shapes.small,
                singleLine = true
            )

            ExposedDropdownMenu(
                expanded = expanded && filtered.isNotEmpty(),
                onDismissRequest = { expanded = false }
            ) {
                filtered.forEach { arts ->
                    DropdownMenuItem(
                        text = { Text(arts.naam) },
                        onClick = {
                            search = arts.naam
                            onSelected(arts)
                            expanded = false
                        }
                    )
                }
            }
        }
    }
}


@Preview(showBackground = true, showSystemUi = true)
@Composable
fun NieuwHuisdierLightPreview() {

    val artsen = listOf(
        SimpleItem(1, "Dr. Peeters"),
        SimpleItem(2, "Dr. Janssens")
    )

    PetNestTheme(darkTheme = false) {
        NieuwHuisdierScreen(
            artsen = artsen,
            onBack = {},
            onSave = { _, _, _, _, _ -> }
        )
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun NieuwHuisdierDarkPreview() {

    val artsen = listOf(
        SimpleItem(1, "Dr. Peeters"),
        SimpleItem(2, "Dr. Janssens")
    )

    PetNestTheme(darkTheme = true) {
        NieuwHuisdierScreen(
            artsen = artsen,
            onBack = {},
            onSave = { _, _, _, _, _ -> }
        )
    }
}