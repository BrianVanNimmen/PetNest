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

class ArtsConsultatiesViewModel : ViewModel() {

    var afspraken by mutableStateOf<List<Afspraak>>(emptyList())
        private set
    var isLoading by mutableStateOf(false)
        private set
    var error by mutableStateOf<String?>(null)
        private set

    fun laadAfspraken(datum: String) {
        val artsId = UserSession.dierenArtsId ?: run {
            error = "Sessie ongeldig: arts-ID niet gevonden."
            return
        }
        isLoading = true
        error = null

        RetrofitClient.apiService.getAfspraken(
            action = "get",
            dierenArtsId = artsId,
            from = datum,
            to = datum,
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
