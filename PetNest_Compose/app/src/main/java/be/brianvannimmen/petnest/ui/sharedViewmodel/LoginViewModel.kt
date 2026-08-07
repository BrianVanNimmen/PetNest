package be.brianvannimmen.petnest.ui.sharedViewmodel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import be.brianvannimmen.petnest.network.KlantLoginResponse
import be.brianvannimmen.petnest.network.RetrofitClient
import be.brianvannimmen.petnest.network.UserSession
import com.google.firebase.auth.FirebaseAuth
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response



// zou het beter zijn om de LoginViewModel op te splitsen in 2 verschillende ViewModels ( 1 voor art 1 voor klant ) ?
// Nee, dat zou niet beter zijn — en zelfs slechter.
// De LoginViewModel doet momenteel één ding: inloggen. Dat is rolonafhankelijk:                                                                                                                                                                                                                                                                                                                                                                                           email + wachtwoord → Firebase → UID → login.php → type: klant of arts
// De rol weet je pas na de API call. Als je twee aparte ViewModels maakt, weet je op voorhand niet welke je moet gebruiken
class LoginViewModel : ViewModel() {

    private val firebaseAuth by lazy { FirebaseAuth.getInstance() }

    var uiState by mutableStateOf<LoginUiState>(LoginUiState.Idle)
        private set

    fun login(email: String, wachtwoord: String) {
        uiState = LoginUiState.Loading

        firebaseAuth.signInWithEmailAndPassword(email, wachtwoord)
            .addOnCompleteListener { task ->
                if (!task.isSuccessful) {
                    uiState = LoginUiState.Error(task.exception?.message ?: "Inloggen mislukt")
                    return@addOnCompleteListener
                }

                val uid = task.result?.user?.uid
                if (uid == null) {
                    uiState = LoginUiState.Error("Kon UID niet ophalen")
                    return@addOnCompleteListener
                }

                RetrofitClient.apiService.login(uid).enqueue(object : Callback<KlantLoginResponse> {
                    override fun onResponse(call: Call<KlantLoginResponse>, response: Response<KlantLoginResponse>) {
                        val body = response.body()
                        if (body?.type != null && body.data != null) {
                            UserSession.id = body.data.id
                            UserSession.voornaam = body.data.voornaam
                            UserSession.achternaam = body.data.achternaam
                            UserSession.type = body.type
                        }
                        if (body?.type == "arts") {
                            UserSession.dierenArtsId = body.dierenArtsId
                        }
                        uiState = when {
                            body?.type == "klant" -> LoginUiState.KlantIngelogd(klantId = body.klantId ?: 0,
                                voornaam = body.voornaam ?: "",
                                achternaam = body.achternaam ?: "")
                            body?.type == "arts" -> LoginUiState.ArtsIngelogd(body.dierenArtsId ?: 0)
                            body?.error != null -> LoginUiState.Error(body.error)
                            else -> LoginUiState.Error("Onbekende fout")
                        }
                    }

                    override fun onFailure(call: Call<KlantLoginResponse>, t: Throwable) {
                        uiState = LoginUiState.Error("Netwerkfout: ${t.message}")
                    }
                })
            }
    }
}

sealed class LoginUiState {
    data object Idle : LoginUiState()
    data object Loading : LoginUiState()
    data class KlantIngelogd(val klantId: Int,
                             val voornaam: String,
                             val achternaam: String) : LoginUiState()
    data class ArtsIngelogd(val dierenArtsId: Int) : LoginUiState()
    data class Error(val message: String) : LoginUiState()
}