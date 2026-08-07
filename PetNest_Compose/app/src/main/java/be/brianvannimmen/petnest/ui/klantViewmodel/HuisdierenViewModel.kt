package be.brianvannimmen.petnest.ui.klantViewmodel

import android.app.Application
import android.net.Uri
import android.util.Log
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.ViewModel
import be.brianvannimmen.petnest.network.ApiResponse
import be.brianvannimmen.petnest.network.HuisdierenResponse
import be.brianvannimmen.petnest.network.MedischDossierResponse
import be.brianvannimmen.petnest.network.PetDto
import be.brianvannimmen.petnest.network.RetrofitClient
import be.brianvannimmen.petnest.network.UpdateHuisdierRequest
import be.brianvannimmen.petnest.network.UserSession
import be.brianvannimmen.petnest.ui.state.HuisdierenUiState
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.toRequestBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


//  AndroidViewModel = speciale ViewModel die toegang heeft tot de volledige Android Application context.
class HuisdierenViewModel(application: Application) : AndroidViewModel(application) {

    private val _uiState = MutableStateFlow(HuisdierenUiState())
    val uiState: StateFlow<HuisdierenUiState> = _uiState.asStateFlow()

    private val _selectedPet = MutableStateFlow<PetDto?>(null)
    val selectedPet: StateFlow<PetDto?> = _selectedPet.asStateFlow()

    init {
        refresh()
    }

    fun refresh() {
        val loggedInId = UserSession.id
        Log.d("API", "HuisdierenViewModel refresh() aangeroepen. Gevonden ID: $loggedInId")
        
        if (loggedInId != null) {
            fetchHuisdieren(loggedInId)
        } else {
            Log.e("API", "HuisdierenViewModel: Kan niet refreshen, UserSession.id is null")
            _uiState.value = _uiState.value.copy(isLoading = false)
        }
    }

    private fun fetchHuisdieren(klantId: Int) {
        Log.d("API", "fetchHuisdieren() verzenden naar server voor klantId: $klantId")

        _uiState.value = _uiState.value.copy(isLoading = true, error = null)

        RetrofitClient.apiService
            .getHuisdieren(klantId)
            .enqueue(object : Callback<HuisdierenResponse> {

                override fun onResponse(
                    call: Call<HuisdierenResponse>,
                    response: Response<HuisdierenResponse>
                ) {
                    val body = response.body()
                    Log.d("API", "Huisdieren Response van server: $body")

                    if (response.isSuccessful && body != null) {
                        val lijst = body.data ?: emptyList()
                        Log.d("API", "Aantal dieren ontvangen: ${lijst.size}")
                        
                        _uiState.value = _uiState.value.copy(
                            dieren = lijst,
                            isLoading = false,
                            error = null
                        )
                    } else {
                        Log.e("API", "Fout bij ophalen dieren: Code ${response.code()}")
                        _uiState.value = _uiState.value.copy(
                            isLoading = false,
                            error = "Server fout"
                        )
                    }
                }

                override fun onFailure(call: Call<HuisdierenResponse>, t: Throwable) {
                    Log.e("API", "Netwerkfout in HuisdierenViewModel", t)
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        error = t.message
                    )
                }
            })
    }


    fun loadPetDetail(id: Int) {
        RetrofitClient.apiService.getMedischDossier(id)
            .enqueue(object : Callback<MedischDossierResponse> {

                override fun onResponse(
                    call: Call<MedischDossierResponse>,
                    response: Response<MedischDossierResponse>
                ) {
                    if (response.isSuccessful) {
                        _selectedPet.value = response.body()?.data?.pet
                    } else {
                        _selectedPet.value = null
                    }
                }

                override fun onFailure(call: Call<MedischDossierResponse>, t: Throwable) {
                    Log.e("DETAIL", "Error loading pet", t)
                    _selectedPet.value = null
                }
            })
    }


    fun saveHuisdier(
        naam: String,
        soort: String,
        geboortedatum: String,
        artsId: Int,
        fotoUri: Uri?
    ) {
        val klantId = UserSession.id

        if (klantId == null) {
            Log.e("SAVE", "Geen klantId in session")
            return
        }

        val plain = "text/plain".toMediaType()
        val naamPart = naam.toRequestBody(plain)
        val soortPart = soort.toRequestBody(plain)
        val geboortedatumPart = geboortedatum.toRequestBody(plain)
        val klantIdPart = klantId.toString().toRequestBody(plain)
        val artsIdPart = artsId.toString().toRequestBody(plain)

        val fotoPart: MultipartBody.Part? = fotoUri?.let { uri ->
            val context = getApplication<Application>()
            val mimeType = context.contentResolver.getType(uri) ?: "image/jpeg"
            val bytes = context.contentResolver.openInputStream(uri)?.use { it.readBytes() }
            bytes?.let {
                val requestBody = it.toRequestBody(mimeType.toMediaType())
                MultipartBody.Part.createFormData("foto", "foto.jpg", requestBody)
            }
        }

        Log.d("SAVE", "Versturen: naam=$naam soort=$soort klant_id=$klantId arts_id=$artsId foto=${fotoUri != null}")

        RetrofitClient.apiService.createHuisdier(naamPart, soortPart, geboortedatumPart, klantIdPart, artsIdPart, fotoPart)
            .enqueue(object : Callback<ApiResponse> {

                override fun onResponse(
                    call: Call<ApiResponse>,
                    response: Response<ApiResponse>
                ) {
                    Log.d("SAVE", "HTTP: ${response.code()}")
                    Log.d("SAVE", "body: ${response.body()}")

                    if (response.isSuccessful) {
                        Log.d("SAVE", "Huisdier opgeslagen")
                        refresh()
                    } else {
                        Log.e("SAVE", "Server error: ${response.errorBody()?.string()}")
                    }
                }

                override fun onFailure(call: Call<ApiResponse>, t: Throwable) {
                    Log.e("SAVE", "Network error", t)
                }
            })
    }

    fun updateHuisdier(
        id: Int,
        naam: String,
        soort: String,
        geboortedatum: String,
        artsId: Int,
        fotoUri: Uri?
    ) {

        val klantId = UserSession.id ?: return

        Log.d("UPDATE", "Versturen update: id=$id naam=$naam soort=$soort")

        val request = UpdateHuisdierRequest(
            id = id,
            naam = naam,
            soort = soort,
            geboortedatum = geboortedatum,
            klant_id = klantId,
            dierenarts_id = artsId
        )

        RetrofitClient.apiService.updateHuisdier(request)
            .enqueue(object : Callback<ApiResponse> {

                override fun onResponse(call: Call<ApiResponse>, response: Response<ApiResponse>) {

                    Log.d("UPDATE", "HTTP: ${response.code()}")
                    Log.d("UPDATE", "body: ${response.body()}")

                    if (response.isSuccessful && response.body()?.status == 200) {
                        Log.d("UPDATE", "OK")
                        refresh()
                    } else {
                        Log.e("UPDATE", "ERROR: ${response.errorBody()?.string()}")
                    }
                }

                override fun onFailure(call: Call<ApiResponse>, t: Throwable) {
                    Log.e("UPDATE", "Network error", t)
                }
            })
    }
}
