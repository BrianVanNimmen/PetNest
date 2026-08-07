package be.brianvannimmen.petnest.network

import okhttp3.MultipartBody
import okhttp3.RequestBody
import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.HTTP
import retrofit2.http.Multipart
import retrofit2.http.POST
import retrofit2.http.PUT
import retrofit2.http.Part
import retrofit2.http.Query

interface PetNestApiService {
    @GET("login.php")
    fun login(@Query("firebase_uid") firebaseUid: String): Call<KlantLoginResponse>

    @GET("gemeentes.php")
    fun getGemeentes(): Call<GemeenteListResponse>

    @Multipart
    @POST("artsen.php")
    fun postArts(
        @Part("voornaam") voornaam: RequestBody,
        @Part("achternaam") achternaam: RequestBody,
        @Part("email") email: RequestBody,
        @Part("firebase_uid") firebase_uid: RequestBody,
        @Part("telefoon") telefoon: RequestBody,
        @Part("praktijknaam") praktijknaam: RequestBody,
        @Part("gemeente_id") gemeente_id: RequestBody?,
        @Part certificaat: MultipartBody.Part
    ): Call<ArtsRegisterResponse>

    @GET("afspraken.php")
    fun getAfspraken(
        @Query("action") action: String,
        @Query("dierenarts_id") dierenArtsId: Int,
        @Query("from") from: String,
        @Query("to") to: String,
        @Query("limit") limit: Int
    ): Call<AfspraakListResponse>

    @GET("afspraken.php")
    fun getAfsprakenKlant(
        @Query("action") action: String,
        @Query("klant_id") klantId: Int,
        @Query("limit") limit: Int
    ): Call<AfspraakListResponse>

    @GET("dieren.php")
    fun getPatientenVoorArts(
        @Query("dierenarts_id") dierenArtsId: Int
    ): Call<PatientListResponse>

    @POST("klanten.php")
    fun postKlant(@Body request: KlantRegisterRequest): Call<KlantRegisterResponse>

    @GET("dieren.php")
    fun getHuisdieren(
        @Query("klant_id") klantId: Int
    ): Call<HuisdierenResponse>

    @GET("dossier.php")
    fun getMedischDossier(
        @Query("dier_id") dierId: Int,
    ): Call<MedischDossierResponse>

    @PUT("dossier.php")
    fun saveMedischDossier(
        @Body request: DossierUpdateRequest
    ): Call<ApiResponse>

    @GET("artsen.php")
    fun getArtsen(): Call<ArtsenResponse>

    @Multipart
    @POST("dieren.php")
    fun createHuisdier(
        @Part("naam") naam: RequestBody,
        @Part("soort") soort: RequestBody,
        @Part("geboortedatum") geboortedatum: RequestBody,
        @Part("klant_id") klantId: RequestBody,
        @Part("dierenarts_id") dierenArtsId: RequestBody,
        @Part foto: MultipartBody.Part?
    ): Call<ApiResponse>

    @PUT("dieren.php")
    fun updateHuisdier(
        @Body request: UpdateHuisdierRequest
    ): Call<ApiResponse>

    @POST("afspraken.php")
    fun createAfspraak(
        @Body request: AfspraakCreateRequest
    ): Call<ApiResponse>

    @HTTP(method = "DELETE", path = "afspraken.php", hasBody = true)
    fun deleteAfspraak(
        @Body request: AfspraakDeleteRequest
    ): Call<ApiResponse>
}