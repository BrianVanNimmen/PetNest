package be.brianvannimmen.petnest.ui.Screens.Klant
import be.brianvannimmen.petnest.ui.theme.*

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import coil.compose.rememberAsyncImagePainter
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CenterAlignedTopAppBar
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBarDefaults
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import be.brianvannimmen.petnest.R
import be.brianvannimmen.petnest.network.Huisdier
import be.brianvannimmen.petnest.network.RetrofitClient
import be.brianvannimmen.petnest.ui.klantViewmodel.HuisdierenViewModel

private fun fotoUrl(raw: String?): Any =
    if (raw != null && !raw.startsWith("http")) RetrofitClient.BASE_URL + raw
    else raw ?: R.drawable.default_dier

@Composable
fun HuisdierenRoute(
    viewModel: HuisdierenViewModel = viewModel(),
    onAddClick: () -> Unit = {},
    onEdit: (Int) -> Unit = {},
    onMedisch: (Int) -> Unit = {},
    onLogout: () -> Unit = {},
    onTabSelected: (KlantTab) -> Unit = {}
) {

    val uiState by viewModel.uiState.collectAsState()

    LaunchedEffect(Unit) {
        viewModel.refresh()
    }

    HuisdierenScreen(
        dieren = uiState.dieren,
        isLoading = uiState.isLoading,
        onAddClick = onAddClick,
        onEdit = onEdit,
        onMedisch = onMedisch,
        onLogout = onLogout,
        onTabSelected = onTabSelected
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HuisdierenScreen(
    dieren: List<Huisdier> = emptyList(),
    isLoading: Boolean = false,
    onAddClick: () -> Unit = {},
    onEdit: (Int) -> Unit = {},
    onMedisch: (Int) -> Unit = {},
    onLogout: () -> Unit = {},
    onTabSelected: (KlantTab) -> Unit = {}
) {

    val extended = LocalExtendedColors.current
    var selectedPet by remember { mutableStateOf<Huisdier?>(null) }

    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = {
                    Text(stringResource(R.string.huisdieren))
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
                selectedTab = KlantTab.Huisdieren,
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
                colors = ButtonDefaults.buttonColors(
                    containerColor = MaterialTheme.colorScheme.primary
                ),
                modifier = Modifier.align(Alignment.CenterHorizontally)
            ) {
                Text(stringResource(R.string.nieuw_huisdier), style = MaterialTheme.typography.bodyMedium)
            }

            Spacer(modifier = Modifier.height(spacerXL))

            LazyColumn(
                verticalArrangement = Arrangement.spacedBy(spacerL)
            ) {
                if (isLoading) {

                    items(3) {
                        PetSkeletonCard()
                    }

                } else {

                    if (dieren.isEmpty()) {
                        item {
                            Text(
                                text = stringResource(R.string.je_hebt_nog_geen_huisdieren),
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    } else {
                        items(dieren) { dier ->
                            PetCard(
                                dier = dier,
                                onClick = {
                                    selectedPet = dier
                                }
                            )
                        }
                    }
                }
            }
        }
    }

    selectedPet?.let { pet ->
        AlertDialog(
            onDismissRequest = {
                selectedPet = null
            },
            confirmButton = {
                Column {
                    Button(
                        onClick = {
                            selectedPet = null
                            onEdit(pet.id)
                        },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text(stringResource(R.string.bewerken))
                    }

                    Spacer(modifier = Modifier.height(8.dp))

                    Button(
                        onClick = {
                            selectedPet = null
                            onMedisch(pet.id)
                        },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text(stringResource(R.string.medisch_dossier))
                    }
                }
            },
            dismissButton = {
                TextButton(
                    onClick = { selectedPet = null }
                ) {
                    Text(stringResource(R.string.sluiten))
                }
            },
            title = {
                Text(
                    pet.naam,
                    modifier = Modifier.fillMaxWidth(),
                    textAlign = TextAlign.Center
                )
            },
            text = {
                Column(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Box(
                        modifier = Modifier
                            .size(petCardPhotoSize)
                            .clip(MaterialTheme.shapes.medium)
                            .background(MaterialTheme.colorScheme.surfaceVariant)
                    ) {
                        Image(
                            painter = rememberAsyncImagePainter(
                                model = fotoUrl(pet.fotoUrl),
                                error = painterResource(id = R.drawable.default_dier),
                                placeholder = painterResource(id = R.drawable.default_dier)
                            ),
                            contentDescription = null,
                            contentScale = ContentScale.Crop,
                            alignment = Alignment.Center,
                            modifier = Modifier.fillMaxSize()
                        )
                    }

                    Spacer(modifier = Modifier.height(spacerL))

                    Text(
                        text = stringResource(R.string.soort_label, pet.soort ?: stringResource(R.string.onbekend)),
                        style = MaterialTheme.typography.bodyMedium
                    )
                }
            }
        )
    }
}

@Composable
fun PetCard(
    dier: Huisdier,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable {
                onClick()
            },
        shape = MaterialTheme.shapes.large,
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceContainer
        )
    ) {
        Row(
            modifier = Modifier.padding(spacerL),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Image(
                painter = rememberAsyncImagePainter(
                    model = fotoUrl(dier.fotoUrl),
                    error = painterResource(id = R.drawable.default_dier),
                    placeholder = painterResource(id = R.drawable.default_dier)
                ),
                contentDescription = null,
                contentScale = ContentScale.Crop,
                modifier = Modifier
                    .size(petCardPhotoSize)
                    .clip(MaterialTheme.shapes.medium)
                    .background(MaterialTheme.colorScheme.surfaceVariant)
            )
            Spacer(modifier = Modifier.width(spacerXL))
            Column {
                Text(
                    text = dier.naam,
                    style = MaterialTheme.typography.bodyLarge,
                    color = MaterialTheme.colorScheme.onSurface
                )
                Text(
                    text = dier.soort ?: stringResource(R.string.onbekend),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

@Composable
fun PetSkeletonCard() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = MaterialTheme.shapes.large,
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceContainerLow
        )
    ) {
        Row(
            modifier = Modifier.padding(spacerL)
        ) {
            Box(
                modifier = Modifier
                    .size(petCardPhotoSize)
                    .background(Color.LightGray, MaterialTheme.shapes.medium)
            )
            Spacer(modifier = Modifier.width(spacerXL))
            Box(
                modifier = Modifier
                    .height(spacerXL)
                    .fillMaxWidth(0.5f)
                    .background(Color.LightGray, MaterialTheme.shapes.extraSmall)
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
fun HuisdierenScreenPreview() {

    val mockDieren = listOf(
        Huisdier(1, "Luna", "Hond", null),
        Huisdier(2, "Max", "Kat", null),
        Huisdier(3, "Bella", "Konijn", null)
    )

    PetNestTheme {
        HuisdierenScreen(
            dieren = mockDieren,
            isLoading = false
        )
    }
}