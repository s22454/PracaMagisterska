package com.example.gakkomobile.auth.domain.usecase

class ValidateCredentialsUseCase {
    private val emailRegex = "^s[0-9]{5}@pjwstk.edu.pl$".toRegex()

    operator fun invoke(email: String, password: String): Result<Unit> {
        if (email.isBlank() || !email.matches(emailRegex)) {
            return Result.failure(IllegalArgumentException("Invalid email format"))
        }

        if (password.length < 8) {
            return Result.failure(IllegalArgumentException("Password is too short"))
        }

        return Result.success(Unit)
    }
}