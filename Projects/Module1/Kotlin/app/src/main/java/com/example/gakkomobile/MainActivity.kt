package com.example.gakkomobile

import android.os.Bundle
import androidx.activity.compose.setContent
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.gakkomobile.auth.data.AuthRepositoryImpl
import com.example.gakkomobile.auth.data.local.EncryptedTokenStore
import com.example.gakkomobile.auth.data.remote.AuthRemoteDataSource
import com.example.gakkomobile.auth.domain.usecase.CheckSessionUseCase
import com.example.gakkomobile.auth.domain.usecase.LoginUseCase
import com.example.gakkomobile.auth.domain.usecase.ValidateCredentialsUseCase
import com.example.gakkomobile.auth.ui.LoginRoute
import com.example.gakkomobile.auth.ui.LoginViewModel
import com.example.gakkomobile.home.ui.HomeScreen

class MainActivity : FragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val authRemoteDataSource = AuthRemoteDataSource()
        val encryptedTokenStore = EncryptedTokenStore(this)
        val authRepository = AuthRepositoryImpl(authRemoteDataSource, encryptedTokenStore)

        val loginUseCase = LoginUseCase(authRepository)
        val validateCredentialsUseCase = ValidateCredentialsUseCase()
        val checkSessionUseCase = CheckSessionUseCase(authRepository)

        val factory = object : ViewModelProvider.Factory {
            @Suppress("UNCHECKED_CAST")
            override fun <T : ViewModel> create(modelClass: Class<T>): T {
                return LoginViewModel(
                    loginUseCase,
                    validateCredentialsUseCase,
                    checkSessionUseCase
                ) as T
            }
        }

        setContent {
            val viewModel : LoginViewModel = viewModel(factory = factory)

            val uiState by viewModel.uiState.collectAsState()

            if (uiState.isUserLoggedIn) {
                HomeScreen()
            } else {
                LoginRoute(viewModel = viewModel)
            }
        }
    }
}
