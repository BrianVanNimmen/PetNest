package be.brianvannimmen.petnest.ui.klantViewmodel

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

class HomeViewModel : ViewModel()  {

    var afspraken by mutableStateOf<List<Afspraak>>(emptyList())
        private set

    var isLoading by mutableStateOf(false)
        private set

    fun loadAfspraken(klantId: Int) {
        isLoading = true

        RetrofitClient.apiService.getAfsprakenKlant(
            action = "get",
            klantId = klantId,
            limit = 5
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
                        tijd = it.tijd,
                        datum = it.geplandeDatumTijd.substringBefore(" ")
                    )
                } ?: emptyList()

                isLoading = false
            }

            override fun onFailure(call: Call<AfspraakListResponse>, t: Throwable) {
                afspraken = emptyList()
                isLoading = false
            }
        })
    }
}