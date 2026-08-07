package be.brianvannimmen.petnest.ui.Screens.Klant

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
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
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import be.brianvannimmen.petnest.R
import be.brianvannimmen.petnest.network.Afspraak
import be.brianvannimmen.petnest.network.UserSession
import be.brianvannimmen.petnest.ui.klantViewmodel.HomeViewModel
import be.brianvannimmen.petnest.ui.theme.LocalExtendedColors
import be.brianvannimmen.petnest.ui.theme.PetNestTheme
import be.brianvannimmen.petnest.ui.theme.buttonHorizontalPadding
import be.brianvannimmen.petnest.ui.theme.buttonWidth
import be.brianvannimmen.petnest.ui.theme.cardElevationHigh
import be.brianvannimmen.petnest.ui.theme.cardElevationLow
import be.brianvannimmen.petnest.ui.theme.cardPaddingSmall
import be.brianvannimmen.petnest.ui.theme.contentHorizontalPadding
import be.brianvannimmen.petnest.ui.theme.logoSize
import be.brianvannimmen.petnest.ui.theme.screenHorizontalPadding
import be.brianvannimmen.petnest.ui.theme.spacerL
import be.brianvannimmen.petnest.ui.theme.spacerM
import be.brianvannimmen.petnest.ui.theme.spacerS
import be.brianvannimmen.petnest.ui.theme.spacerXL
import be.brianvannimmen.petnest.ui.theme.spacerXS
import be.brianvannimmen.petnest.ui.theme.spacerXXL


@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun KlantHomeScreen(
    viewModel: HomeViewModel = remember { HomeViewModel() },
    onAllAfsprakenClick: () -> Unit,
    onLogout: () -> Unit,
    onAccessibility: () -> Unit = {},
    onTabSelected: (KlantTab) -> Unit = {}
) {
    val klantId = UserSession.id
    val klantNaam = UserSession.fullName
    val afspraken = viewModel.afspraken
    val isLoading = viewModel.isLoading

    var reminders by remember { mutableStateOf(listOf<String>()) }
    var newReminder by remember { mutableStateOf("") }

    LaunchedEffect(klantId) {
        if (klantId != null) {
            viewModel.loadAfspraken(klantId)
        }
    }

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
                    TextButton(onClick = {
                        UserSession.clear()
                        onLogout()
                    }) {
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
            KlantBottomBar(
                selectedTab = KlantTab.Home,
                onTabSelected = onTabSelected
            )
        }
    ) { innerPadding ->

        Column(
            modifier = Modifier
                .padding(innerPadding)
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(contentHorizontalPadding),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            AppLogo()

            WelkomKlantText(klantNaam)

            Spacer(Modifier.height(spacerL))

            AfsprakenCard(
                afspraken = afspraken,
                isLoading = isLoading,
                onClickAll = onAllAfsprakenClick
            )

            Spacer(Modifier.height(spacerXL))

            RemindersCard(
                reminders = reminders,
                newReminder = newReminder,
                onReminderChange = { newReminder = it },
                onAdd = {
                    if (newReminder.isNotBlank() && reminders.size < 3) {
                        reminders = listOf(newReminder) + reminders.take(2)
                        newReminder = ""
                    }
                },
                onRemove = { index ->
                    reminders = reminders.toMutableList().also { it.removeAt(index) }
                }
            )
        }
    }
}

@Composable
fun WelkomKlantText(naam: String) {
    Row(modifier = Modifier.padding(top = spacerS, bottom = spacerXXL)) {
        Text(text = stringResource(R.string.welkom), style = MaterialTheme.typography.bodyMedium, color = colorScheme.primary)
        Text(
            text = naam,
            style = MaterialTheme.typography.bodyMedium,
            color = colorScheme.primary,
            fontWeight = FontWeight.SemiBold
        )
    }
}

@Composable
fun AppLogo() {
    Box(
        modifier = Modifier
            .padding(top = spacerXXL, bottom = spacerM)
            .size(logoSize)
            .clip(CircleShape)
            .background(colorScheme.primaryContainer),
        contentAlignment = Alignment.Center
    ) {
        Image(
            painter = painterResource(R.drawable.petnest_logo),
            contentDescription = stringResource(R.string.petnest_logo)
        )
    }
}

// Appbar
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PetNestAppBar(
    title: String = "",
    onBack: (() -> Unit)? = null,
    onLogout: (() -> Unit)? = null
    ) {
    val extended = LocalExtendedColors.current
    Column {
        CenterAlignedTopAppBar(
            title = { Text(title) },
            navigationIcon = {
                if (onBack != null) {
                    IconButton(onClick = onBack) {
                        Icon(
                            imageVector = Icons.Default.ArrowBack,
                            contentDescription = stringResource(R.string.terug),
                            tint = extended.topBar.onColor
                        )
                    }
                }
            },
            actions = {
                if (onLogout != null) {
                    TextButton(onClick = onLogout) {
                        Text(stringResource(R.string.afmelden), color = extended.topBar.onColor)
                    }
                }
            },
            colors = TopAppBarDefaults.centerAlignedTopAppBarColors(
                containerColor = extended.topBar.color,
                titleContentColor = extended.topBar.onColor
            )
        )
    }
}

@Composable
fun AfsprakenCard(
    afspraken: List<Afspraak>,
    isLoading: Boolean,
    onClickAll: () -> Unit
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
                text = stringResource(R.string.mijn_afspraken),
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
                afspraken.isEmpty() -> {
                    Text(
                        text = stringResource(R.string.geen_geplande_afspraken),
                        style = MaterialTheme.typography.bodySmall,
                        fontStyle = FontStyle.Italic,
                        color = colorScheme.onSurface.copy(alpha = 0.45f),
                        modifier = Modifier.padding(vertical = spacerM)
                    )
                }
                else -> {
                    afspraken.take(3).forEach {
                        AfspraakRij(afspraak = it)
                    }
                }
            }

            Button(
                onClick = onClickAll,
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
                    text = stringResource(R.string.alle_afspraken_bekijken),
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

@Composable
fun AfspraakRij(afspraak: Afspraak) {
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
                    text = "${afspraak.datum}  ·  $tijdstip",
                    style = MaterialTheme.typography.bodySmall,
                    color = colorScheme.onSurface.copy(alpha = 0.6f)
                )
            }
            AfspraakTypeBadge(type = afspraak.type)
        }
    }
}

@Composable
fun AfspraakTypeBadge(type: String) {
    val isDonker = type.equals("Operatie", ignoreCase = true)
    val achtergrond = if (isDonker) colorScheme.primary else colorScheme.primaryContainer
    val tekstKleur = if (isDonker) colorScheme.onPrimary else colorScheme.onPrimaryContainer

    Box(
        modifier = Modifier
            .clip(CircleShape)
            .background(achtergrond)
            .padding(horizontal = spacerM, vertical = spacerXS),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = type,
            style = MaterialTheme.typography.labelSmall,
            color = tekstKleur,
            fontWeight = FontWeight.SemiBold
        )
    }
}

@Composable
fun RemindersCard(
    reminders: List<String>,
    newReminder: String,
    onReminderChange: (String) -> Unit,
    onAdd: () -> Unit,
    onRemove: (Int) -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = MaterialTheme.shapes.large,
        colors = CardDefaults.cardColors(containerColor = colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = cardElevationHigh)
    ) {
        Column(modifier = Modifier.padding(cardPaddingSmall)) {
            Text(
                text = stringResource(R.string.mijn_herinneringen),
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.onSurface
            )
            Spacer(modifier = Modifier.height(spacerM))
            Row {
                TextField(
                    value = newReminder,
                    onValueChange = onReminderChange,
                    modifier = Modifier.weight(1f),
                    placeholder = {
                        Text(
                            stringResource(R.string.nieuwe_reminder),
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    },
                    colors = TextFieldDefaults.colors(
                        focusedContainerColor = MaterialTheme.colorScheme.surfaceContainer,
                        unfocusedContainerColor = MaterialTheme.colorScheme.surfaceContainer,
                        focusedTextColor = MaterialTheme.colorScheme.onSurface,
                        unfocusedTextColor = MaterialTheme.colorScheme.onSurface,
                        cursorColor = MaterialTheme.colorScheme.primary
                    )
                )
                Spacer(modifier = Modifier.width(spacerM))
                Button(
                    onClick = onAdd,
                    enabled = newReminder.isNotBlank() && reminders.size < 3,
                    shape = MaterialTheme.shapes.medium,
                    colors = ButtonDefaults.buttonColors(
                        containerColor = MaterialTheme.colorScheme.primary,
                        contentColor = MaterialTheme.colorScheme.onPrimary
                    )
                ) {
                    Text(stringResource(R.string.toevoegen), style = MaterialTheme.typography.bodyMedium)
                }
            }
            Spacer(modifier = Modifier.height(spacerM))
            if (reminders.isEmpty()) {
                Text(
                    stringResource(R.string.geen_herinneringen),
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            } else {
                LazyColumn(modifier = Modifier.heightIn(max = 200.dp)) {
                    items(reminders.size) { index ->
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = spacerXS),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(reminders[index], color = MaterialTheme.colorScheme.onSurface)
                            TextButton(onClick = { onRemove(index) }) {
                                Text(stringResource(R.string.verwijder), color = MaterialTheme.colorScheme.primary)
                            }
                        }
                    }
                }
            }
        }
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun HomeScreenLightPreview() {
    PetNestTheme(darkTheme = false) {
        KlantHomeScreen(
            onAllAfsprakenClick = {},
            onLogout = {},
            onTabSelected = {}
        )
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun HomeScreenDarkPreview() {
    PetNestTheme(darkTheme = true) {
        KlantHomeScreen(
            onAllAfsprakenClick = {},
            onLogout = {},
            onTabSelected = {}
        )
    }
}
