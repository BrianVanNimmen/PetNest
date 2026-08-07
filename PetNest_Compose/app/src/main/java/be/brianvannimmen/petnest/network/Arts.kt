package be.brianvannimmen.petnest.network

import com.google.gson.annotations.SerializedName

data class ArtsRegisterResponse(
    @SerializedName("status") val status: Int? = null,
    @SerializedName("message") val message: String? = null,
    @SerializedName("id") val id: Int? = null,
    @SerializedName("firebase_uid") val firebase_uid: String? = null,
    @SerializedName("status_arts") val status_arts: String? = null,
    @SerializedName("certificaatUrl") val certificaatUrl: String? = null
)
