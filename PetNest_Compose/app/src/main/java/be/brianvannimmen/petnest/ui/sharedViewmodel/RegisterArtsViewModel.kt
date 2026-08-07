package be.brianvannimmen.petnest.ui.sharedViewmodel

import android.app.Application
import android.net.Uri
import android.provider.OpenableColumns
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.AndroidViewModel
import be.brianvannimmen.petnest.network.ArtsRegisterResponse
import be.brianvannimmen.petnest.network.Gemeente
import be.brianvannimmen.petnest.network.GemeenteListResponse
import be.brianvannimmen.petnest.network.RetrofitClient
import com.google.firebase.auth.FirebaseAuth
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.toRequestBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class RegisterArtsViewModel(application: Application) : AndroidViewModel(application) {

    private val firebaseAuth by lazy { FirebaseAuth.getInstance() }

    var uiState by mutableStateOf<UiState>(UiState.Idle)
        private set

    var gemeentes by mutableStateOf<List<Gemeente>>(emptyList())
        private set

    var gemeentesLaadfout by mutableStateOf<String?>(null)
        private set

    init {
        laadGemeentes()
    }

    private fun laadGemeentes() {
        RetrofitClient.apiService.getGemeentes().enqueue(object : Callback<GemeenteListResponse> {
            override fun onResponse(call: Call<GemeenteListResponse>, response: Response<GemeenteListResponse>) {
                if (response.isSuccessful) {
                    gemeentes = response.body()?.data ?: emptyList()
                } else {
                    gemeentesLaadfout = "Kon gemeentes niet laden (${response.code()})"
                }
            }
            override fun onFailure(call: Call<GemeenteListResponse>, t: Throwable) {
                gemeentesLaadfout = "Geen verbinding met server: ${t.message}"
            }
        })
    }

    fun registreer(
        voornaam: String,
        achternaam: String,
        email: String,
        wachtwoord: String,
        gemeenteId: Int,
        telefoon: String,
        praktijknaam: String,
        certificaatUri: Uri
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

                val resolver = getApplication<Application>().contentResolver

                val bestandsnaam = resolver.query(certificaatUri, null, null, null, null)?.use { cursor ->
                    val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                    cursor.moveToFirst()
                    cursor.getString(index)
                } ?: "certificaat"

                val mimeType = resolver.getType(certificaatUri) ?: "application/octet-stream"

                val bestandBytes = resolver.openInputStream(certificaatUri)?.use { it.readBytes() }
                if (bestandBytes == null) {
                    uiState = UiState.Error("Kon certificaat niet lezen")
                    return@addOnCompleteListener
                }

                fun String.asTextPart() = toRequestBody("text/plain".toMediaType())

                val certificaatPart = MultipartBody.Part.createFormData(
                    "certificaat",
                    bestandsnaam,
                    bestandBytes.toRequestBody(mimeType.toMediaType())
                )

                RetrofitClient.apiService.postArts(
                    voornaam = voornaam.asTextPart(),
                    achternaam = achternaam.asTextPart(),
                    email = email.asTextPart(),
                    firebase_uid = uid.asTextPart(),
                    telefoon = telefoon.asTextPart(),
                    praktijknaam = praktijknaam.asTextPart(),
                    gemeente_id = gemeenteId.toString().asTextPart(),
                    certificaat = certificaatPart
                ).enqueue(object : Callback<ArtsRegisterResponse> {
                    override fun onResponse(call: Call<ArtsRegisterResponse>, response: Response<ArtsRegisterResponse>) {
                        uiState = if (response.isSuccessful && response.body()?.id != null) {
                            UiState.Success
                        } else {
                            UiState.Error(response.body()?.message ?: "Onbekende serverfout")
                        }
                    }

                    override fun onFailure(call: Call<ArtsRegisterResponse>, t: Throwable) {
                        uiState = UiState.Error("Netwerkfout: ${t.message}")
                    }
                })
            }
    }
}