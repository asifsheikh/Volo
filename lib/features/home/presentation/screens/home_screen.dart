import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../../../../theme/app_theme.dart';
import '../../../../features/add_flight/add_flight_screen.dart';
import '../../../../features/profile/presentation/screens/profile_screen.dart';
import '../providers/home_provider.dart';
import '../../domain/repositories/home_repository.dart';
import '../../data/repositories/home_repository_impl.dart';

/// Home Screen using Riverpod + Clean Architecture
class HomeScreen extends ConsumerStatefulWidget {
  final String username;
  
  const HomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final homeStateAsync = ref.watch(homeProviderProvider(widget.username));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: homeStateAsync.when(
          data: (homeState) => _buildHomeContent(homeState),
          loading: () => _buildLoadingContent(),
          error: (error, stackTrace) => _buildErrorContent(error.toString()),
        ),
      ),
    );
  }

  Widget _buildHomeContent(homeState) {
    return Column(
      children: [
        // Header section with greeting and profile
        Padding(
          padding: EdgeInsets.only(
            left: 24.0, 
            right: 24.0,
            top: MediaQuery.of(context).padding.top > 0 ? 16.0 : 24.0,
            bottom: 32.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Hey, ${homeState.username} 👋',
                  style: AppTheme.headlineLarge.copyWith(fontWeight: FontWeight.w400),
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToProfile(context, homeState),
                child: _buildProfileAvatar(homeState),
              ),
            ],
          ),
        ),
        
        // Main content area with improved visual hierarchy
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Main title - Secondary level prominence
                Text(
                  'Travel confidently—Volo updates your loved ones automatically',
                  textAlign: TextAlign.center,
                  style: AppTheme.headlineMedium,
                ),
                
                const SizedBox(height: 20),
                
                // Subtitle - Tertiary level (significantly de-emphasized)
                Text(
                  'Add your flight details and Volo will keep your family and friends updated in real time, so you can focus on your journey.',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary.withOpacity(0.8),
                  ),
                ),
                
                const SizedBox(height: 56),
                
                // Primary CTA Button - Most prominent element
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddFlightScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.flight_takeoff, 
                      color: Colors.white, 
                      size: 24,
                    ),
                    label: const Text(
                      'Add Your Flight',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    style: AppTheme.primaryButton,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Secondary link - Very subtle (optional secondary action)
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('How does Volo work? - Coming soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text(
                    'How does Volo work?',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary.withOpacity(0.7),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingContent() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorContent(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: AppTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
                      ElevatedButton(
              onPressed: () {
                ref.invalidate(homeProviderProvider(widget.username));
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  /// Navigate to profile screen with user data
  void _navigateToProfile(BuildContext context, homeState) {
    final repository = ref.read(homeRepositoryImplProvider);
    final phoneNumber = repository.getUserPhoneNumber() ?? 'Unknown';
    developer.log('HomeScreen: Navigating to profile with phone: $phoneNumber', name: 'VoloAuth');
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          username: homeState.username,
          phoneNumber: phoneNumber,
        ),
      ),
    ).then((_) {
      // Refresh profile picture when returning from profile screen
      ref.invalidate(homeProviderProvider(widget.username));
    });
  }

  Widget _buildProfileAvatar(homeState) {
    if (homeState.isLoadingProfile) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: AppTheme.cardBackground,
        child: CircularProgressIndicator(
          color: AppTheme.textSecondary,
        ),
      );
    }

    if (homeState.isOffline) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: AppTheme.cardBackground,
        child: Icon(
          Icons.signal_wifi_off,
          size: 28,
          color: AppTheme.textSecondary,
        ),
      );
    }

    if (homeState.profilePictureUrl != null) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: AppTheme.cardBackground,
        backgroundImage: NetworkImage(homeState.profilePictureUrl!),
      );
    }

    return CircleAvatar(
      radius: 28,
      backgroundColor: AppTheme.cardBackground,
      child: Icon(
        Icons.person,
        size: 28,
        color: AppTheme.textSecondary,
      ),
    );
  }
} 