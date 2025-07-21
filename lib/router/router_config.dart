import 'package:go_router/go_router.dart';
import 'package:music_app/features/home/views/home_page.dart';
import 'package:music_app/features/splash_screen/views/splash_screen.dart';
import 'package:music_app/router/router_constants.dart';


final GoRouter _router = GoRouter(
  initialLocation: '/',
  
  routes: [
    // ✅ Splash
    GoRoute(
      path: '/splash',
      name: RouterConstants.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      name: RouterConstants.home,
      builder: (context, state) => const HomePage(),
    ),

  ],
);

GoRouter get router => _router;
