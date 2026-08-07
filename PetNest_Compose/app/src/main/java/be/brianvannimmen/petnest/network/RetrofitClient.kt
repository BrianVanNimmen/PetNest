package be.brianvannimmen.petnest.network

import com.google.gson.GsonBuilder
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

object RetrofitClient {
    const val BASE_URL = "http://10.0.2.2:8080/"

    private val gson = GsonBuilder().setLenient().create() // etLenient(true) zorgt dat Gson de response accepteert ook als er extra whitespace, een BOM of een PHP notice/warning voor de JSON staat

    val apiService: PetNestApiService by lazy {
        Retrofit.Builder()
            .baseUrl(BASE_URL)
            .addConverterFactory(GsonConverterFactory.create(gson))
            .build()
            .create(PetNestApiService::class.java)
    }
}