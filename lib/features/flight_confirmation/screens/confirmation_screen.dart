import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../models/confirmation_args.dart';

// Global flag to track if confetti has been shown for the current journey
bool _hasShownConfettiForJourney = false;

// Global function to reset confetti flag when starting a new journey
void resetConfettiForNewJourney() {
  _hasShownConfettiForJourney = false;
}

class ConfirmationScreen extends StatefulWidget {
  final ConfirmationArgs args;

  const ConfirmationScreen({
    Key? key,
    required this.args,
  }) : super(key: key);

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
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
      backgroundColor: const Color(0xFFF7F8FA),
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
                                      // Departing City (Left 50%)
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(widget.args.departureImage.isNotEmpty 
                                                  ? widget.args.departureImage 
                                                  : widget.args.departureThumbnail.isNotEmpty
                                                      ? widget.args.departureThumbnail
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
                                                    widget.args.departureAirportCode.toUpperCase(),
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
                                              image: NetworkImage(widget.args.arrivalImage.isNotEmpty 
                                                  ? widget.args.arrivalImage 
                                                  : widget.args.arrivalThumbnail.isNotEmpty
                                                      ? widget.args.arrivalThumbnail
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
                                                    widget.args.arrivalAirportCode.toUpperCase(),
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
                                  
                                  // City names at bottom of banner
                                  Positioned(
                                    bottom: 40,
                                    left: 0,
                                    right: 0,
                                    child: Column(
                                      children: [
                                        Text(
                                          '${widget.args.fromCity.toUpperCase()} → ${widget.args.toCity.toUpperCase()}',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                            color: Colors.white,
                                            letterSpacing: 1.5,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          width: 120,
                                          height: 2,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                Colors.white.withOpacity(0.8),
                                                Colors.transparent,
                                              ],
                                              stops: const [0.0, 0.5, 1.0],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 28,
                                      height: 32 / 28,
                                      color: const Color(0xFF1F2937),
                                    ),
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
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          height: 26 / 16,
                                          color: const Color(0xFF4B5563),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      
                                      // Enhanced Alert Information
                                      if (widget.args.contactNames.isNotEmpty) ...[
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF9FAFB),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: const Color(0xFFE5E7EB),
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.notifications_active,
                                                    size: 18,
                                                    color: const Color(0xFF059393),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Real-time alerts will be sent via WhatsApp',
                                                    style: GoogleFonts.inter(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 14,
                                                      color: const Color(0xFF374151),
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
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                  
                                  // Notifying card - only show when contacts are added
                                  if (widget.args.contactNames.isNotEmpty) ...[
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 18,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
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
                                                color: const Color(0xFFF3F4F6),
                                                borderRadius: BorderRadius.circular(24),
                                              ),
                                              child: const Icon(
                                                Icons.people,
                                                color: Color(0xFF6B7280),
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            
                                            // Contact names
                                            Text(
                                              _formatContactNames(widget.args.contactNames),
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18,
                                                height: 24 / 18,
                                                color: const Color(0xFF1F2937),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 12),
                                            
                                            // WhatsApp notification text
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.message,
                                                  color: Color(0xFF25D366),
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'will be notified via WhatsApp',
                                                  style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                    color: const Color(0xFF6B7280),
                                                  ),
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
                              colors: const [
                                Colors.green,
                                Colors.blue,
                                Colors.pink,
                                Colors.orange,
                                Colors.purple,
                                Colors.red,
                                Colors.yellow,
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
                            colors: const [
                              Colors.green,
                              Colors.blue,
                              Colors.pink,
                              Colors.orange,
                              Colors.purple,
                              Colors.red,
                              Colors.yellow,
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
                              colors: const [
                                Colors.green,
                                Colors.blue,
                                Colors.pink,
                                Colors.orange,
                                Colors.purple,
                                Colors.red,
                                Colors.yellow,
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
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF6B7280), size: 16),
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
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
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
                    color: const Color(0xFFF9FAFB),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
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
}