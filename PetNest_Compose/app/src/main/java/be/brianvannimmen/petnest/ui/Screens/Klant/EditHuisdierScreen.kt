package be.brianvannimmen.petnest.ui.Screens.Klant

import android.net.Uri
import android.util.Log
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
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
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
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.lifecycle.viewmodel.compose.viewModel
import be.brianvannimmen.petnest.R
import be.brianvannimmen.petnest.model.SimpleItem
import be.brianvannimmen.petnest.network.PetDto
import be.brianvannimmen.petnest.network.RetrofitClient
import be.brianvannimmen.petnest.ui.klantViewmodel.DierenartsViewModel
import be.brianvannimmen.petnest.ui.klantViewmodel.HuisdierenViewModel
import be.brianvannimmen.petnest.ui.theme.PetNestTheme
import be.brianvannimmen.petnest.ui.theme.contentHorizontalPadding
import be.brianvannimmen.petnest.ui.theme.photoPickerSize
import be.brianvannimmen.petnest.ui.theme.spacerL
import coil.compose.rememberAsyncImagePainter


@Composable
fun EditHuisdierRoute(
    petId: Int,
    huisdierenViewModel: HuisdierenViewModel = viewModel(),
    artsenViewModel: DierenartsViewModel = viewModel(),
    onBack: () -> Unit
) {
    val artsen by artsenViewModel.artsen.collectAsState()
    val dier = huisdierenViewModel.selectedPet.collectAsState().value

    LaunchedEffect(petId) {
        huisdierenViewModel.loadPetDetail(petId)
    }

    if (dier == null) return

    EditHuisdierScreen(
        dier = dier,
        artsen = artsen,
        onBack = onBack,
        onSave = { naam, ras, datum, arts, foto ->

            val artsId = arts?.id
            if (artsId == null) {
                Log.e("UPDATE", "Geen arts geselecteerd → update geannuleerd")
                return@EditHuisdierScreen
            }
            huisdierenViewModel.updateHuisdier(
                id = petId,
                naam = naam,
                soort = ras,
                geboortedatum = datum,
                artsId = artsId,
                fotoUri = foto
            )
            onBack()
        }
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditHuisdierScreen(
    dier: PetDto,
    artsen: List<SimpleItem>,
    onBack: () -> Unit,
    onSave: (String, String, String, SimpleItem?, Uri?) -> Unit
) {
    var naam by remember { mutableStateOf(dier.naam ?: "") }
    var ras by remember { mutableStateOf(dier.soort ?: "") }
    var geboortedatum by remember { mutableStateOf(dier.geboortedatum ?: "") }

    var selectedArts by remember(dier, artsen) {
        mutableStateOf(
            artsen.firstOrNull { it.id == dier.dierenartsId }
        )
    }

    var photo by remember { mutableStateOf<Uri?>(null) }

    Scaffold(
        topBar = {
            PetNestAppBar(
                title = stringResource(R.string.huisdier_bewerken),
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

            HuisdierFotoPicker(
                photo = photo,
                fallbackUrl = dier.fotoUrl,
                onPick = { photo = it }
            )

            HuisdierNaamVeld(
                value = naam,
                onChange = { naam = it }
            )

            HuisdierRasVeld(
                value = ras,
                onChange = { ras = it }
            )

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
                    onSave(naam, ras, geboortedatum, selectedArts, photo)
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
    fallbackUrl: String? = null,
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
        when {
            photo != null -> {
                Image(
                    painter = rememberAsyncImagePainter(photo),
                    contentDescription = stringResource(R.string.gekozen_foto),
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )
            }
            !fallbackUrl.isNullOrEmpty() -> {
                val imageUrl = if (!fallbackUrl.startsWith("http")) RetrofitClient.BASE_URL + fallbackUrl else fallbackUrl
                Image(
                    painter = rememberAsyncImagePainter(imageUrl),
                    contentDescription = stringResource(R.string.huidige_foto),
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )
            }
            else -> {
                Text(stringResource(R.string.foto))
            }
        }
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun EditHuisdierLightPreview() {

    val artsen = listOf(
        SimpleItem(1, "Dr. Jansen"),
        SimpleItem(2, "Dr. Peeters")
    )

    val dier = PetDto(
        id = 1,
        naam = "Bobby",
        soort = "Golden Retriever",
        geboortedatum = "2020-05-10",
        fotoUrl = null,
        dierenartsId = null
    )

    PetNestTheme(darkTheme = false) {
        EditHuisdierScreen(
            dier = dier,
            artsen = artsen,
            onBack = {},
            onSave = { _, _, _, _, _ -> }
        )
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun EditHuisdierDarkPreview() {

    val artsen = listOf(
        SimpleItem(1, "Dr. Jansen"),
        SimpleItem(2, "Dr. Peeters")
    )

    val dier = PetDto(
        id = 1,
        naam = "Bobby",
        soort = "Golden Retriever",
        geboortedatum = "2020-05-10",
        fotoUrl = null,
        dierenartsId = null
    )

    PetNestTheme(darkTheme = true) {
        EditHuisdierScreen(
            dier = dier,
            artsen = artsen,
            onBack = {},
            onSave = { _, _, _, _, _ -> }
        )
    }
}