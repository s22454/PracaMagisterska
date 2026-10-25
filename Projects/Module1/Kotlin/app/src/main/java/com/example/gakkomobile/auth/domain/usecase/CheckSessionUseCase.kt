package com.example.gakkomobile.auth.domain.usecase

import com.example.gakkomobile.auth.data.AuthRepository

class CheckSessionUseCase (
    private val authRepository: AuthRepository
) {
    suspend operator fun invoke(): Boolean {
        return authRepository.hasValidToken()
    }
}