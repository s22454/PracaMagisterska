import 'package:flutter/material.dart';
import 'package:gakko_mobile_module1/data/models/auth_request.dart';
import 'package:gakko_mobile_module1/ui/view_model/sign_in_view_model.dart';
import 'package:go_router/go_router.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final SignInViewModel _viewModel = SignInViewModel();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel.checkSavedToken();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 50.0,
              vertical: 25.0,
            ),
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // LOGO
                    Image.asset(
                      'assets/pjatk_logo.png',
                      height: 180,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // TITLE
                    const Text(
                      'POLSKO-JAPOŃSKA AKADEMIA\nTECHNIK KOMPUTEROWYCH',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        height: 1.3,
                        letterSpacing: 0.2,
                      ),
                    ),

                    // EMAIL
                    const SizedBox(height: 25),
                    _buildTextField(
                      label: 'E-mail',
                      hint: 'e-mail...',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      semanticLabel: 'email_input',
                    ),

                    // PASSWORD
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Password',
                      hint: 'password...',
                      controller: _passwordController,
                      obscureText: true,
                      semanticLabel: 'password_input',
                    ),
                    const SizedBox(height: 15),

                    if (_viewModel.errorMessage != null) ...[
                      Text(
                        _viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                    ] else ...[
                      const SizedBox(height: 30),
                    ],

                    // SIGN IN BUTTON
                    Semantics(
                      label: 'login_button',
                      child: SizedBox(
                        width: 200,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F76E6),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _viewModel.isLoading
                              ? null
                              : () async {
                                  final request = AuthRequest(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  );

                                  final success = await _viewModel
                                      .signInWithCredentials(request);

                                  if (success && context.mounted) {
                                    context.go('/');
                                  }
                                },
                          child: _viewModel.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Sign in',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    if (_viewModel.hasSavedToken) ...[
                      Semantics(
                        label: 'biometric_button',
                        child: SizedBox(
                          width: 200,
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2F76E6),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              final success = await _viewModel
                                  .signInWithBiometric();
                              if (success && context.mounted) {
                                context.go('/');
                              }
                            },
                            child: _viewModel.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Biometric sign in',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String semanticLabel,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B6B6B),
          ),
        ),
        const SizedBox(height: 5),
        Semantics(
          label: semanticLabel,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Color(0xFFAAAAAA),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD6D6D6), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF2F76E6),
                  width: 1.5,
                ),
              ),
              fillColor: Colors.transparent,
              filled: true,
            ),
          ),
        ),
      ],
    );
  }
}
