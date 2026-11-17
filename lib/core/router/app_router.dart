import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/booking/domain/booking_models.dart';
import '../../features/booking/presentation/book_spot_screen.dart';
import '../../features/booking/presentation/bookings_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/chat/presentation/chats_screen.dart';
import '../../features/credits/presentation/credits_screen.dart';
import '../../features/discover/domain/companion_summary.dart';
import '../../features/discover/presentation/companion_profile_screen.dart';
import '../../features/discover/presentation/discover_screen.dart';
import '../../features/discover/presentation/free_now_screen.dart';
import '../../features/discover/presentation/saved_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/map/presentation/map_screen.dart';
import '../../features/onboarding/domain/onboarding_redirect.dart';
import '../../features/onboarding/presentation/rules_screen.dart';
import '../../features/onboarding/presentation/session_providers.dart';
import '../../features/onboarding/presentation/status_screens.dart';
import '../../features/preferences/presentation/preferences_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/my_profile_screen.dart';
import '../../features/verification/presentation/verification_screen.dart';
import 'routes.dart';
import 'screens/not_found_screen.dart';
import 'screens/start_screen.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // Re-run redirects whenever the session stage or consent changes.
  final refresh = ValueNotifier<int>(0);
  ref
    ..listen(sessionStageProvider, (_, _) => refresh.value++)
    ..listen(consentGivenProvider, (_, _) => refresh.value++)
    ..onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.start,
    refreshListenable: refresh,
    redirect: (context, state) => onboardingRedirect(
      stage: ref.read(sessionStageProvider),
      consentGiven: ref.read(consentGivenProvider),
      location: state.matchedLocation,
    ),
    routes: [
      GoRoute(path: AppRoutes.start, builder: (context, state) => const StartScreen()),
      GoRoute(path: AppRoutes.rules, builder: (context, state) => const RulesScreen()),
      GoRoute(path: AppRoutes.verify, builder: (context, state) => const VerificationScreen()),
      GoRoute(path: AppRoutes.preferences, builder: (context, state) => const PreferencesScreen()),
      GoRoute(path: AppRoutes.suspended, builder: (context, state) => const SuspendedScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.discover,
                builder: (context, state) => const DiscoverScreen(),
                routes: [
                  GoRoute(path: 'free-now', builder: (context, state) => const FreeNowScreen()),
                  GoRoute(
                    path: 'map',
                    builder: (context, state) => MapScreen(
                      companionUid: state.uri.queryParameters['companion'],
                      plan: _plan(state.uri.queryParameters['plan']),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.chats, builder: (context, state) => const ChatsScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.bookings, builder: (context, state) => const BookingsScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const MyProfileScreen(),
                routes: [
                  GoRoute(path: 'saved', builder: (context, state) => const SavedScreen()),
                  GoRoute(path: 'edit', builder: (context, state) => const EditProfileScreen()),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.companionPattern,
        builder: (context, state) => CompanionProfileScreen(uid: state.pathParameters['uid']!),
      ),
      GoRoute(path: AppRoutes.credits, builder: (context, state) => const CreditsScreen()),
      GoRoute(
        path: AppRoutes.chatPattern,
        builder: (context, state) => ChatScreen(chatId: state.pathParameters['chatId']!),
      ),
      GoRoute(
        path: AppRoutes.pickSpotPath,
        builder: (context, state) => MapScreen(
          companionUid: state.uri.queryParameters['companion'],
          plan: _plan(state.uri.queryParameters['plan']),
          pickMode: true,
        ),
      ),
      GoRoute(
        path: AppRoutes.bookPath,
        builder: (context, state) {
          final query = state.uri.queryParameters;
          final companion = query['companion'];
          if (companion == null) return const NotFoundScreen();
          return BookSpotScreen(
            companionUid: companion,
            plan: _plan(query['plan']),
            initialVenueId: query['venue'],
            kind: query['kind'] == BookingKind.instant.name ? BookingKind.instant : BookingKind.scheduled,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}

PlanType? _plan(String? name) => PlanType.values.where((p) => p.name == name).firstOrNull;
