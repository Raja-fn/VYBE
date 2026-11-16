import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/floating_nav_bar.dart';
import '../../credits/presentation/credits_providers.dart';

/// Bottom navigation for the seeker: Discover, Chats, Bookings, Profile.
/// Also starts listening for store purchases, so one left unfinished last
/// time is confirmed with the server after sign-in.
class HomeShell extends ConsumerWidget {
  const HomeShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(purchaseFlowProvider, (_, _) {});
    final l10n = context.l10n;
    return Scaffold(
      body: shell,
      bottomNavigationBar: FloatingNavBar(
        currentIndex: shell.currentIndex,
        onSelected: (index) => shell.goBranch(index, initialLocation: index == shell.currentIndex),
        items: [
          FloatingNavItem(icon: Icons.explore_outlined, label: l10n.navDiscover),
          FloatingNavItem(icon: Icons.chat_bubble_outline, label: l10n.navChats),
          FloatingNavItem(icon: Icons.calendar_today_outlined, label: l10n.navBookings),
          FloatingNavItem(icon: Icons.person_outline, label: l10n.navProfile),
        ],
      ),
    );
  }
}
