package be.brianvannimmen.petnest.ui.Screens.Shared
import be.brianvannimmen.petnest.ui.theme.*

import android.util.Log
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.statusBarsPadding
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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.MaterialTheme.colorScheme
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
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.tooling.preview.Preview
import androidx.lifecycle.viewmodel.compose.viewModel
import be.brianvannimmen.petnest.R
import be.brianvannimmen.petnest.ui.sharedViewmodel.LoginUiState
import be.brianvannimmen.petnest.ui.sharedViewmodel.LoginViewModel


@Composable
fun LoginScreen(
    onMaakAccount: () -> Unit = {},
    onKlantLogin: () -> Unit = {},
    onArtsLogin: (Int) -> Unit = {},
    onAccessibility: () -> Unit = {},
    viewModel: LoginViewModel = viewModel()
) {
    var email by remember { mutableStateOf("") }
    var wachtwoord by remember { mutableStateOf("") }

    val uiState = viewModel.uiState

    LaunchedEffect(uiState) {
        when (uiState) {
            is LoginUiState.KlantIngelogd -> onKlantLogin()
            is LoginUiState.ArtsIngelogd -> onArtsLogin(uiState.dierenArtsId)
            else -> Unit
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(colorScheme.background)
    ) {
        IconButton(
            onClick = onAccessibility,
            modifier = Modifier
                .align(Alignment.TopStart)
                .statusBarsPadding()
        ) {
            Icon(
                imageVector = Icons.Default.Settings,
                contentDescription = stringResource(R.string.toegankelijkheid),
                tint = colorScheme.primary
            )
        }

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = screenHorizontalPadding),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(spacerTopLarge))

            Image(
                painter = painterResource(R.drawable.petnest_logo),
                contentDescription = stringResource(R.string.petnest_logo),
                contentScale = ContentScale.Crop,
                modifier = Modifier
                    .size(logoSize)
                    .clip(CircleShape)
            )

            Spacer(modifier = Modifier.height(spacerXXXL))

            Text(
                text = stringResource(R.string.inloggen),
                style = MaterialTheme.typography.headlineMedium
            )

            Spacer(modifier = Modifier.height(spacerS))

            Text(
                text = stringResource(R.string.ben_je_een_arts_of_baasje),
                style = MaterialTheme.typography.bodyMedium
            )

            Spacer(modifier = Modifier.height(spacerXXXL))

            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = MaterialTheme.shapes.large,
                colors = CardDefaults.cardColors(containerColor = colorScheme.surface),
                elevation = CardDefaults.cardElevation(defaultElevation = cardElevationDefault)
            ) {
                Column(modifier = Modifier.padding(cardPadding)) {

                    LoginVeld(
                        value = email,
                        onValueChange = { email = it },
                        placeholder = stringResource(R.string.hello_gmail_com),
                        text = stringResource(R.string.email)
                    )

                    Spacer(modifier = Modifier.height(spacerL))

                    LoginVeld(
                        value = wachtwoord,
                        onValueChange = { wachtwoord = it },
                        placeholder = stringResource(R.string.voer_je_wachtwoord_in),
                        text = stringResource(R.string.wachtwoord),
                        isWachtwoord = true
                    )

                    if (uiState is LoginUiState.Error) {
                        Spacer(modifier = Modifier.height(spacerM))
                        Text(
                            text = uiState.message,
                            color = colorScheme.error,
                            style = MaterialTheme.typography.labelMedium
                        )
                    }

                    Spacer(modifier = Modifier.height(spacerXXL))

                    Button(
                        onClick = { viewModel.login(email, wachtwoord) },
                        enabled = uiState !is LoginUiState.Loading,
                        modifier = Modifier.fillMaxWidth(),
                        shape = MaterialTheme.shapes.medium,
                        colors = ButtonDefaults.buttonColors(
                            containerColor = colorScheme.primary,
                            contentColor = colorScheme.onPrimary
                        ),
                        contentPadding = PaddingValues(vertical = buttonVerticalPadding)
                    ) {
                        if (uiState is LoginUiState.Loading) {
                            CircularProgressIndicator(
                                color = colorScheme.onPrimary,
                                strokeWidth = progressIndicatorStroke,
                                modifier = Modifier.size(progressIndicatorSize)
                            )
                        } else {
                            Text(
                                text = stringResource(R.string.inloggen),
                                style = MaterialTheme.typography.labelLarge
                            )
                        }
                    }

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = stringResource(R.string.nog_geen_account),
                            style = MaterialTheme.typography.labelMedium
                        )
                        TextButton(onClick = onMaakAccount) {
                            Text(
                                text = stringResource(R.string.maak_een_account_aan),
                                style = MaterialTheme.typography.labelMedium,
                                color = colorScheme.primary
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun LoginVeld(
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String,
    text: String,
    isWachtwoord: Boolean = false,
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
        visualTransformation = if (isWachtwoord) PasswordVisualTransformation() else androidx.compose.ui.text.input.VisualTransformation.None,
        shape = MaterialTheme.shapes.small,
        modifier = Modifier.fillMaxWidth()
    )
}
