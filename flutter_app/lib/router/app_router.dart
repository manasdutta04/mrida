import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/scan_result.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/phone_entry_screen.dart';
import '../screens/demo/demo_screen.dart';
import '../screens/field/field_detail_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/scan/camera_screen.dart';
import '../screens/scan/loading_screen.dart';
import '../screens/scan/result_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/map/field_map_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isProtected = !state.matchedLocation.startsWith('/login') &&
          state.matchedLocation != '/' &&
          state.matchedLocation != '/demo';
      if (user == null && isProtected) return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const PhoneEntryScreen()),
      GoRoute(
        path: '/login/otp',
        builder: (_, state) => OTPScreen(
          verificationId: (state.extra as String?) ?? '',
        ),
      ),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/scan/camera', builder: (_, __) => const CameraScreen()),
      GoRoute(path: '/scan/loading', builder: (_, __) => const LoadingScreen()),
      GoRoute(
        path: '/scan/result',
        builder: (_, state) => ResultScreen(result: state.extra as ScanResult?),
      ),
      GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
      GoRoute(path: '/map', builder: (_, __) => const FieldMapScreen()),
      GoRoute(
        path: '/field/:fieldId',
        builder: (_, state) =>
            FieldDetailScreen(fieldId: state.pathParameters['fieldId'] ?? ''),
      ),
      GoRoute(path: '/demo', builder: (_, __) => const DemoScreen()),
    ],
  );
});
