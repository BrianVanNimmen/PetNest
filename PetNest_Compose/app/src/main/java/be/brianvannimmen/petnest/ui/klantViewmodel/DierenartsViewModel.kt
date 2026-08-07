package be.brianvannimmen.petnest.ui.klantViewmodel

import android.util.Log
import androidx.lifecycle.ViewModel
import be.brianvannimmen.petnest.model.SimpleItem
import be.brianvannimmen.petnest.network.ArtsenResponse
import be.brianvannimmen.petnest.network.RetrofitClient
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class DierenartsViewModel : ViewModel() {

    private val _artsen = MutableStateFlow<List<SimpleItem>>(emptyList())
    val artsen: StateFlow<List<SimpleItem>> = _artsen

    init {
        fetchArtsen()
    }

    private fun fetchArtsen() {

        Log.d("ARTSEN", "fetchArtsen() gestart")

        RetrofitClient.apiService.getArtsen()
            .enqueue(object : Callback<ArtsenResponse> {

                override fun onResponse(
                    call: Call<ArtsenResponse>,
                    response: Response<ArtsenResponse>
                ) {

                    Log.d("ARTSEN", "HTTP code: ${response.code()}")
                    Log.d("ARTSEN", "raw body: ${response.body()}")

                    val data = response.body()?.data.orEmpty()

                    _artsen.value = data.map {
                        SimpleItem(
                            id = it.id,
                            naam = "${it.voornaam} ${it.achternaam}"
                        )
                    }

                    Log.d("ARTSEN", "aantal artsen: ${_artsen.value.size}")
                }

                override fun onFailure(call: Call<ArtsenResponse>, t: Throwable) {
                    Log.e("ARTSEN", "API error", t)
                    _artsen.value = emptyList()
                }
            })
    }
}
