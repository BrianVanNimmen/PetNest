package be.brianvannimmen.petnest.ui.Screens.Klant
import be.brianvannimmen.petnest.ui.theme.*

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import be.brianvannimmen.petnest.R
import be.brianvannimmen.petnest.network.Afspraak
import be.brianvannimmen.petnest.ui.klantViewmodel.AfspraakViewModel
import be.brianvannimmen.petnest.ui.klantViewmodel.DierenartsViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AfsprakenScreen(
    onAddClick: () -> Unit = {},
    onLogout: () -> Unit = {},
    onTabSelected: (KlantTab) -> Unit = {}
) {
    val afspraakViewModel: AfspraakViewModel = viewModel()
    val dierenartsViewModel: DierenartsViewModel = viewModel()
    val afspraken by afspraakViewModel.afspraken.collectAsState()
    val artsen by dierenartsViewModel.artsen.collectAsState()

    val extended = LocalExtendedColors.current
    var selected by remember { mutableStateOf<Afspraak?>(null) }
    var showConfirmDelete by remember { mutableStateOf(false) }

    LaunchedEffect(artsen) {
        if (artsen.isNotEmpty()) {
            afspraakViewModel.setArtsen(artsen)
        }
    }

    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = {
                    Text(stringResource(R.string.afspraken))
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
            KlantBottomBar(
                selectedTab = KlantTab.Afspraken,
                onTabSelected = onTabSelected
            )
        }
    ) { innerPadding ->

        Column(
            modifier = Modifier
                .padding(innerPadding)
                .fillMaxSize()
                .padding(contentHorizontalPadding)
        ) {

            Button(
                onClick = onAddClick,
                shape = CircleShape,
                modifier = Modifier.align(Alignment.CenterHorizontally)
            ) {
                Text(stringResource(R.string.nieuwe_afspraak), style = MaterialTheme.typography.bodyMedium)
            }

            Spacer(modifier = Modifier.height(spacerXL))

            LazyColumn(verticalArrangement = Arrangement.spacedBy(spacerL)) {

                if (afspraken.isEmpty()) {
                    item {
                        Text(stringResource(R.string.je_hebt_nog_geen_afspraken))
                    }
                } else {
                    items(afspraken) { afspraak ->
                        AfspraakCard(
                            afspraak = afspraak,
                            onClick = { selected = afspraak }
                        )
                    }
                }
            }
        }
    }

    if (showConfirmDelete) {
        AlertDialog(
            onDismissRequest = { showConfirmDelete = false },
            title = { Text(stringResource(R.string.afspraak_annuleren)) },
            text = { Text(stringResource(R.string.zeker_annuleren)) },
            confirmButton = {
                TextButton(
                    onClick = {
                        selected?.let { afspraakViewModel.deleteAfspraak(it.id) }
                        showConfirmDelete = false
                        selected = null
                    }
                ) {
                    Text(stringResource(R.string.ja_annuleren), color = MaterialTheme.colorScheme.error)
                }
            },

            dismissButton = {
                TextButton(onClick = { showConfirmDelete = false }) {
                    Text(stringResource(R.string.terug))
                }
            }
        )
    }

    selected?.let { a ->
        AlertDialog(
            onDismissRequest = { selected = null },
            confirmButton = {
                TextButton(onClick = { selected = null }) {
                    Text(stringResource(R.string.sluiten))
                }
            },
            dismissButton = {
                TextButton(onClick = { showConfirmDelete = true }) {
                    Text(stringResource(R.string.annuleren), color = MaterialTheme.colorScheme.error)
                }
            },
            title = {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = a.dier,
                        style = MaterialTheme.typography.titleLarge
                    )
                    TypeBadge(a.type)
                }
            },
            text = {
                Column(verticalArrangement = Arrangement.spacedBy(spacerL)) {

                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(1.dp)
                            .background(MaterialTheme.colorScheme.outlineVariant)
                    )

                    // Datum + tijd naast elkaar
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        DetailBlock(label = stringResource(R.string.datum_label), value = a.datum)
                        DetailBlock(label = stringResource(R.string.tijd_label), value = a.tijd)
                    }

                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(1.dp)
                            .background(MaterialTheme.colorScheme.outlineVariant)
                    )

                    DetailBlock(label = stringResource(R.string.dierenarts), value = a.arts.ifBlank { stringResource(R.string.onbekend) })
                }
            }
        )
    }
}

@Composable
fun AfspraakCard(
    afspraak: Afspraak,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() },
        shape = MaterialTheme.shapes.large,
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceContainer
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(cardPaddingSmall),
            verticalAlignment = Alignment.CenterVertically
        ) {

            Text(
                afspraak.dier,
                style = MaterialTheme.typography.bodyMedium,
                modifier = Modifier.weight(1f)
            )

            Text(
                afspraak.tijd,
                style = MaterialTheme.typography.bodySmall,
                modifier = Modifier.weight(1f),
                textAlign = TextAlign.Center
            )

            Box(
                modifier = Modifier.weight(1f),
                contentAlignment = Alignment.CenterEnd
            ) {
                TypeBadge(afspraak.type)
            }
        }
    }
}

@Composable
fun TypeBadge(type: String) {

    val (bg, textColor) = when (type.lowercase()) {
        "controle" -> Pair(
            MaterialTheme.colorScheme.tertiaryContainer,
            MaterialTheme.colorScheme.onTertiaryContainer
        )
        "vaccinatie" -> Pair(
            MaterialTheme.colorScheme.secondaryContainer,
            MaterialTheme.colorScheme.onSecondaryContainer
        )
        "operatie" -> Pair(
            MaterialTheme.colorScheme.primary,
            MaterialTheme.colorScheme.onPrimary
        )
        else -> Pair(
            MaterialTheme.colorScheme.surfaceVariant,
            MaterialTheme.colorScheme.onSurfaceVariant
        )
    }

    Box(
        modifier = Modifier
            .background(bg, MaterialTheme.shapes.medium)
            .padding(horizontal = badgeHorizontalPadding, vertical = badgeVerticalPadding)
    ) {
        Text(
            text = type,
            style = MaterialTheme.typography.labelSmall,
            color = textColor
        )
    }
}

@Composable
fun DetailBlock(label: String, value: String, icon: String = "") {
    Column {
        Text(
            text = "$icon $label".trim(),
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Text(
            text = value,
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurface
        )
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun AfsprakenScreenLightPreview() {
    PetNestTheme(darkTheme = false) {
        AfsprakenScreen(
            onAddClick = {},
            onLogout = {}
        )
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun AfsprakenScreenDarkPreview() {
    PetNestTheme(darkTheme = true) {
        AfsprakenScreen(
            onAddClick = {},
            onLogout = {}
        )
    }
}