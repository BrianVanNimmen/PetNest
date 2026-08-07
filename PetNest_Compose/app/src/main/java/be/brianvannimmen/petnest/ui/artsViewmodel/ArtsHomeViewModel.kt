package be.brianvannimmen.petnest.ui.artsViewmodel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import be.brianvannimmen.petnest.network.Afspraak
import be.brianvannimmen.petnest.network.AfspraakListResponse
import be.brianvannimmen.petnest.network.RetrofitClient
import be.brianvannimmen.petnest.network.UserSession
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.util.Calendar

class ArtsHomeViewModel : ViewModel() {
    var artsNaam by mutableStateOf(UserSession.fullName)
        private set

    var afspraken by mutableStateOf<List<Afspraak>>(emptyList())
        private set
    var isLoading by mutableStateOf(false)
        private set
    var error by mutableStateOf<String?>(null)
        private set

    init {
        laadVandaagAfspraken()
    }

    fun laadVandaagAfspraken() {
        val artsId = UserSession.dierenArtsId ?: run {
            error = "Sessie ongeldig: arts-ID niet gevonden."
            return
        }
        val cal = Calendar.getInstance()
        val vandaag = "%04d-%02d-%02d".format(
            cal.get(Calendar.YEAR),
            cal.get(Calendar.MONTH) + 1,
            cal.get(Calendar.DAY_OF_MONTH)
        )
        isLoading = true
        error = null

        RetrofitClient.apiService.getAfspraken(
            action = "get",
            dierenArtsId = artsId,
            from = vandaag,
            to = vandaag,
            limit = 50
        ).enqueue(object : Callback<AfspraakListResponse> {
            override fun onResponse(
                call: Call<AfspraakListResponse>,
                response: Response<AfspraakListResponse>
            ) {
                afspraken = response.body()?.data?.map {
                    Afspraak(
                        id = it.id,
                        dier = it.huisdierNaam,
                        type = it.type,
                        tijd = it.tijd
                    )
                } ?: emptyList()
                isLoading = false
            }

            override fun onFailure(call: Call<AfspraakListResponse>, t: Throwable) {
                error = "Netwerkfout: ${t.message}"
                isLoading = false
            }
        })
    }
}
