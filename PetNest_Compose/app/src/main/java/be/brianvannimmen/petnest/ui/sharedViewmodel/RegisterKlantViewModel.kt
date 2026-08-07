package be.brianvannimmen.petnest.ui.sharedViewmodel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import be.brianvannimmen.petnest.network.Gemeente
import be.brianvannimmen.petnest.network.GemeenteListResponse
import be.brianvannimmen.petnest.network.KlantRegisterRequest
import be.brianvannimmen.petnest.network.KlantRegisterResponse
import be.brianvannimmen.petnest.network.RetrofitClient
import com.google.firebase.auth.FirebaseAuth
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class RegisterKlantViewModel : ViewModel() {

    private val firebaseAuth by lazy { FirebaseAuth.getInstance() }

    var uiState by mutableStateOf<UiState>(UiState.Idle)
        private set

    var gemeentes by mutableStateOf<List<Gemeente>>(emptyList())
        private set

    init {
        laadGemeentes()
    }

    private fun laadGemeentes() {
        RetrofitClient.apiService.getGemeentes().enqueue(object : Callback<GemeenteListResponse> {
            override fun onResponse(call: Call<GemeenteListResponse>, response: Response<GemeenteListResponse>) {
                if (response.isSuccessful) {
                    gemeentes = response.body()?.data ?: emptyList()
                }
            }
            override fun onFailure(call: Call<GemeenteListResponse>, t: Throwable) { }
        })
    }

    fun registreer(
        voornaam: String,
        achternaam: String,
        email: String,
        wachtwoord: String,
        geboortedatum: String,
        gemeenteId: Int
    ) {
        uiState = UiState.Loading

        firebaseAuth.createUserWithEmailAndPassword(email, wachtwoord)
            .addOnCompleteListener { task ->
                if (!task.isSuccessful) {
                    uiState = UiState.Error(task.exception?.message ?: "Firebase registratie mislukt")
                    return@addOnCompleteListener
                }

                val uid = task.result?.user?.uid
                if (uid == null) {
                    uiState = UiState.Error("Kon UID niet ophalen")
                    return@addOnCompleteListener
                }

                val request = KlantRegisterRequest(
                    voornaam = voornaam,
                    achternaam = achternaam,
                    email = email,
                    firebase_uid = uid,
                    geboortedatum = geboortedatum,
                    gemeente_id = gemeenteId
                )

                RetrofitClient.apiService.postKlant(request).enqueue(object : Callback<KlantRegisterResponse> {
                    override fun onResponse(call: Call<KlantRegisterResponse>, response: Response<KlantRegisterResponse>) {
                        uiState = if (response.isSuccessful) {
                            UiState.Success
                        } else {
                            UiState.Error(response.body()?.message ?: "Onbekende serverfout")
                        }
                    }

                    override fun onFailure(call: Call<KlantRegisterResponse>, t: Throwable) {
                        uiState = UiState.Error("Netwerkfout: ${t.message}")
                    }
                })
            }
    }
}

sealed class UiState {
    data object Idle : UiState()
    data object Loading : UiState()
    data object Success : UiState()
    data class Error(val message: String) : UiState()
}