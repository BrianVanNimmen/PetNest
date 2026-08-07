package be.brianvannimmen.petnest.ui.state

import be.brianvannimmen.petnest.network.Afspraak

data class HomeUiState(
    val klantNaam: String = "Gast",
    val afspraken: List<Afspraak> = emptyList(),
    val reminders: List<String> = emptyList(),
    val isLoading: Boolean = false
)
