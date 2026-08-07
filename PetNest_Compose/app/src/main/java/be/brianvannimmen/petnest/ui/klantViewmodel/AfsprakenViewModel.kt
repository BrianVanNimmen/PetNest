package be.brianvannimmen.petnest.ui.klantViewmodel

import android.util.Log
import androidx.lifecycle.ViewModel
import be.brianvannimmen.petnest.model.SimpleItem
import be.brianvannimmen.petnest.network.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class AfspraakViewModel : ViewModel() {

    private val _afspraken = MutableStateFlow<List<Afspraak>>(emptyList())
    val afspraken = _afspraken.asStateFlow()

    private val _bezetteSlots = MutableStateFlow<Set<String>>(emptySet())
    val bezetteSlots = _bezetteSlots.asStateFlow()

    private val _artsen = MutableStateFlow<List<SimpleItem>>(emptyList())
    fun setArtsen(artsen: List<SimpleItem>) {
        _artsen.value = artsen
        loadAfspraken()
    }

    fun loadBezetteSlots(datum: String, artsId: Int) {

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
                Log.d("AFSPRAAK", "loadBezetteSlots HTTP: ${response.code()}")
                Log.d("AFSPRAAK", "loadBezetteSlots body: ${response.body()}")
                Log.d("AFSPRAAK", "loadBezetteSlots data: ${response.body()?.data}")

                if (response.isSuccessful) {

                    _bezetteSlots.value =
                        response.body()?.data
                            ?.mapNotNull {
                                // "26/05/2026 09:00" -> "09:00"
                                it.geplandeDatumTijd.split(" ").getOrNull(1)?.take(5)
                            }
                            ?.toSet()
                            ?: emptySet()

                    Log.d("AFSPRAAK", "Bezette slots: ${_bezetteSlots.value}")
                }
            }

            override fun onFailure(
                call: Call<AfspraakListResponse>,
                t: Throwable
            ) {
                Log.e("AFSPRAAK", "Bezette slots laden mislukt", t)
            }
        })
    }

    fun clearBezetteSlots() {
        _bezetteSlots.value = emptySet()
    }

    fun loadAfspraken() {
        val klantId = UserSession.id ?: return

        RetrofitClient.apiService.getAfsprakenKlant(
            action = "get",
            klantId = klantId,
            limit = 50
        ).enqueue(object : Callback<AfspraakListResponse> {

            override fun onResponse(
                call: Call<AfspraakListResponse>,
                response: Response<AfspraakListResponse>
            ) {
                if (response.isSuccessful) {

                    val data = response.body()?.data ?: emptyList()

                    _afspraken.value = data.map {

                        val parts = it.geplandeDatumTijd?.split(" ") ?: listOf("", "")

                        val datum = parts.getOrNull(0) ?: ""
                        val tijd = parts.getOrNull(1)?.take(5) ?: ""

                        val artsNaam = _artsen.value.find { arts -> arts.id == it.dierenArtsId }?.naam ?: ""

                        Afspraak(
                            id = it.id,
                            dier = it.huisdierNaam,
                            tijd = tijd,
                            type = it.type,
                            datum = datum,
                            arts = artsNaam
                        )
                    }

                } else {
                    Log.e("AFSPRAAK", "Error loading afspraken")
                }
            }

            override fun onFailure(call: Call<AfspraakListResponse>, t: Throwable) {
                Log.e("AFSPRAAK", "Network error", t)
            }
        })
    }

    fun getBezetteSlots(datum: String): Set<String> {
        return _afspraken.value
            .filter { it.datum == datum }
            .map { it.tijd.take(5) }
            .toSet()
    }

    fun deleteAfspraak(id: Int, onSuccess: () -> Unit = {}) {
        RetrofitClient.apiService.deleteAfspraak(AfspraakDeleteRequest(id))
            .enqueue(object : Callback<ApiResponse> {
                override fun onResponse(call: Call<ApiResponse>, response: Response<ApiResponse>) {
                    if (response.isSuccessful) {
                        loadAfspraken()
                        onSuccess()
                    } else {
                        Log.e("AFSPRAAK", "Delete mislukt: ${response.errorBody()?.string()}")
                    }
                }
                override fun onFailure(call: Call<ApiResponse>, t: Throwable) {
                    Log.e("AFSPRAAK", "Network error bij delete", t)
                }
            })
    }

    fun createAfspraak(
        dierId: Int,
        artsId: Int,
        datum: String,
        tijd: String,
        type: String,
        onSuccess: () -> Unit = {}
    ) {
        val klantId = UserSession.id

        if (klantId == null) {
            Log.e("AFSPRAAK", "Geen klantId in session")
            return
        }

        if (datum.isBlank() || tijd.isBlank()) {
            Log.e("AFSPRAAK", "Datum of tijd ontbreekt")
            return
        }

        val safeTijd = tijd.take(5)
        val geplandeDatumTijd = "${datum} ${safeTijd}:00"

        val request = AfspraakCreateRequest(
            dierId = dierId,
            klantId = klantId,
            artsId = artsId,
            geplandeDatumTijd = geplandeDatumTijd,
            type = type
        )

        Log.d(
            "AFSPRAAK",
            "Versturen: klant=$klantId dier=$dierId arts=$artsId datum=$datum tijd=$safeTijd type=$type"
        )

        RetrofitClient.apiService.createAfspraak(request)
            .enqueue(object : Callback<ApiResponse> {

                override fun onResponse(
                    call: Call<ApiResponse>,
                    response: Response<ApiResponse>
                ) {

                    Log.d("AFSPRAAK", "HTTP: ${response.code()}")
                    Log.d("AFSPRAAK", "body: ${response.body()}")

                    if (response.isSuccessful) {
                        Log.d("AFSPRAAK", "Afspraak succesvol aangemaakt")

                        loadAfspraken()
                        onSuccess()

                    } else {
                        val error = response.errorBody()?.string() ?: "unknown error"
                        Log.e("AFSPRAAK", error)
                    }
                }

                override fun onFailure(call: Call<ApiResponse>, t: Throwable) {
                    Log.e("AFSPRAAK", "Network error", t)
                }
            })
    }
}