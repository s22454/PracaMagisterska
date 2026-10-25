package com.example.gakkomobile.auth.data

interface AuthRepository {
    suspend fun login(email: String, password: String): Result<String>
    suspend fun saveToken(token: String): Result<Unit>
    suspend fun hasValidToken(): Boolean
}