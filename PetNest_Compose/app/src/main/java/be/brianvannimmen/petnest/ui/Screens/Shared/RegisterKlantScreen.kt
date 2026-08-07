package be.brianvannimmen.petnest.ui.Screens.Shared
import be.brianvannimmen.petnest.ui.theme.*

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material3.*
import androidx.compose.material3.MaterialTheme.colorScheme
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.tooling.preview.Preview
import androidx.lifecycle.viewmodel.compose.viewModel
import be.brianvannimmen.petnest.R
import be.brianvannimmen.petnest.network.Gemeente
import be.brianvannimmen.petnest.ui.sharedViewmodel.RegisterKlantViewModel
import java.util.Calendar
import java.util.TimeZone
import be.brianvannimmen.petnest.ui.sharedViewmodel.UiState

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RegisterKlantScreen(
    onTerug: () -> Unit = {},
    onRegistratieSucces: () -> Unit = {},
    viewModel: RegisterKlantViewModel = viewModel()
) {
    var voornaam by remember { mutableStateOf("") }
    var achternaam by remember { mutableStateOf("") }
    var email by remember { mutableStateOf("") }
    var wachtwoord by remember { mutableStateOf("") }
    var herhaalWachtwoord by remember { mutableStateOf("") }
    var geboortedatum by remember { mutableStateOf("") }
    var geselecteerdeGemeente by remember { mutableStateOf<Gemeente?>(null) }
    var validatieFout by remember { mutableStateOf<String?>(null) }

    val vulAlleVeldenIn = stringResource(R.string.vul_alle_velden_in)
    val vulGeldigeEmail = stringResource(R.string.vul_geldige_email_in)
    val wachtwoordTeKort = stringResource(R.string.wachtwoord_te_kort)
    val wachtwoordenNietOvereen = stringResource(R.string.wachtwoorden_komen_niet_overeen)

    val uiState = viewModel.uiState
    val gemeentes = viewModel.gemeentes

    LaunchedEffect(uiState) {
        if (uiState is UiState.Success) {
            onRegistratieSucces()
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(colorScheme.background)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = screenHorizontalPadding),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {

            Spacer(modifier = Modifier.height(spacerTop))

            Text(
                text = stringResource(R.string.klantenregistratie),
                style = MaterialTheme.typography.headlineSmall
            )

            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = MaterialTheme.shapes.large,
                colors = CardDefaults.cardColors(containerColor = colorScheme.surface),
                elevation = CardDefaults.cardElevation(defaultElevation = cardElevationDefault)
            ) {
                Column(modifier = Modifier.padding(cardPadding)) {

                    RegistratieVeld(
                        value = voornaam,
                        onValueChange = { voornaam = it },
                        placeholder = stringResource(R.string.placeholder_voornaam),
                        text = stringResource(R.string.voornaam)
                    )

                    Spacer(modifier = Modifier.height(spacerFormField))

                    RegistratieVeld(
                        value = achternaam,
                        onValueChange = { achternaam = it },
                        placeholder = stringResource(R.string.placeholder_achternaam),
                        text = stringResource(R.string.achternaam)
                    )

                    Spacer(modifier = Modifier.height(spacerFormField))

                    RegistratieVeld(
                        value = email,
                        onValueChange = { email = it },
                        placeholder = stringResource(R.string.placeholder_email),
                        text = stringResource(R.string.email)
                    )

                    Spacer(modifier = Modifier.height(spacerFormField))

                    GeboortedatumVeld(
                        geboortedatum = geboortedatum,
                        onDatumGekozen = { geboortedatum = it }
                    )

                    Spacer(modifier = Modifier.height(spacerFormField))

                    GemeenteVeld(
                        gemeentes = gemeentes,
                        geselecteerdeGemeente = geselecteerdeGemeente,
                        onGemeenteGekozen = { geselecteerdeGemeente = it }
                    )

                    Spacer(modifier = Modifier.height(spacerFormField))

                    RegistratieVeld(
                        value = wachtwoord,
                        onValueChange = { wachtwoord = it },
                        placeholder = stringResource(R.string.placeholder_wachtwoord),
                        text = stringResource(R.string.wachtwoord),
                        visualTransformation = PasswordVisualTransformation()
                    )

                    Spacer(modifier = Modifier.height(spacerFormField))

                    RegistratieVeld(
                        value = herhaalWachtwoord,
                        onValueChange = { herhaalWachtwoord = it },
                        placeholder = stringResource(R.string.placeholder_wachtwoord),
                        text = stringResource(R.string.herhaal_wachtwoord),
                        visualTransformation = PasswordVisualTransformation()
                    )

                    Spacer(modifier = Modifier.height(spacerL))

                    validatieFout?.let {
                        Text(text = it, color = colorScheme.error, style = MaterialTheme.typography.labelMedium)
                        Spacer(modifier = Modifier.height(spacerXS))
                    }

                    if (uiState is UiState.Error) {
                        Text(
                            text = uiState.message,
                            color = colorScheme.error,
                            style = MaterialTheme.typography.labelMedium
                        )
                        Spacer(modifier = Modifier.height(spacerXS))
                    }

                    Spacer(modifier = Modifier.height(spacerM))

                    RegistreerKlantKnop(
                        uiState = uiState,
                        onClick = {
                            validatieFout = when {
                                voornaam.isBlank() -> vulAlleVeldenIn
                                achternaam.isBlank() -> vulAlleVeldenIn
                                email.isBlank() -> vulAlleVeldenIn
                                !android.util.Patterns.EMAIL_ADDRESS.matcher(email.trim()).matches() -> vulGeldigeEmail
                                geboortedatum.isBlank() -> vulAlleVeldenIn
                                geselecteerdeGemeente == null -> vulAlleVeldenIn
                                wachtwoord.length < 6 -> wachtwoordTeKort
                                wachtwoord != herhaalWachtwoord -> wachtwoordenNietOvereen
                                else -> null
                            }
                            if (validatieFout == null) {
                                viewModel.registreer(
                                    voornaam = voornaam,
                                    achternaam = achternaam,
                                    email = email,
                                    wachtwoord = wachtwoord,
                                    geboortedatum = geboortedatum,
                                    gemeenteId = geselecteerdeGemeente!!.id
                                )
                            }
                        }
                    )

                    Spacer(modifier = Modifier.height(spacerXS))

                    TextButton(
                        onClick = onTerug,
                        modifier = Modifier.align(Alignment.CenterHorizontally)
                    ) {
                        Text(
                            text = stringResource(R.string.terug_uppercase),
                            style = MaterialTheme.typography.labelMedium,
                            color = colorScheme.primary
                        )
                    }
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun GeboortedatumVeld(
    geboortedatum: String,
    onDatumGekozen: (String) -> Unit
) {
    var toonDatePicker by remember { mutableStateOf(false) }
    val datePickerState = rememberDatePickerState()

    if (toonDatePicker) {
        DatePickerDialog(
            onDismissRequest = { toonDatePicker = false },
            confirmButton = {
                TextButton(onClick = {
                    datePickerState.selectedDateMillis?.let { millis ->
                        val cal = Calendar.getInstance(TimeZone.getTimeZone("UTC"))
                        cal.timeInMillis = millis
                        onDatumGekozen(
                            String.format(
                                "%04d-%02d-%02d",
                                cal.get(Calendar.YEAR),
                                cal.get(Calendar.MONTH) + 1,
                                cal.get(Calendar.DAY_OF_MONTH)
                            )
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

    Text(text = stringResource(R.string.geboortedatum))
    OutlinedTextField(
        value = geboortedatum,
        onValueChange = {},
        readOnly = true,
        placeholder = {
            Text(
                text = stringResource(R.string.datum_placeholder),
                style = MaterialTheme.typography.bodyMedium,
                color = colorScheme.onSurface.copy(alpha = 0.35f)
            )
        },
        trailingIcon = {
            IconButton(onClick = { toonDatePicker = true }) {
                Icon(
                    imageVector = Icons.Default.CalendarMonth,
                    contentDescription = stringResource(R.string.kies_datum)
                )
            }
        },
        shape = MaterialTheme.shapes.small,
        modifier = Modifier.fillMaxWidth()
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun GemeenteVeld(
    gemeentes: List<Gemeente>,
    geselecteerdeGemeente: Gemeente?,
    onGemeenteGekozen: (Gemeente) -> Unit
) {
    var expanded by remember { mutableStateOf(false) }
    var zoekterm by remember { mutableStateOf("") }
    val gefilterdeGemeentes = gemeentes
        .filter { it.naam.startsWith(zoekterm, ignoreCase = true) }
        .take(5)

    Text(text = stringResource(R.string.gemeente))
    ExposedDropdownMenuBox(
        expanded = expanded,
        onExpandedChange = { expanded = zoekterm.isNotEmpty() && it }
    ) {
        OutlinedTextField(
            value = zoekterm,
            onValueChange = {
                zoekterm = it
                if (geselecteerdeGemeente != null) onGemeenteGekozen(geselecteerdeGemeente)
                expanded = it.isNotEmpty()
            },
            placeholder = {
                Text(
                    text = stringResource(R.string.zoek_gemeente),
                    style = MaterialTheme.typography.bodyMedium,
                    color = colorScheme.onSurface.copy(alpha = 0.35f)
                )
            },
            trailingIcon = {
                ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded)
            },
            shape = MaterialTheme.shapes.small,
            modifier = Modifier
                .fillMaxWidth()
                .menuAnchor(MenuAnchorType.PrimaryEditable)
        )
        ExposedDropdownMenu(
            expanded = expanded && gefilterdeGemeentes.isNotEmpty(),
            onDismissRequest = { expanded = false }
        ) {
            gefilterdeGemeentes.forEach { gemeente ->
                DropdownMenuItem(
                    text = { Text(gemeente.naam) },
                    onClick = {
                        onGemeenteGekozen(gemeente)
                        zoekterm = gemeente.naam
                        expanded = false
                    }
                )
            }
        }
    }
}

@Composable
private fun RegistratieVeld(
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String,
    text: String,
    visualTransformation: VisualTransformation = VisualTransformation.None,
) {
    Text(text = text)
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        placeholder = {
            Text(
                text = placeholder,
                style = MaterialTheme.typography.bodyMedium,
                color = colorScheme.onSurface.copy(alpha = 0.35f)
            )
        },
        visualTransformation = visualTransformation,
        shape = MaterialTheme.shapes.small,
        modifier = Modifier.fillMaxWidth()
    )
}

@Composable
private fun RegistreerKlantKnop(
    uiState: UiState,
    onClick: () -> Unit
) {
    Button(
        onClick = onClick,
        enabled = uiState !is UiState.Loading,
        modifier = Modifier.fillMaxWidth(),
        shape = MaterialTheme.shapes.medium,
        colors = ButtonDefaults.buttonColors(
            containerColor = colorScheme.primary,
            contentColor = colorScheme.onPrimary
        ),
        contentPadding = PaddingValues(vertical = buttonVerticalPadding)
    ) {
        if (uiState is UiState.Loading) {
            CircularProgressIndicator(
                color = colorScheme.onPrimary,
                strokeWidth = progressIndicatorStroke,
                modifier = Modifier.size(progressIndicatorSize)
            )
        } else {
            Text(
                text = stringResource(R.string.registreren_uppercase),
                style = MaterialTheme.typography.labelLarge
            )
        }
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun PreviewRegisterLightKlant() {

    PetNestTheme(darkTheme = false) {
        RegisterKlantScreen()
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun PreviewRegisterDarkKlant() {

    PetNestTheme(darkTheme = true) {
        RegisterKlantScreen()
    }
}