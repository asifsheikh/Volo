import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../providers/flight_confirmation_provider.dart';
import '../../domain/entities/flight_confirmation_state.dart' as domain;
import '../../domain/usecases/get_confirmation_data.dart';
import '../../models/confirmation_args.dart';
import '../../../../features/weather/presentation/providers/weather_provider.dart';
import '../../../../features/weather/presentation/widgets/weather_city_card.dart';
import '../../../../features/weather/domain/entities/weather_state.dart' as weather_domain;

/// Flight Confirmation Screen using Riverpod + Clean Architecture
class ConfirmationScreen extends ConsumerStatefulWidget {
  final ConfirmationArgs args;

  const ConfirmationScreen({
    Key? key,
    required this.args,
  }) : super(key: key);

  @override
  ConsumerState<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends ConsumerState<ConfirmationScreen> {
  ConfettiController? _confettiController;
  ConfettiController? _leftConfettiController;
  ConfettiController? _rightConfettiController;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _leftConfettiController = ConfettiController(duration: const Duration(seconds: 3));
    _rightConfettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Reset confetti flag for new journey
    ref.read(getConfirmationDataProvider(widget.args).notifier).resetConfettiForNewJourney();
    
    // Trigger confetti after the frame is rendered
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _playConfetti(includeCenter: false);
      });
    });
  }

  @override
  void dispose() {
    _confettiController?.dispose();
    _leftConfettiController?.dispose();
    _rightConfettiController?.dispose();
    super.dispose();
  }

  void _playConfetti({bool includeCenter = false}) {
    // Ensure controllers are initialized
    if (_confettiController == null || _leftConfettiController == null || _rightConfettiController == null) {
      return;
    }
    
    // Stop all controllers first
    _confettiController!.stop();
    _leftConfettiController!.stop();
    _rightConfettiController!.stop();
    
    // Play bottom left and right confetti
    Future.delayed(const Duration(milliseconds: 50), () {
      _leftConfettiController!.play();
    });
    
    Future.delayed(const Duration(milliseconds: 100), () {
      _rightConfettiController!.play();
    });
    
    // Play center confetti only if requested (for test button)
    if (includeCenter) {
      _confettiController!.play();
    }
    
    // Mark confetti as shown
    ref.read(getConfirmationDataProvider(widget.args).notifier).markConfettiShown();
  }

  @override
  Widget build(BuildContext context) {
    final confirmationAsync = ref.watch(flightConfirmationProviderProvider(widget.args));
    
    return confirmationAsync.when(
      data: (confirmationState) => _buildConfirmationContent(confirmationState),
      loading: () => _buildLoadingContent(),
      error: (error, stackTrace) => _buildErrorContent(error.toString()),
    );
  }

  Widget _buildLoadingContent() {
    return const Scaffold(
      backgroundColor: Color(0xFFF7F8FA),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorContent(String error) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Confirmation',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(flightConfirmationProviderProvider(widget.args));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationContent(domain.FlightConfirmationState confirmationState) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = screenHeight * 0.5; // 50% of screen height
    
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          final hasContacts = confirmationState.contactNames.isNotEmpty;
          
          // Calculate if content will be short (no contacts) or long (with contacts)
          final isShortContent = !hasContacts;
          
          return Column(
            children: [
              // Scrollable content
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // This simulates user interaction which can help trigger animations
                    print('👆 User interaction detected');
                  },
                  child: Stack(
                    children: [
                      CustomScrollView(
                        slivers: [
                          // Sliver App Bar for the banner with fade effect
                          SliverAppBar(
                            expandedHeight: bannerHeight,
                            floating: false,
                            pinned: false,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            automaticallyImplyLeading: false,
                            flexibleSpace: FlexibleSpaceBar(
                              background: Stack(
                                children: [
                                  // Background Images
                                  Row(
                                    children: [
                                      // Departing City (Left 50%)
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(confirmationState.departureImage.isNotEmpty 
                                                  ? confirmationState.departureImage 
                                                  : confirmationState.departureThumbnail.isNotEmpty
                                                      ? confirmationState.departureThumbnail
                                                      : 'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=400&h=400&fit=crop'),
                                              fit: BoxFit.cover,
                                              onError: (exception, stackTrace) {
                                                // Fallback to gradient
                                              },
                                            ),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                                colors: [
                                                  Colors.black.withOpacity(0.4),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.flight_takeoff,
                                                    color: Colors.white,
                                                    size: 48,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    confirmationState.departureAirportCode.toUpperCase(),
                                                    style: GoogleFonts.inter(
                                                      fontWeight: FontWeight.w900,
                                                      fontSize: 32,
                                                      color: Colors.white,
                                                      letterSpacing: 1.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      // Arriving City (Right 50%)
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(confirmationState.arrivalImage.isNotEmpty 
                                                  ? confirmationState.arrivalImage 
                                                  : confirmationState.arrivalThumbnail.isNotEmpty
                                                      ? confirmationState.arrivalThumbnail
                                                      : 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=400&h=400&fit=crop'),
                                              fit: BoxFit.cover,
                                              onError: (exception, stackTrace) {
                                                // Fallback to gradient
                                              },
                                            ),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.centerRight,
                                                end: Alignment.centerLeft,
                                                colors: [
                                                  Colors.black.withOpacity(0.4),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.flight_land,
                                                    color: Colors.white,
                                                    size: 48,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    confirmationState.arrivalAirportCode.toUpperCase(),
                                                    style: GoogleFonts.inter(
                                                      fontWeight: FontWeight.w900,
                                                      fontSize: 32,
                                                      color: Colors.white,
                                                      letterSpacing: 1.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Confetti controllers
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: ConfettiWidget(
                                      confettiController: _leftConfettiController!,
                                      blastDirection: pi / 4,
                                      maxBlastForce: 5,
                                      minBlastForce: 2,
                                      emissionFrequency: 0.05,
                                      numberOfParticles: 20,
                                      gravity: 0.1,
                                    ),
                                  ),
                                  
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: ConfettiWidget(
                                      confettiController: _rightConfettiController!,
                                      blastDirection: -pi / 4,
                                      maxBlastForce: 5,
                                      minBlastForce: 2,
                                      emissionFrequency: 0.05,
                                      numberOfParticles: 20,
                                      gravity: 0.1,
                                    ),
                                  ),
                                  
                                  // Center confetti for testing
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: ConfettiWidget(
                                      confettiController: _confettiController!,
                                      blastDirection: pi / 2,
                                      maxBlastForce: 5,
                                      minBlastForce: 2,
                                      emissionFrequency: 0.05,
                                      numberOfParticles: 20,
                                      gravity: 0.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Main content
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Success Message
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF059393).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.check_circle,
                                                color: Color(0xFF059393),
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Trip Confirmed!',
                                                    style: GoogleFonts.inter(
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 20,
                                                      color: const Color(0xFF111827),
                                                    ),
                                                  ),
                                                  Text(
                                                    'Your flight has been successfully booked',
                                                    style: GoogleFonts.inter(
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 14,
                                                      color: const Color(0xFF6B7280),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Flight Details
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Flight Details',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: const Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'From',
                                                    style: GoogleFonts.inter(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 12,
                                                      color: const Color(0xFF6B7280),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    confirmationState.fromCity,
                                                    style: GoogleFonts.inter(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 16,
                                                      color: const Color(0xFF111827),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                              Icons.arrow_forward,
                                              color: Color(0xFF6B7280),
                                              size: 20,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'To',
                                                    style: GoogleFonts.inter(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 12,
                                                      color: const Color(0xFF6B7280),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    confirmationState.toCity,
                                                    style: GoogleFonts.inter(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 16,
                                                      color: const Color(0xFF111827),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Weather Section
                                  _buildWeatherSection(),
                                  
                                  if (hasContacts) ...[
                                    const SizedBox(height: 24),
                                    
                                    // Contacts Section
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.04),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Contacts Notified',
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: const Color(0xFF111827),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            _formatContactNames(confirmationState.contactNames),
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                              color: const Color(0xFF374151),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  
                                  const SizedBox(height: 24),
                                  
                                  // What's Next Section
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'What\'s Next?',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: const Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        _buildConfirmationAlertItem('You\'ll receive boarding passes 24 hours before departure'),
                                        _buildConfirmationAlertItem('Real-time flight updates will be sent to your contacts'),
                                        _buildConfirmationAlertItem('Check your email for booking confirmation'),
                                        _buildConfirmationAlertItem('Download the Volo app for mobile boarding passes'),
                                      ],
                                    ),
                                  ),
                                  
                                  // Bottom padding to account for the pinned button
                                  const SizedBox(height: 100),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Pinned Continue Button at bottom
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059393),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Let's go!",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "✈️",
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper method to format contact names smartly
  String _formatContactNames(List<String> fullNames) {
    if (fullNames.isEmpty) return '';
    if (fullNames.length == 1) {
      final parts = fullNames.first.split(' ');
      return parts.isNotEmpty ? parts.first : fullNames.first;
    }
    
    final firstNames = fullNames.map((name) {
      final parts = name.split(' ');
      return parts.isNotEmpty ? parts.first : name;
    }).toList();
    
    if (firstNames.length == 2) {
      return '${firstNames[0]} & ${firstNames[1]}';
    } else if (firstNames.length == 3) {
      return '${firstNames[0]}, ${firstNames[1]} & ${firstNames[2]}';
    } else {
      return '${firstNames[0]}, ${firstNames[1]} & ${firstNames.length - 2} others';
    }
  }

  /// Build individual alert item widget for confirmation screen
  Widget _buildConfirmationAlertItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF059393),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 13,
                color: const Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherSection() {
    // Get IATA codes for departure and arrival cities
    final iataCodes = [
      widget.args.departureAirportCode,
      widget.args.arrivalAirportCode,
    ];

    return Consumer(
      builder: (context, ref, child) {
        final weatherState = ref.watch(globalWeatherNotifierProvider);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weather at your destinations',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),
              _buildWeatherContent(weatherState),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeatherContent(Map<String, weather_domain.WeatherState> weatherState) {
    final departureWeather = weatherState[widget.args.departureAirportCode];
    final arrivalWeather = weatherState[widget.args.arrivalAirportCode];

    if (departureWeather == null && arrivalWeather == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (departureWeather != null)
          Expanded(
            child: WeatherCityCard(
              weather: departureWeather,
              isDeparture: true,
            ),
          ),
        if (departureWeather != null && arrivalWeather != null)
          const SizedBox(width: 12),
        if (arrivalWeather != null)
          Expanded(
            child: WeatherCityCard(
              weather: arrivalWeather,
              isDeparture: false,
            ),
          ),
      ],
    );
  }
} 