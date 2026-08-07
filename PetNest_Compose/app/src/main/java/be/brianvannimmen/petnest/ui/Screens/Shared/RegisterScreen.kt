package be.brianvannimmen.petnest.ui.Screens.Shared
import be.brianvannimmen.petnest.ui.theme.*

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.MaterialTheme.colorScheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import be.brianvannimmen.petnest.R


@Composable
private fun RegisterKeuzeButton(
    tekst: String,
    onClick: () -> Unit,
) {
    Button(
        onClick = onClick,
        modifier = Modifier
            .fillMaxWidth()
            .border(borderWidth, colorScheme.primary, MaterialTheme.shapes.medium),
        colors = ButtonDefaults.buttonColors(
            containerColor = colorScheme.surface,
            contentColor = colorScheme.primary
        ),
    ) {
        Text(
            text = tekst,
            style = MaterialTheme.typography.labelLarge
        )
    }
}

@Composable
fun RegisterScreen(
    onRegisterArts: () -> Unit = {},
    onRegisterKlant: () -> Unit = {},
    onTerug: () -> Unit = {}
) {
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
                text = stringResource(R.string.registreren),
                style = MaterialTheme.typography.headlineMedium,
                color = colorScheme.onBackground
            )

            Spacer(modifier = Modifier.height(spacerS))

            Text(
                text = stringResource(R.string.kies_accounttype),
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

                    RegisterKeuzeButton(tekst = stringResource(R.string.register_als_arts), onClick = onRegisterArts)

                    Spacer(modifier = Modifier.height(spacerL))

                    RegisterKeuzeButton(tekst = stringResource(R.string.register_als_klant), onClick = onRegisterKlant)

                    Spacer(modifier = Modifier.height(spacerXS))

                    TextButton(
                        onClick = onTerug,
                        modifier = Modifier.align(Alignment.CenterHorizontally)
                    ) {
                        Text(
                            text = stringResource(R.string.terug_naar_login),
                            style = MaterialTheme.typography.labelMedium,
                            color = colorScheme.onSurface.copy(alpha = 0.55f)
                        )
                    }
                }
            }
        }
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun RegisterScreenPreview() {
    PetNestTheme(dynamicColor = false) {
        RegisterScreen()
    }
}