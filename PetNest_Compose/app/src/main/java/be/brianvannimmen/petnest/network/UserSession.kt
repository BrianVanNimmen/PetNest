package be.brianvannimmen.petnest.network

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue

object UserSession {
    var id: Int? = null
    var dierenArtsId: Int? = null
    var voornaam: String? = null
    var achternaam: String? = null
    var type: String? = null

    val fullName: String
        get() = listOfNotNull(
            voornaam?.trim()?.takeIf { it.isNotBlank() },
            achternaam?.trim()?.takeIf { it.isNotBlank() }
        ).joinToString(" ")
            .ifBlank { "Gast" }

    fun clear() {
        id = null
        dierenArtsId = null
        voornaam = null
        achternaam = null
        type = null
    }
}
