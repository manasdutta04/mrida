import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/scan_result.dart';
import '../screens/auth/phone_entry_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/field/field_detail_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/scan/camera_screen.dart';
import '../screens/scan/loading_screen.dart';
import '../screens/scan/result_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/map/field_map_screen.dart';
import '../widgets/modern_nav_bar.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/welcome',
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isAuthFlow = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation == '/welcome';

      if (user == null && !isAuthFlow) {
        return '/welcome';
      }
      
      if (user != null && isAuthFlow) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, __) => const PhoneEntryScreen()),
      
      // Universal Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            extendBody: true,
            bottomNavigationBar: ModernNavBar(
              activeIndex: navigationShell.currentIndex,
              onItemSelected: (index) => navigationShell.goBranch(index),
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (_, __) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/history', builder: (_, __) => const HistoryScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/scan/camera', builder: (_, __) => const CameraScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/map', builder: (_, __) => const FieldMapScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen())],
          ),
        ],
      ),
      
      // Secondary routes (outside shell if needed, or inside if they need nav)
      GoRoute(path: '/scan/loading', builder: (_, __) => const LoadingScreen()),
      GoRoute(
        path: '/scan/result',
        builder: (_, state) => ResultScreen(result: state.extra as ScanResult?),
      ),
      GoRoute(
        path: '/field/:fieldId',
        builder: (_, state) =>
            FieldDetailScreen(fieldId: state.pathParameters['fieldId'] ?? ''),
      ),
    ],
  );
});
