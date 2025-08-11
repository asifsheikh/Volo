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
        // Header section with greeting
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
        
        // Centered content area with illustration and button
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hero illustration
                Container(
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
                
                const SizedBox(height: 32),
                
                // Add Flight button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SizedBox(
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