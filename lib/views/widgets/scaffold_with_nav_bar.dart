import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:texty/views/widgets/custom_bottom_bar.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/discover')) {
      return 0;
    }
    if (location.startsWith('/chat')) {
      return 1;
    }
    if (location.startsWith('/settings')) {
      return 2;
    }
    return 1; // Default to Chat
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/discover');
        break;
      case 1:
        context.go('/chat');
        break;
      case 2:
        context.go('/settings');
        break;
    }
  }
}
