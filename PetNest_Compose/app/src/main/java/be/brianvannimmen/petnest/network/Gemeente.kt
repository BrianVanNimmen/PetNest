package be.brianvannimmen.petnest.network

import com.google.gson.annotations.SerializedName

data class Gemeente(
    @SerializedName("id") val id: Int,
    @SerializedName("naam") val naam: String
)

data class GemeenteListResponse(
    @SerializedName("data") val data: List<Gemeente>
)