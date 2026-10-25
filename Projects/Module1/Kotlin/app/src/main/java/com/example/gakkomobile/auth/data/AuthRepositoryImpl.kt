package com.example.gakkomobile.auth.data

import com.example.gakkomobile.auth.data.local.EncryptedTokenStore
import com.example.gakkomobile.auth.data.remote.AuthRemoteDataSource
import com.example.gakkomobile.auth.data.remote.LoginRequest

class AuthRepositoryImpl(
    private val remoteDataSource: AuthRemoteDataSource,
    private val tokenStore: EncryptedTokenStore
) : AuthRepository {

    override suspend fun login(
        email: String,
        password: String
    ): Result<String> {
        try {
            val request = LoginRequest(email, password)

            val response = remoteDataSource.authenticate(request)

            return if (response.isSuccessful) {
                val token = response.body()?.token
                if (token != null) {
                    Result.success(token)
                } else {
                    Result.failure(Exception("Server didn't returned a token"))
                }
            } else {
                Result.failure(Exception("Auth failure"))
            }
        } catch (e: Exception) {
            return Result.failure(e)
        }
    }

    override suspend fun saveToken(token: String): Result<Unit> {
        return try {
            tokenStore.persistToken(token)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun hasValidToken(): Boolean {
        val token = tokenStore.retrieveToken()
        return !token.isNullOrEmpty()
    }
}
