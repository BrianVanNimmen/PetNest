package be.brianvannimmen.petnest.ui.state

import be.brianvannimmen.petnest.network.Huisdier

data class HuisdierenUiState(
    val dieren: List<Huisdier> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null
)
