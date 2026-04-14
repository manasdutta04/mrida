import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

import '../models/scan_result.dart';
import '../screens/auth/phone_entry_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/field/add_field_screen.dart';
import '../screens/field/field_detail_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/scan/camera_screen.dart';
import '../screens/scan/loading_screen.dart';
import '../screens/scan/result_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/map/field_map_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/support/about_screen.dart';
import '../screens/settings/support/help_center_screen.dart';
import '../screens/settings/support/terms_screen.dart';
import '../screens/settings/support/privacy_screen.dart';
import '../widgets/modern_nav_bar.dart';
import '../widgets/universal_app_bar.dart';

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

      // Universal Navigation Shell (4 persistent tabs)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // Map shell index to navbar index
          int getNavIndex(int shellIndex) {
            if (shellIndex < 2) return shellIndex;
            return shellIndex + 1; // Skip index 2 (Scan)
          }

          return Scaffold(
            backgroundColor: MridaColors.surface,
            body: Column(
              children: [
                UniversalAppBar(),
                Expanded(child: navigationShell),
              ],
            ),
            extendBody: true,
            bottomNavigationBar: ModernNavBar(
              activeIndex: getNavIndex(navigationShell.currentIndex),
              onItemSelected: (index) {
                if (index == 2) {
                  context.push('/scan/camera');
                } else {
                  // Map navbar index to shell index
                  int shellIndex = index > 2 ? index - 1 : index;
                  navigationShell.goBranch(shellIndex);
                }
              },
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, __) => const HomeScreen())
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                  path: '/history', builder: (_, __) => const HistoryScreen())
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/map', builder: (_, __) => const FieldMapScreen())
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                  path: '/profile', builder: (_, __) => const ProfileScreen())
            ],
          ),
        ],
      ),

      // Full-screen Scan Flow (outside shell)
      GoRoute(
        path: '/scan/camera',
        builder: (_, state) => CameraScreen(
          fieldId: state.uri.queryParameters['fieldId'],
        ),
      ),
      GoRoute(path: '/scan/loading', builder: (_, __) => const LoadingScreen()),
      GoRoute(
        path: '/scan/result',
        builder: (_, state) => ResultScreen(result: state.extra as ScanResult?),
      ),

      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
        routes: [
          GoRoute(path: 'about', builder: (_, __) => const AboutScreen()),
          GoRoute(path: 'help', builder: (_, __) => const HelpCenterScreen()),
          GoRoute(path: 'terms', builder: (_, __) => const TermsScreen()),
          GoRoute(path: 'privacy', builder: (_, __) => const PrivacyScreen()),
        ],
      ),

      GoRoute(path: '/field/add', builder: (_, __) => const AddFieldScreen()),

      GoRoute(
        path: '/field/:fieldId',
        builder: (_, state) =>
            FieldDetailScreen(fieldId: state.pathParameters['fieldId'] ?? ''),
      ),
    ],
  );
});
