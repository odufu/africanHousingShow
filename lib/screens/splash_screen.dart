import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/modern_button.dart';
import '../services/location_service.dart';
import '../widgets/error_dialog.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final LocationService _locationService = LocationService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _checkPermissionsAndNavigate();
  }

  Future<void> _checkPermissionsAndNavigate() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Check location services
      final serviceEnabled = await _locationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        await ErrorDialog.show(
          context: context,
          title: 'Location Services Disabled',
          message: 'Please enable location services to use the app.',
          buttonText: 'OK',
        );
        setState(() => _isLoading = false);
        return;
      }

      // Request location permission
      final permission = await _locationService.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        await ErrorDialog.show(
          context: context,
          title: 'Location Permission Required',
          message:
              'This app needs location permission to guide you through the exhibition.',
          buttonText: 'OK',
        );
        setState(() => _isLoading = false);
        return;
      }

      // Add a delay to show the splash screen
      await Future.delayed(const Duration(seconds: 2));

      // Navigate to main screen
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      await ErrorDialog.show(
        context: context,
        title: 'Error',
        message: 'Failed to initialize app: $e',
        buttonText: 'Retry',
      );
      _checkPermissionsAndNavigate();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          children: [
                            // Logo or Icon
                            Icon(
                              Icons.location_on,
                              size: 100,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 24),
                            // App Title
                            const Text(
                              'African Housing Show',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Subtitle
                            const Text(
                              'AR Navigation Guide',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isLoading) ...[
                      const SizedBox(height: 48),
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Admin Login Button at bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.pushReplacementNamed(
                          context, '/admin-login'),
                  child: const Text(
                    'Admin Login',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
