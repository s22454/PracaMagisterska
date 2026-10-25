package com.example.gakkomobile.auth.data.remote

import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.Body
import retrofit2.http.POST

data class LoginRequest(
    val email: String,
    val password: String
)

data class TokenResponse(
    val token: String
)

interface AuthApi {
    @POST("api/auth/login")
    suspend fun authenticate(
        @Body request: LoginRequest
    ): Response<TokenResponse>
}

class AuthRemoteDataSource {
    private val retrofit = Retrofit.Builder()
        .baseUrl("http://bs-local.com:3000/")
        .addConverterFactory(GsonConverterFactory.create())
        .build()

    private val api = retrofit.create(AuthApi::class.java)

    suspend fun authenticate(request: LoginRequest): Response<TokenResponse> {
        return api.authenticate(request)
    }
}