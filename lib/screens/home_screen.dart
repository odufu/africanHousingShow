import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/modern_button.dart';
import '../services/data_service.dart';
import '../services/location_service.dart';
import '../models/stand_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DataService _dataService = DataService();
  final LocationService _locationService = LocationService();
  List<Stand> _nearbyStands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNearbyStands();
  }

  Future<void> _loadNearbyStands() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final position = await _locationService.getCurrentLocation();
      if (!mounted) return;

      if (position != null) {
        final stands = await _dataService.getNearbyStands(
          position.latitude,
          position.longitude,
          1000, // Search within 1km radius
        );
        if (!mounted) return;

        setState(() {
          _nearbyStands = stands;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      print('Error loading nearby stands: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'African Housing Show',
        showBackButton: false, // This will show the admin login button
      ),
      body: RefreshIndicator(
        onRefresh: _loadNearbyStands,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                const Text(
                  'Welcome to\nAfrican Housing Show',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore exhibition stands using AR navigation',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                ModernButton(
                  text: 'Find Stands',
                  icon: Icons.search,
                  onPressed: () {
                    final bottomNavBar = context
                        .findAncestorWidgetOfExactType<BottomNavigationBar>();
                    if (bottomNavBar != null) {
                      bottomNavBar.onTap!(1); // Navigate to search tab
                    }
                  },
                  isFullWidth: true,
                ),
                const SizedBox(height: 16),
                ModernOutlinedButton(
                  text: 'Start AR Navigation',
                  icon: Icons.view_in_ar,
                  onPressed: () {
                    final bottomNavBar = context
                        .findAncestorWidgetOfExactType<BottomNavigationBar>();
                    if (bottomNavBar != null) {
                      bottomNavBar.onTap!(2); // Navigate to AR tab
                    }
                  },
                  isFullWidth: true,
                ),
                const SizedBox(height: 32),

                // Nearby Stands Section
                const Text(
                  'Nearby Stands',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _nearbyStands.isEmpty
                        ? _buildEmptyState()
                        : Column(
                            children: _nearbyStands
                                .map((stand) => _buildStandCard(stand))
                                .toList(),
                          ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No nearby stands found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try moving closer to the exhibition area',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandCard(Stand stand) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/stand-details',
          arguments: stand,
        ),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.store,
                  size: 30,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stand.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stand.exhibitorName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
