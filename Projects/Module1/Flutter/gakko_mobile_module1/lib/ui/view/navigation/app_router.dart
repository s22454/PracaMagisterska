import 'package:gakko_mobile_module1/data/repositories/auth_repository.dart';
import 'package:gakko_mobile_module1/ui/view/screens/home_screen.dart';
import 'package:gakko_mobile_module1/ui/view/screens/sign_in_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final AuthRepository _authRepository;

  AppRouter(this._authRepository);

  late final GoRouter router = GoRouter(
    initialLocation: '/signin',
    routes: [
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen()
      ),
    ],
    redirect: (context, state) async {
      final bool isSignedIn = await _authRepository.isSignedIn();

      final bool isGoingToSignIn = state.matchedLocation == '/signin';

      if (!isSignedIn && !isGoingToSignIn) {
        return '/signin';
      }

      if (isSignedIn && isGoingToSignIn) {
        return '/';
      }

      return null;
    },
  );
}
