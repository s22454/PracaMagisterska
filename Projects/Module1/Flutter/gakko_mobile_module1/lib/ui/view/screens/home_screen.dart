import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gakko_mobile_module1/data/repositories/auth_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          Semantics(
            label: 'logout_button',
            child: IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign out',
              onPressed: () async {
                final authRepository = AuthRepository();
                await authRepository.signOut();

                if (context.mounted) {
                  context.go('/signin');
                }
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: Semantics(
          label: 'home_screen',
          child: const Text(
            'Home',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
