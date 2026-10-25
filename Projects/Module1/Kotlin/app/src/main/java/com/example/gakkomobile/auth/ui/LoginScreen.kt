package com.example.gakkomobile.auth.ui

import androidx.biometric.BiometricPrompt
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import com.example.gakkomobile.R.drawable.pjatk_logo
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics

@Preview(showBackground = true)
@Composable
fun LoginScreenPreview() {
    MaterialTheme {
        LoginScreen(
            uiState = LoginUiState(
                email = "",
                password = "",
                isLoading = false,
                errorMessage = "Authentication error"
            ),
            onEmailChanged = {},
            onPasswordChanged = {},
            onSigningButtonPress = {}
        )
    }
}

@Composable
fun LoginRoute(
    viewModel: LoginViewModel
) {
    val uiState by viewModel.uiState.collectAsState()

    if (uiState.hasSavedSession) {
        val context = LocalContext.current

        Column(
            modifier = Modifier.fillMaxSize(),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Button(
                onClick = {
                    val activity = context as? FragmentActivity
                    if (activity != null) {
                        launchBiometricPrompt(
                            activity = activity,
                            onSuccess = { viewModel.onBiometricLoginSuccess() },
                            onError = {}
                        )
                    }
                }
            ) {
                Text("Sign in using biometric authentication")
            }

            TextButton(onClick = { viewModel.clearSavedSession() }) {
                Text("Use password")
            }
        }
    } else {
        LoginScreen(
            uiState = uiState,
            onEmailChanged = { viewModel.onEmailChanged(it) },
            onPasswordChanged = { viewModel.onPasswordChanged(it) },
            onSigningButtonPress = { viewModel.login() }
        )
    }
}

@Composable
fun LoginScreen(
    uiState: LoginUiState,
    onEmailChanged: (String) -> Unit,
    onPasswordChanged: (String) -> Unit,
    onSigningButtonPress: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(if (!uiState.isLoading) Color.White else Color.Gray),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Logo
        Image(
            painter = painterResource(id = pjatk_logo),
            contentDescription = "PJATK logo",
            modifier = Modifier
                .size(150.dp)
                .padding(bottom = 20.dp)
        )

        // Title
        Text(
            text = "POLSKO-JAPOŃSKA AKADEMIA \n" + "TECHNIK KOMPUTEROWYCH",
            textAlign = TextAlign.Center,
            modifier = Modifier
                .padding(bottom = 40.dp)
        )

        // Email input
        OutlinedTextField(
            value = uiState.email,
            onValueChange = onEmailChanged,
            label = { Text("E-mail:") },
            placeholder = { Text("e-mail...") },
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 20.dp, start = 40.dp, end = 40.dp)
                .semantics { contentDescription = "email_input" },
            enabled = !uiState.isLoading
        )

        // Password input
        OutlinedTextField(
            value = uiState.password,
            onValueChange = onPasswordChanged,
            label = { Text("Password:") },
            placeholder = { Text("password...") },
            visualTransformation = PasswordVisualTransformation(),
            keyboardOptions = KeyboardOptions(
                keyboardType = KeyboardType.Password,
                autoCorrectEnabled = false
            ),
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 15.dp, start = 40.dp, end = 40.dp)
                .semantics { contentDescription = "password_input" },
            enabled = !uiState.isLoading
        )

        // Error message
        Text(
            text = uiState.errorMessage ?: "",
            color = MaterialTheme.colorScheme.error,
            style = MaterialTheme.typography.bodyMedium,
            modifier = Modifier
                .padding(bottom = 20.dp)
        )

        // Button
        Button(
            onClick = onSigningButtonPress,
            enabled = !uiState.isLoading,
            modifier = Modifier
                .fillMaxWidth()
                .height(50.dp)
                .padding(start = 80.dp, end = 80.dp)
                .semantics { contentDescription = "login_button" }
        ) {
            Text("Sign in")
        }
    }
}

fun launchBiometricPrompt(
    activity: FragmentActivity,
    onSuccess: () -> Unit,
    onError: (String) -> Unit
) {
    val executor = ContextCompat.getMainExecutor(activity)
    val biometricPrompt = BiometricPrompt(
        activity,
        executor,
        object : BiometricPrompt.AuthenticationCallback() {
            override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                super.onAuthenticationSucceeded(result)
                onSuccess()
            }

            override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                super.onAuthenticationError(errorCode, errString)
                onError(errString.toString())
            }
        }
    )

    val promptInfo = BiometricPrompt.PromptInfo.Builder()
        .setTitle("Biometric authentication")
        .setSubtitle("Sign in using biometric authentication")
        .setNegativeButtonText("Use password")
        .build()

    biometricPrompt.authenticate(promptInfo)
}