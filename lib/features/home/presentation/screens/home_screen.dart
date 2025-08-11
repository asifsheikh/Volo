import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_theme.dart';
import '../../../../features/add_flight/add_flight_screen.dart';
import '../providers/home_provider.dart';

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
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Hey, ${homeState.username} 👋',
              style: AppTheme.headlineLarge.copyWith(fontWeight: FontWeight.w400),
            ),
          ),
        ),
        
        // Hero illustration with seamless background integration
        Expanded(
          flex: 2,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 300,
                maxHeight: 300,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/home.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        
        // Main content area with improved visual hierarchy
        Expanded(
          flex: 3,
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
                  style: AppTheme.bodyMediumSecondary,
                ),
                
                const SizedBox(height: 48),
                
                // Primary CTA Button - Most prominent element
                SizedBox(
                  width: double.infinity,
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
                      size: 24,
                    ),
                    label: const Text('Add Your Flight'),
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
                    style: AppTheme.linkStyle.copyWith(
                      color: AppTheme.textSecondary,
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
            style: AppTheme.primaryButton,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }


} 