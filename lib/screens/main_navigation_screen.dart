import 'package:flutter/material.dart';
import '../widgets/buttom_nav_bar.dart';
import 'home_screen.dart';
import 'stand_list_screen.dart';
import 'ar_navigation_screen.dart';
import 'admin/admin_home_screen.dart';
import 'about_screen.dart';
import '../widgets/error_dialog.dart';

class MainNavigationScreen extends StatefulWidget {
  final bool isAdmin;

  const MainNavigationScreen({
    super.key,
    this.isAdmin = false,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _initializeScreens();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _initializeScreens() {
    _screens = [
      const HomeScreen(),
      const StandListScreen(),
      Container(), // Placeholder for AR screen
      if (widget.isAdmin) const AdminHomeScreen(),
      const AboutScreen(),
    ];
  }

  Future<void> _handleNavigation(int index) async {
    // Check if trying to access AR screen
    if (index == 2) {
      // Show dialog explaining AR navigation needs a stand selection
      await ErrorDialog.show(
        context: context,
        title: 'Select a Stand',
        message:
            'Please select a stand from the search screen to start AR navigation.',
        buttonText: 'OK',
      );
      // Navigate to search screen instead
      if (!mounted) return;
      setState(() => _currentIndex = 1);
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    // Adjust index for non-admin users to skip admin screen
    final adjustedIndex = (!widget.isAdmin && index > 2) ? index - 1 : index;

    if (!mounted) return;
    setState(() => _currentIndex = adjustedIndex);
    _pageController.animateToPage(
      adjustedIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int page) {
    if (page != 2) {
      // Don't update state for AR screen
      setState(() => _currentIndex = page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          // If not on home screen, go to home screen
          _handleNavigation(0);
          return false;
        }
        return true; // Allow app to be closed if on home screen
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Disable swipe
          onPageChanged: _onPageChanged,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _handleNavigation,
          isAdmin: widget.isAdmin,
        ),
      ),
    );
  }
}
