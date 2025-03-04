import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/stand_details_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/stand_allocation_screen.dart';

void main() {
  runApp(const AfricanHousingShow());
}

class AfricanHousingShow extends StatelessWidget {
  const AfricanHousingShow({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'African Housing Show',
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      //   visualDensity: VisualDensity.adaptivePlatformDensity,
      //   fontFamily: 'Roboto',
      // ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/main': (context) => const MainNavigationScreen(),
        '/main-admin': (context) => const MainNavigationScreen(isAdmin: true),
        '/stand-details': (context) => const StandDetailsScreen(),
        '/admin-login': (context) => const AdminLoginScreen(),
        '/stand-allocation': (context) => const StandAllocationScreen(),
      },
    );
  }
}
