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
      body: _TabTransition(index: shell.currentIndex, child: shell),
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

/// Plays a short fade-and-settle whenever the tab changes. The tabs keep their
/// state (scroll position, loaded data); only the newly shown one animates in.
class _TabTransition extends StatefulWidget {
  const _TabTransition({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_TabTransition> createState() => _TabTransitionState();
}

class _TabTransitionState extends State<_TabTransition> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    value: 1,
  );
  late final Animation<double> _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  late final Animation<double> _scale = Tween<double>(
    begin: 0.97,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void didUpdateWidget(_TabTransition old) {
    super.didUpdateWidget(old);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (old.index != widget.index && !reduceMotion) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: ScaleTransition(scale: _scale, child: widget.child),
  );
}
