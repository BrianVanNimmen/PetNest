package be.brianvannimmen.petnest.model

data class TijdSlot(
    val start: String,
    val einde: String
) {
    override fun toString(): String {
        return "$start - $einde"
    }
}

val TIJD_SLOTEN = listOf(
    TijdSlot("08:00", "09:00"),
    TijdSlot("09:00", "10:00"),
    TijdSlot("10:00", "11:00"),
    TijdSlot("11:00", "12:00"),
    TijdSlot("13:00", "14:00"),
    TijdSlot("14:00", "15:00"),
    TijdSlot("15:00", "16:00"),
    TijdSlot("16:00", "17:00"),
    TijdSlot("17:00", "18:00")
)