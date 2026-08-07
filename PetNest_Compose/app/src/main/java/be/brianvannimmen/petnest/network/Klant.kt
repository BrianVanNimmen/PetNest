package be.brianvannimmen.petnest.network

import com.google.gson.annotations.SerializedName

data class KlantRegisterRequest(
    @SerializedName("voornaam") var voornaam: String,
    @SerializedName("achternaam") var achternaam: String,
    @SerializedName("email") var email: String,
    @SerializedName("firebase_uid") var firebase_uid: String,
    @SerializedName("geboortedatum") var geboortedatum: String?,
    @SerializedName("gemeente_id") var gemeente_id: Int?,
)

data class KlantRegisterResponse(
    @SerializedName("data") var data: String = "ok",
    @SerializedName("message") var message: String,
    @SerializedName("status") var status: Int,
    @SerializedName("PR_ID") var PR_ID: Int,
    @SerializedName("firebase_uid") var firebase_uid: String
)

data class LoginUserData(
    @SerializedName("id") val id: Int?,
    @SerializedName("voornaam") val voornaam: String?,
    @SerializedName("achternaam") val achternaam: String?,
    @SerializedName("email") val email: String?,
    @SerializedName("firebase_uid") val firebaseUid: String?,
    @SerializedName("status") val status: String?
)

data class KlantLoginResponse(
    @SerializedName("type") val type: String?,
    @SerializedName("klant_id") val klantId: Int?,
    @SerializedName("voornaam") val voornaam: String?,
    @SerializedName("achternaam") val achternaam: String?,
    @SerializedName("dierenarts_id") val dierenArtsId: Int?,
    @SerializedName("data") val data: LoginUserData?,
    @SerializedName("error") val error: String?,
    @SerializedName("status") val status: String?
)