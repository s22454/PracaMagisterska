import 'package:flutter/material.dart';
import 'package:gakko_mobile_module1/data/repositories/auth_repository.dart';
import 'package:gakko_mobile_module1/ui/view/navigation/app_router.dart';

void main() {
  final authRepository = AuthRepository();
  final appRouter = AppRouter(authRepository);

  runApp(GakkoApp(appRouter: appRouter));
}

class GakkoApp extends StatelessWidget {
  final AppRouter appRouter;

  const GakkoApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gakko Mobile',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter.router,
    );
  }
}
