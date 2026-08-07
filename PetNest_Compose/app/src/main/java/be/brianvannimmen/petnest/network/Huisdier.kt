package be.brianvannimmen.petnest.network

import com.google.gson.annotations.SerializedName

data class Huisdier(
    val id: Int,
    val naam: String,
    val soort: String?,
    //val geboortedatum: String?,
    //@SerializedName("dierenarts_id") val dierenartsId: Int?,
    @SerializedName("foto_url") val fotoUrl: String?
)

// --- Respons voor de LIJST met dieren (gebruikt in HuisdierenViewModel) ---
data class HuisdierenResponse(
    val status: Int,
    val message: String,
    val data: List<be.brianvannimmen.petnest.network.Huisdier>?
)

// --- Respons voor het SPECIFIEKE medisch dossier ---
data class MedischDossierResponse(
    val status: Int,
    val message: String,
    val data: MedischDossierDto?
)

data class MedischDossierDto(
    val id: Int,
    val dier_id: Int,
    val gewicht: String?,
    @SerializedName("gebit_status") val gebitStatus: String?,
    @SerializedName("botten_status") val bottenStatus: String?,
    @SerializedName("spieren_status") val spierenStatus: String?,
    val opmerking: String?,
    val pet: PetDto?
)

data class PetDto(
    val id: Int,
    val naam: String?,
    val soort: String?,
    val geboortedatum: String?,
    @SerializedName("foto_url") val fotoUrl: String?,
    @SerializedName("dierenarts_id") val dierenartsId: Int?
)

data class DierenartsDto(
    val id: Int,
    val voornaam: String,
    val achternaam: String,
    val email: String?,
    val telefoon: String?,
    val praktijknaam: String?,
    val gemeente_id: Int?,
    val firebase_uid: String?
)

data class ArtsenResponse(
    val status: Int,
    val message: String,
    val data: List<DierenartsDto>
)

data class ApiResponse(
    val status: Int,
    val message: String?
)

data class UpdateHuisdierRequest(
    val id: Int,
    val naam: String,
    val soort: String,
    val geboortedatum: String,
    val klant_id: Int,
    val dierenarts_id: Int
)
