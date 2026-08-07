package be.brianvannimmen.petnest.ui.Screens.Shared
import be.brianvannimmen.petnest.ui.theme.*

import android.net.Uri
import android.provider.OpenableColumns
import android.util.Patterns
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.MaterialTheme.colorScheme
import androidx.compose.material3.MenuAnchorType
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.tooling.preview.Preview
import be.brianvannimmen.petnest.R
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewmodel.compose.viewModel
import be.brianvannimmen.petnest.network.Gemeente
import be.brianvannimmen.petnest.ui.sharedViewmodel.RegisterArtsViewModel
import be.brianvannimmen.petnest.ui.sharedViewmodel.UiState

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RegisterArtsScreen(
    onTerug: () -> Unit = {},
    onRegistratieSucces: () -> Unit = {},
    viewModel: RegisterArtsViewModel = viewModel(
        factory = ViewModelProvider.AndroidViewModelFactory(
            LocalContext.current.applicationContext as android.app.Application
        )
    )
) {
    LaunchedEffect(viewModel.uiState) {
        if (viewModel.uiState is UiState.Success) onRegistratieSucces()
    }

    var voornaam by remember { mutableStateOf("") }
    var achternaam by remember { mutableStateOf("") }
    var email by remember { mutableStateOf("") }
    var wachtwoord by remember { mutableStateOf("") }
    var herhaalWachtwoord by remember { mutableStateOf("") }
    var telefoon by remember { mutableStateOf("") }
    var praktijknaam by remember { mutableStateOf("") }
    var geselecteerdeGemeente by remember { mutableStateOf<Gemeente?>(null) }
    var certificaatUri by remember { mutableStateOf<Uri?>(null) }
    val defaultBestandsnaam = stringResource(R.string.geen_bestand_gekozen)
    var certificaatNaam by remember { mutableStateOf(defaultBestandsnaam) }
    var validatieFout by remember { mutableStateOf<String?>(null) }

    val vulAlleVeldenIn = stringResource(R.string.vul_alle_velden_in)
    val vulGeldigeEmail = stringResource(R.string.vul_geldige_email_in)
    val uploadCertificaat = stringResource(R.string.upload_certificaat)
    val wachtwoordTeKort = stringResource(R.string.wachtwoord_te_kort)
    val wachtwoordenNietOvereen = stringResource(R.string.wachtwoorden_komen_niet_overeen)

    val gemeentes = viewModel.gemeentes
    val gemeentesLaadfout = viewModel.gemeentesLaadfout

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(colorScheme.background)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = screenHorizontalPadding),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {

            Spacer(modifier = Modifier.height(spacerTop))

            Text(
                text = stringResource(R.string.artsenregistratie),
                style = MaterialTheme.typography.headlineSmall,
                color = colorScheme.onBackground
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

                    GemeenteVeld(
                        gemeentes = gemeentes,
                        geselecteerdeGemeente = geselecteerdeGemeente,
                        laadfout = gemeentesLaadfout,
                        onGemeenteGekozen = { geselecteerdeGemeente = it }
                    )

                    Spacer(modifier = Modifier.height(spacerFormField))

                    RegistratieVeld(
                        value = telefoon,
                        onValueChange = { telefoon = it },
                        placeholder = stringResource(R.string.placeholder_telefoon),
                        text = stringResource(R.string.telefoon)
                    )
                    Spacer(modifier = Modifier.height(spacerFormField))

                    RegistratieVeld(
                        value = praktijknaam,
                        onValueChange = { praktijknaam = it },
                        placeholder = stringResource(R.string.placeholder_praktijknaam),
                        text = stringResource(R.string.praktijknaam)
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
                    Spacer(modifier = Modifier.height(spacerFormField))

                    validatieFout?.let {
                        Text(text = it, color = colorScheme.error, style = MaterialTheme.typography.labelMedium)
                        Spacer(modifier = Modifier.height(spacerXS))
                    }
                    Spacer(modifier = Modifier.height(spacerFormField))

                    CertificaatPicker(
                        bestandsnaam = certificaatNaam,
                        onBestandGekozen = { uri, naam ->
                            certificaatUri = uri
                            certificaatNaam = naam
                        }
                    )

                    Spacer(modifier = Modifier.height(spacerXXL))

                    val uiState = viewModel.uiState
                    if (uiState is UiState.Error) {
                        Text(
                            text = uiState.message,
                            color = colorScheme.error,
                            style = MaterialTheme.typography.bodySmall,
                            modifier = Modifier.padding(bottom = spacerM)
                        )
                    }

                    RegistreerArtsKnop(
                        uiState = uiState,
                        onClick = {
                            validatieFout = when {
                                voornaam.isBlank() -> vulAlleVeldenIn
                                achternaam.isBlank() -> vulAlleVeldenIn
                                email.isBlank() -> vulAlleVeldenIn
                                !Patterns.EMAIL_ADDRESS.matcher(email.trim()).matches() -> vulGeldigeEmail
                                geselecteerdeGemeente == null -> vulAlleVeldenIn
                                telefoon.isBlank() -> vulAlleVeldenIn
                                praktijknaam.isBlank() -> vulAlleVeldenIn
                                certificaatUri == null -> uploadCertificaat
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
                                    gemeenteId = geselecteerdeGemeente!!.id,
                                    telefoon = telefoon,
                                    praktijknaam = praktijknaam,
                                    certificaatUri = certificaatUri!!
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

            Spacer(modifier = Modifier.height(spacerXXXL + spacerM))
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

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun GemeenteVeld(
    gemeentes: List<Gemeente>,
    geselecteerdeGemeente: Gemeente?,
    laadfout: String?,
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
        onExpandedChange = { expanded = it }
    ) {
        OutlinedTextField(
            value = zoekterm,
            onValueChange = {
                zoekterm = it
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
            isError = laadfout != null,
            supportingText = laadfout?.let { { Text(it, color = colorScheme.error) } },
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
private fun CertificaatPicker(
    bestandsnaam: String,
    onBestandGekozen: (Uri, String) -> Unit
) {
    val context = LocalContext.current
    val launcher = rememberLauncherForActivityResult(
        ActivityResultContracts.GetContent()
    ) { uri ->
        if (uri == null) return@rememberLauncherForActivityResult
        val naam = context.contentResolver.query(uri, null, null, null, null)?.use { cursor ->
            val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            cursor.moveToFirst()
            cursor.getString(index)
        } ?: uri.lastPathSegment ?: "certificaat"
        onBestandGekozen(uri, naam)
    }

    Text(text = stringResource(R.string.certificaat_label))
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .weight(1f)
                .border(
                    width = borderWidth,
                    color = colorScheme.outline,
                    shape = MaterialTheme.shapes.small
                )
                .padding(horizontal = buttonHorizontalPadding, vertical = spacerL)
        ) {
            Text(
                text = bestandsnaam,
                style = MaterialTheme.typography.bodySmall,
                color = colorScheme.onSurface.copy(alpha = 0.45f)
            )
        }
        Spacer(modifier = Modifier.width(spacerFormField))
        Button(
            onClick = { launcher.launch("*/*") },
            shape = MaterialTheme.shapes.small,
            colors = ButtonDefaults.buttonColors(
                containerColor = colorScheme.primary,
                contentColor = colorScheme.onPrimary
            ),
            contentPadding = PaddingValues(
                horizontal = buttonHorizontalPadding,
                vertical = buttonVerticalPadding
            )
        ) {
            Text(
                text = stringResource(R.string.kiezen),
                style = MaterialTheme.typography.bodySmall,
                fontWeight = FontWeight.SemiBold
            )
        }
    }
}

@Composable
private fun RegistreerArtsKnop(
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
fun RegisterArtsLightScreenPreview() {
    PetNestTheme(darkTheme = false){
        RegisterArtsScreen()
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun RegisterArtsDarkScreenPreview() {
    PetNestTheme(darkTheme = true) {
        RegisterArtsScreen()
    }
}