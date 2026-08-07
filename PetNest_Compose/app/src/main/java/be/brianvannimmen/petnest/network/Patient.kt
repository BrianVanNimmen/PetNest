package be.brianvannimmen.petnest.network

import com.google.gson.annotations.SerializedName

data class Patient(
    val id: Int,
    val naam: String,
    val soort: String,
    val geboortedatum: String? = null,
    val fotoUrl: String? = null
)

data class PatientApiItem(
    @SerializedName("id") val id: Int,
    @SerializedName("naam") val naam: String,
    @SerializedName("soort") val soort: String,
    @SerializedName("geboortedatum") val geboortedatum: String?,
    @SerializedName("foto_url") val fotoUrl: String?,
    @SerializedName("dierenarts_id") val dierenArtsId: Int?
) {
    fun toPatient() = Patient(
        id = id,
        naam = naam,
        soort = soort,
        geboortedatum = geboortedatum,
        fotoUrl = fotoUrl
    )
}

data class PatientListResponse(
    @SerializedName("status") val status: Int,
    @SerializedName("count") val count: Int,
    @SerializedName("data") val data: List<PatientApiItem>?
)
