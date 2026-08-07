package be.brianvannimmen.petnest.ui.artsViewmodel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import be.brianvannimmen.petnest.network.ApiResponse
import be.brianvannimmen.petnest.network.DossierUpdateRequest
import be.brianvannimmen.petnest.network.MedischDossierResponse
import be.brianvannimmen.petnest.network.RetrofitClient
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class ArtsMedischDossierViewModel : ViewModel() {

    var isLoading by mutableStateOf(false)
        private set
    var isSaving by mutableStateOf(false)
        private set
    var error by mutableStateOf<String?>(null)
        private set
    var opslaanSucces by mutableStateOf(false)
        private set

    var gewicht by mutableStateOf("")
    var gebitStatus by mutableStateOf("")
    var bottenStatus by mutableStateOf("")
    var spierenStatus by mutableStateOf("")
    var opmerking by mutableStateOf("")

    private var huidigDierId: Int? = null

    fun resetOpslaanSucces() {
        opslaanSucces = false
    }

    fun laad(dierId: Int) {
        huidigDierId = dierId
        isLoading = true
        error = null
        opslaanSucces = false

        RetrofitClient.apiService.getMedischDossier(dierId)
            .enqueue(object : Callback<MedischDossierResponse> {
                override fun onResponse(
                    call: Call<MedischDossierResponse>,
                    response: Response<MedischDossierResponse>
                ) {
                    val dto = response.body()?.data
                    if (dto != null) {
                        gewicht = dto.gewicht ?: ""
                        gebitStatus = dto.gebitStatus ?: ""
                        bottenStatus = dto.bottenStatus ?: ""
                        spierenStatus = dto.spierenStatus ?: ""
                        opmerking = dto.opmerking ?: ""
                    }
                    isLoading = false
                }

                override fun onFailure(call: Call<MedischDossierResponse>, t: Throwable) {
                    // Lege serverresponse = nog geen dossier aangemaakt, toon lege velden
                    if (t.message?.contains("End of input") == true) {
                        isLoading = false
                        return
                    }
                    error = "Netwerkfout: ${t.message}"
                    isLoading = false
                }
            })
    }

    fun opslaan() {
        val dierId = huidigDierId ?: return
        isSaving = true
        error = null
        opslaanSucces = false

        val request = DossierUpdateRequest(
            dierId = dierId,
            gewicht = gewicht.ifBlank { null },
            gebitStatus = gebitStatus,
            bottenStatus = bottenStatus,
            spierenStatus = spierenStatus,
            opmerking = opmerking.ifBlank { null }
        )

        RetrofitClient.apiService.saveMedischDossier(request)
            .enqueue(object : Callback<ApiResponse> {
                override fun onResponse(
                    call: Call<ApiResponse>,
                    response: Response<ApiResponse>
                ) {
                    if (response.body()?.status == 200) {
                        opslaanSucces = true
                    } else {
                        error = response.body()?.message ?: "Opslaan mislukt"
                    }
                    isSaving = false
                }

                override fun onFailure(call: Call<ApiResponse>, t: Throwable) {
                    // Lege serverresponse na opslaan = geslaagd (PHP stuurt geen body terug)
                    if (t.message?.contains("End of input") == true) {
                        opslaanSucces = true
                        isSaving = false
                        return
                    }
                    error = "Netwerkfout: ${t.message}"
                    isSaving = false
                }
            })
    }
}
