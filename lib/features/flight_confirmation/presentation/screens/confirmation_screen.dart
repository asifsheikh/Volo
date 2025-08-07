import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../../models/confirmation_args.dart';
import '../../../../theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/weather/presentation/providers/weather_provider.dart';

// Global flag to track if confetti has been shown for the current journey
bool _hasShownConfettiForJourney = false;

// Global function to reset confetti flag when starting a new journey
void resetConfettiForNewJourney() {
  _hasShownConfettiForJourney = false;
}

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
  bool _weatherLoaded = false;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    // Load weather data automatically after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeatherData();
    });
  }

  void _initializeControllers() {
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _leftConfettiController = ConfettiController(duration: const Duration(seconds: 3));
    _rightConfettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Only trigger confetti if it hasn't been shown for this journey
    if (!_hasShownConfettiForJourney) {
      _hasShownConfettiForJourney = true;
      
      // Trigger bottom confetti after the frame is rendered
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _playConfetti(includeCenter: false);
        });
      });
    }
  }

  void _loadWeatherData() {
    if (!_weatherLoaded) {
      final args = widget.args;
      final iataCodes = [args.departureAirportCode, args.arrivalAirportCode];
      
      print('Confirmation Debug: Auto-loading weather for IATA codes: $iataCodes');
      
      final globalWeatherNotifier = ref.read(globalWeatherNotifierProvider.notifier);
      globalWeatherNotifier.loadWeatherData(iataCodes);
      
      setState(() {
        _weatherLoaded = true;
      });
    }
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
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = screenHeight * 0.5; // 50% of screen height
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          final hasContacts = widget.args.contactNames.isNotEmpty;
          
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
                                      _buildCityBanner(
                                        imageUrl: widget.args.departureImage.isNotEmpty
                                            ? widget.args.departureImage
                                            : widget.args.departureThumbnail.isNotEmpty
                                                ? widget.args.departureThumbnail
                                                : 'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=400&h=400&fit=crop',
                                        city: widget.args.fromCity,
                                        airportCode: widget.args.departureAirportCode,
                                        icon: Icons.flight_takeoff,
                                        isDeparture: true,
                                      ),
                                      _buildCityBanner(
                                        imageUrl: widget.args.arrivalImage.isNotEmpty
                                            ? widget.args.arrivalImage
                                            : widget.args.arrivalThumbnail.isNotEmpty
                                                ? widget.args.arrivalThumbnail
                                                : 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=400&h=400&fit=crop',
                                        city: widget.args.toCity,
                                        airportCode: widget.args.arrivalAirportCode,
                                        icon: Icons.flight_land,
                                        isDeparture: false,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Content below banner
                          SliverToBoxAdapter(
                            child: Container(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: isShortContent ? MainAxisAlignment.center : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Title
                                  Text(
                                    "You're all set!",
                                    style: AppTheme.headlineLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Enhanced Subtitle
                                  Column(
                                    children: [
                                      Text(
                                        widget.args.contactNames.isNotEmpty
                                            ? "We'll handle the updates to your closed family members from now on."
                                            : "We'll take care of your flight notifications from now on.",
                                        style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      
                                      // Enhanced Alert Information
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: AppTheme.cardDecoration.copyWith(
                                          color: AppTheme.background,
                                          border: Border.all(color: AppTheme.borderPrimary),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.notifications_active,
                                                  size: 18,
                                                  color: AppTheme.primary,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    'Real-time alerts will be sent via WhatsApp',
                                                    style: AppTheme.titleSmall,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            _buildConfirmationAlertItem('✈️ Flight plan confirmation'),
                                            _buildConfirmationAlertItem('🛫 Departure (boarding & takeoff)'),
                                            _buildConfirmationAlertItem('🛬 Arrival and landing'),
                                            _buildConfirmationAlertItem('⏰ Delays with updated times'),
                                            _buildConfirmationAlertItem('❌ Cancellations'),
                                            _buildConfirmationAlertItem('🔄 Diversions'),
                                            _buildConfirmationAlertItem('🚪 Gate changes'),
                                            _buildConfirmationAlertItem('📋 Schedule updates'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                  
                                  // Notifying card - only show when contacts are added
                                  if (widget.args.contactNames.isNotEmpty) ...[
                                    Container(
                                      width: double.infinity,
                                      decoration: AppTheme.elevatedCardDecoration,
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            // Generic people icon
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: AppTheme.background,
                                                borderRadius: BorderRadius.circular(24),
                                              ),
                                              child: const Icon(
                                                Icons.people,
                                                color: AppTheme.textSecondary,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            
                                            // Contact names
                                            Text(
                                              _formatContactNames(widget.args.contactNames),
                                              style: AppTheme.titleLarge,
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 12),
                                            
                                            // WhatsApp notification text
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.message,
                                                  color: AppTheme.success,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'will be notified via WhatsApp',
                                                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                  ],
                                  
                                  // CTA Button - only include in scrollable content when there are contacts
                                  if (hasContacts) ...[
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.of(context).popUntil((route) => route.isFirst);
                                        },
                                        style: AppTheme.primaryButton,
                                        icon: Text(
                                          "✈️",
                                          style: AppTheme.titleLarge,
                                        ),
                                        label: const Text("Let's go!"),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Confetti overlays and back button (unchanged)
                      // Center confetti animation
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          height: 300,
                          child: Center(
                            child: ConfettiWidget(
                              confettiController: _confettiController ?? ConfettiController(duration: const Duration(seconds: 3)),
                              blastDirection: pi / 2,
                              maxBlastForce: 5,
                              minBlastForce: 2,
                              emissionFrequency: 0.05,
                              numberOfParticles: 50,
                              gravity: 0.1,
                              colors: [
                                AppTheme.success,
                                AppTheme.primary,
                                AppTheme.warning,
                                AppTheme.destructive,
                                AppTheme.secondary,
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Bottom left confetti animation
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: ConfettiWidget(
                            confettiController: _leftConfettiController ?? ConfettiController(duration: const Duration(seconds: 3)),
                            blastDirection: -pi / 4,
                            maxBlastForce: 3,
                            minBlastForce: 1,
                            emissionFrequency: 0.03,
                            numberOfParticles: 20,
                            gravity: 0.05,
                            colors: [
                              AppTheme.success,
                              AppTheme.primary,
                              AppTheme.warning,
                              AppTheme.destructive,
                              AppTheme.secondary,
                            ],
                          ),
                        ),
                      ),
                      
                      // Bottom right confetti animation
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: ConfettiWidget(
                              confettiController: _rightConfettiController ?? ConfettiController(duration: const Duration(seconds: 3)),
                              blastDirection: -3 * pi / 4,
                              maxBlastForce: 3,
                              minBlastForce: 1,
                              emissionFrequency: 0.03,
                              numberOfParticles: 20,
                              gravity: 0.05,
                                                              colors: [
                                  AppTheme.success,
                                  AppTheme.primary,
                                  AppTheme.warning,
                                  AppTheme.destructive,
                                  AppTheme.secondary,
                                ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Back button (top left) - positioned above everything
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 16,
                        left: 16,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: AppTheme.cardDecoration.copyWith(
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                      
                      // Confetti icon (top right) - positioned above everything
                      if (kDebugMode)
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 16,
                          right: 16,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: AppTheme.cardDecoration.copyWith(
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Text(
                                "🎉",
                                style: TextStyle(fontSize: 18),
                              ),
                              onPressed: () {
                                _playConfetti(includeCenter: true);
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Bottom pinned CTA - only show when content is short (no contacts)
              if (isShortContent)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowPrimary,
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
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          style: AppTheme.primaryButton,
                          icon: const Text(
                            "✈️",
                            style: TextStyle(fontSize: 20),
                          ),
                          label: const Text("Let's go!"),
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
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityBanner({
    required String imageUrl,
    required String city,
    required String airportCode,
    required IconData icon,
    required bool isDeparture,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {},
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isDeparture ? Alignment.centerLeft : Alignment.centerRight,
              end: isDeparture ? Alignment.centerRight : Alignment.centerLeft,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.transparent,
              ],
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: AppTheme.textOnPrimary,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      airportCode.toUpperCase(),
                      style: AppTheme.headlineLarge.copyWith(
                        color: AppTheme.textOnPrimary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildWeatherInfo(airportCode),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    city.toUpperCase(),
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.textOnPrimary,
                      letterSpacing: 1.0,
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

  Widget _buildWeatherInfo(String airportCode) {
    return Consumer(
      builder: (context, ref, child) {
        final globalWeather = ref.watch(globalWeatherNotifierProvider);
        final weather = globalWeather[airportCode];
        
        print('Confirmation Weather Debug: Building weather for $airportCode, weather data: ${weather != null ? 'available' : 'null'}');
        
        if (weather != null) {
          // Just show temperature with simple formatting
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '${weather.current.temperature.round()}°C',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.textOnPrimary,
                letterSpacing: 0.5,
              ),
            ),
          );
        } else {
          // Show nothing when weather data is not available
          print('Confirmation Weather Debug: No weather data for $airportCode, showing SizedBox.shrink()');
          return const SizedBox.shrink();
        }
      },
    );
  }
}