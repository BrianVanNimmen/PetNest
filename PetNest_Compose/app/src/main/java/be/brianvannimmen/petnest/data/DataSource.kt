package be.brianvannimmen.petnest.data

/**
 * Data class voor een consultatie.
 * Komt later van de RESTFul API (afspraken.php).
 */
data class Consultatie(
    val id: Int,
    val dier: String,
    val type: String,
    val eigenaar: String,
    val tijd: String
)

/**
 * Centrale (mock) databron. Vervang de voorbeeldlijsten later
 * door echte API/repository calls.
 */
object DataSource {

    val consultatiesToday: List<Consultatie> = listOf(
        // Voorbeelden — laat leeg om de "Geen consultaties vandaag" state te zien
        // Consultatie(1, "Hond Rex", "Vaccinatie", "Jan Janssens", "08/04/2026 09:30"),
        // Consultatie(2, "Kat Mia", "Controle",   "Eva Peeters",  "08/04/2026 11:00"),
    )
}
