package com.example.gakkomobile.auth.domain.usecase

import com.example.gakkomobile.auth.data.AuthRepository

class LoginUseCase (
    private val authRepository: AuthRepository
) {
    suspend operator fun invoke(email: String, password: String): Result<Unit> {
        val loginResult = authRepository.login(email, password)

        return loginResult.fold(
            onSuccess = { token ->
                authRepository.saveToken(token)
            },
            onFailure = { exception ->
                Result.failure(exception)
            }
        )
    }
}