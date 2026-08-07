package be.brianvannimmen.petnest.network

import com.google.gson.annotations.SerializedName

data class DossierUpdateRequest(
    @SerializedName("dier_id") val dierId: Int,
    @SerializedName("gewicht") val gewicht: String?,
    @SerializedName("gebit_status") val gebitStatus: String,
    @SerializedName("botten_status") val bottenStatus: String,
    @SerializedName("spieren_status") val spierenStatus: String,
    @SerializedName("opmerking") val opmerking: String?
)

data class MedischDossier(
    val pet: PetInfo?,
    val gewicht: String?,
    val gebitStatus: String?,
    val bottenStatus: String?,
    val spierenStatus: String?,
    val opmerking: String?
)

data class PetInfo(
    val id: Int? = null,
    val naam: String?,
    val soort: String?,
    val geboortedatum: String?,
    val fotoUrl: String?
)