package be.brianvannimmen.petnest.ui.artsViewmodel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import be.brianvannimmen.petnest.network.Patient
import be.brianvannimmen.petnest.network.PatientListResponse
import be.brianvannimmen.petnest.network.RetrofitClient
import be.brianvannimmen.petnest.network.UserSession
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class ArtsPatientenViewModel : ViewModel() {

    var patienten by mutableStateOf<List<Patient>>(emptyList())
        private set
    var isLoading by mutableStateOf(false)
        private set
    var error by mutableStateOf<String?>(null)
        private set

    fun laadPatienten() {
        val artsId = UserSession.dierenArtsId ?: run {
            error = "Sessie ongeldig: arts-ID niet gevonden. Probeer opnieuw in te loggen."
            return
        }
        isLoading = true
        error = null

        RetrofitClient.apiService.getPatientenVoorArts(artsId).enqueue(object : Callback<PatientListResponse> {
            override fun onResponse(call: Call<PatientListResponse>, response: Response<PatientListResponse>) {
                patienten = response.body()?.data?.map { it.toPatient() } ?: emptyList()
                isLoading = false
            }

            override fun onFailure(call: Call<PatientListResponse>, t: Throwable) {
                error = "Netwerkfout: ${t.message}"
                isLoading = false
            }
        })
    }
}
