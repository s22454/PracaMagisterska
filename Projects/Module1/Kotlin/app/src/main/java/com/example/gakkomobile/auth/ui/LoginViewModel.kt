package com.example.gakkomobile.auth.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.gakkomobile.auth.domain.usecase.CheckSessionUseCase
import com.example.gakkomobile.auth.domain.usecase.LoginUseCase
import com.example.gakkomobile.auth.domain.usecase.ValidateCredentialsUseCase
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

class LoginViewModel(
    private val loginUseCase: LoginUseCase,
    private val validateCredentialsUseCase: ValidateCredentialsUseCase,
    private val checkSessionUseCase: CheckSessionUseCase
) : ViewModel() {
    private val _uiState = MutableStateFlow(LoginUiState())
    val uiState: StateFlow<LoginUiState> = _uiState.asStateFlow()

    init {
        checkSession()
    }

    fun onEmailChanged(newEmail: String) {
        _uiState.update { currentState ->
            currentState.copy(email = newEmail)
        }
    }

    fun onPasswordChanged(newPassword: String) {
        _uiState.update { currentState ->
            currentState.copy(password = newPassword)
        }
    }

    fun login() {
        val currentState = _uiState.value
        if (currentState.isLoading) return

        val validationResult = validateCredentialsUseCase(currentState.email, currentState.password)

        if (validationResult.isFailure) {
            _uiState.update {
                it.copy(errorMessage = validationResult.exceptionOrNull()?.message)
            }
            return
        }

        _uiState.update { it.copy(isLoading = true, errorMessage = null) }

        viewModelScope.launch {
            val loginResult = loginUseCase(currentState.email, currentState.password)

            loginResult.fold(
                onSuccess = {
                    _uiState.update { it.copy(isLoading = false, isUserLoggedIn = true) }
                },
                onFailure = { error ->
                    _uiState.update { it.copy(isLoading = false, errorMessage = error.message) }
                }
            )
        }
    }

    fun checkSession() {
        viewModelScope.launch {
            val hasSession = checkSessionUseCase()
            if (hasSession) {
                _uiState.update { it.copy(hasSavedSession = true) }
            }
        }
    }

    fun onBiometricLoginSuccess() {
        _uiState.update { it.copy(isUserLoggedIn = true) }
    }

    fun clearSavedSession() {
        _uiState.update { it.copy(hasSavedSession = false, isLoading = false) }
    }
}