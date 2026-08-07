package be.brianvannimmen.petnest.ui.klantViewmodel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import be.brianvannimmen.petnest.network.MedischDossierResponse
import be.brianvannimmen.petnest.network.RetrofitClient
import be.brianvannimmen.petnest.network.MedischDossier
import be.brianvannimmen.petnest.network.PetInfo
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class MedischDossierViewModel : ViewModel() {
    var dossier by mutableStateOf<MedischDossier?>(null)
        private set

    var isLoading by mutableStateOf(false)
        private set

    fun load(id: Int) {
        isLoading = true

        RetrofitClient.apiService.getMedischDossier(id)
            .enqueue(object : Callback<MedischDossierResponse> {

                override fun onResponse(
                    call: Call<MedischDossierResponse>,
                    response: Response<MedischDossierResponse>
                ) {
                    val dto = response.body()?.data

                    dossier = dto?.let {
                        MedischDossier(
                            pet = PetInfo(
                                naam = it.pet?.naam,
                                soort = it.pet?.soort,
                                geboortedatum = it.pet?.geboortedatum,
                                fotoUrl = it.pet?.fotoUrl
                            ),
                            gewicht = it.gewicht,
                            gebitStatus = it.gebitStatus,
                            bottenStatus = it.bottenStatus,
                            spierenStatus = it.spierenStatus,
                            opmerking = it.opmerking
                        )
                    }

                    isLoading = false
                }

                override fun onFailure(call: Call<MedischDossierResponse>, t: Throwable) {
                    dossier = null
                    isLoading = false
                }
            })
    }
}