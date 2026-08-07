package be.brianvannimmen.petnest.network

import com.google.gson.annotations.SerializedName

data class Afspraak(
    val id: Int,
    val dier: String,
    val tijd: String,
    val type: String,
    val datum: String = "",
    val arts: String = ""
)

data class AfspraakApiItem(
    @SerializedName("id") val id: Int = 0,
    @SerializedName("dier") val dier: String = "",
    @SerializedName("naam") val naam: String = "",          // huisdier naam (klant-side)
    @SerializedName("type") val type: String = "",
    @SerializedName("eigenaar") val eigenaar: String = "",
    @SerializedName("tijd") val tijd: String = "",
    @SerializedName("geplande_datumtijd") val geplandeDatumTijd: String = "",
    @SerializedName("dierenarts_id") val dierenArtsId: Int = 0
) {
    // Huisdier naam: gebruik "naam" als "dier" leeg is (API-variant klant)
    val huisdierNaam: String get() = naam.ifEmpty { dier }
}

data class AfspraakListResponse(
    @SerializedName("data") val data: List<AfspraakApiItem>?
)

data class AfspraakCreateRequest(
    @SerializedName("dier_id") val dierId: Int,
    @SerializedName("klant_id") val klantId: Int,
    @SerializedName("dierenarts_id") val artsId: Int,
    @SerializedName("geplande_datumtijd") val geplandeDatumTijd: String,
    @SerializedName("type") val type: String
)

data class AfspraakDeleteRequest(
    @SerializedName("id") val id: Int
)