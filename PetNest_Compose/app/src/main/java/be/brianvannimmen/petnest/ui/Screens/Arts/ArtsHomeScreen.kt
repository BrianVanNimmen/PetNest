package be.brianvannimmen.petnest.ui.Screens.Arts
import be.brianvannimmen.petnest.ui.theme.*

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Settings
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
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.tooling.preview.Preview
import androidx.lifecycle.viewmodel.compose.viewModel
import be.brianvannimmen.petnest.R
import be.brianvannimmen.petnest.network.Afspraak
import be.brianvannimmen.petnest.ui.artsViewmodel.ArtsHomeViewModel


@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ArtsHomeScreen(
    onTabSelected: (ArtsTab) -> Unit = {},
    onLogout: () -> Unit = {},
    onAccessibility: () -> Unit = {},
    onConsultaties: () -> Unit = {},
    viewModel: ArtsHomeViewModel = viewModel()
) {
    val extended = LocalExtendedColors.current

    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = { },
                navigationIcon = {
                    IconButton(onClick = onAccessibility) {
                        Icon(
                            imageVector = Icons.Default.Settings,
                            contentDescription = stringResource(R.string.toegankelijkheid),
                            tint = extended.topBar.onColor
                        )
                    }
                },
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
                selectedTab = ArtsTab.Home,
                onTabSelected = onTabSelected
            )
        }
    ) { innerPadding ->
        Box(Modifier.padding(innerPadding)) {
            ArtsHomeContent(
                artsNaam = viewModel.artsNaam,
                afspraken = viewModel.afspraken,
                isLoading = viewModel.isLoading,
                error = viewModel.error,
                onConsultaties = onConsultaties
            )
        }
    }
}

@Composable
private fun ArtsHomeContent(
    artsNaam: String = "",
    afspraken: List<Afspraak> = emptyList(),
    isLoading: Boolean = false,
    error: String? = null,
    onConsultaties: () -> Unit = {}
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(contentHorizontalPadding),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Image(
            painter = painterResource(R.drawable.petnest_logo),
            contentDescription = stringResource(R.string.petnest_logo),
            contentScale = ContentScale.Crop,
            modifier = Modifier
                .padding(top = spacerXXL, bottom = spacerM)
                .size(logoSize)
                .clip(CircleShape)
        )
        welkomText(artsNaam)
        consultationCard(
            afspraken = afspraken,
            isLoading = isLoading,
            error = error,
            onConsultaties = onConsultaties
        )
    }
}

@Composable
fun welkomText(artsNaam: String = "Arts") {
    val welkomDr = stringResource(R.string.welkom_dr)
    Text(
        text = buildAnnotatedString {
            append(welkomDr)
            withStyle(SpanStyle(fontWeight = FontWeight.SemiBold)) { append(artsNaam) }
        },
        style = MaterialTheme.typography.bodyMedium,
        color = colorScheme.primary,
        modifier = Modifier.padding(top = spacerS, bottom = spacerXL + spacerS)
    )
}

@Composable
fun consultationCard(
    afspraken: List<Afspraak> = emptyList(),
    isLoading: Boolean = false,
    error: String? = null,
    onConsultaties: () -> Unit = {}
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = screenHorizontalPadding),
        shape = MaterialTheme.shapes.large,
        colors = CardDefaults.cardColors(containerColor = colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = cardElevationHigh)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(cardPaddingSmall),
            verticalArrangement = Arrangement.spacedBy(spacerM)
        ) {
            Text(
                text = stringResource(R.string.mijn_consultaties_vandaag),
                style = MaterialTheme.typography.titleMedium,
                color = colorScheme.onSurface
            )

            when {
                isLoading -> {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = spacerXL),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator()
                    }
                }
                error != null -> {
                    Text(
                        text = error,
                        color = colorScheme.error,
                        style = MaterialTheme.typography.bodySmall
                    )
                }
                afspraken.isEmpty() -> {
                    Text(
                        text = stringResource(R.string.geen_consultaties_vandaag),
                        style = MaterialTheme.typography.bodySmall,
                        fontStyle = FontStyle.Italic,
                        color = colorScheme.onSurface.copy(alpha = 0.45f),
                        modifier = Modifier.padding(vertical = spacerM)
                    )
                }
                else -> {
                    afspraken.take(3).forEach { afspraak ->
                        ConsultatieRij(afspraak = afspraak)
                    }
                }
            }

            Button(
                onClick = onConsultaties,
                modifier = Modifier
                    .width(buttonWidth)
                    .align(Alignment.CenterHorizontally),
                shape = MaterialTheme.shapes.medium,
                colors = ButtonDefaults.buttonColors(
                    containerColor = colorScheme.primary,
                    contentColor = colorScheme.onPrimary
                ),
                contentPadding = PaddingValues(vertical = spacerL)
            ) {
                Text(
                    text = stringResource(R.string.alle_consultaties_bekijken),
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun ArtsHomeLightScreenPreview() {
    PetNestTheme(darkTheme = false) {
        ArtsHomeScreen()
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun ArtsHomeDarkScreenPreview() {
    PetNestTheme(darkTheme = true) {
        ArtsHomeScreen()
    }
}
