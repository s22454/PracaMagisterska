package com.example.gakkomobile.auth.ui

data class LoginUiState (
    val email: String = "",
    val password: String = "",
    val isLoading: Boolean = false,
    val isUserLoggedIn: Boolean = false,
    val hasSavedSession: Boolean = false,
    val errorMessage: String? = null
)