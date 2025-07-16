import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../models/confirmation_args.dart';

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
    
    // Trigger bottom confetti after the frame is rendered
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
  }

  // Helper method to generate initials from contact name
  String _getInitials(String name) {
    final nameParts = name.trim().split(' ');
    if (nameParts.isEmpty) return '?';
    if (nameParts.length == 1) return nameParts[0].isNotEmpty ? nameParts[0][0].toUpperCase() : '?';
    return '${nameParts[0][0].toUpperCase()}${nameParts.last[0].toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = screenHeight * 0.5; // 50% of screen height
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: GestureDetector(
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
                                child: const Center(
                                  child: Icon(
                                    Icons.flight_takeoff,
                                    color: Colors.white,
                                    size: 48,
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
                                child: const Center(
                                  child: Icon(
                                    Icons.flight_land,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Back button (top left) - matching add contacts screen
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 16,
                        left: 16,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
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
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Title
                      Text(
                        "You're all set! 🎉",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                          height: 32 / 28,
                          color: const Color(0xFF1F2937),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      // Subtitle
                      Text(
                        "We'll automatically notify your selected contacts about flight updates, delays, and status changes.",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          height: 26 / 16,
                          color: const Color(0xFF4B5563),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Notifying card
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Will be notified',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      height: 20 / 16,
                                      color: const Color(0xFF4B5563),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.favorite, color: Color(0xFF9CA3AF), size: 18),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Overlapped contact avatars
                                  SizedBox(
                                    height: 40,
                                    width: 40 + (widget.args.contactNames.take(4).length - 1) * 6.0 + (widget.args.contactNames.length > 4 ? 40 : 0),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        // Show first 4 contacts with overlap
                                        ...widget.args.contactNames.take(4).toList().asMap().entries.map((entry) {
                                          final index = entry.key;
                                          final name = entry.value;
                                          final offset = index * 6.0;
                                          return Positioned(
                                            left: offset,
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.white, width: 2),
                                                borderRadius: BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: CircleAvatar(
                                                radius: 20,
                                                backgroundColor: const Color(0xFF1F2937),
                                                child: Text(
                                                  _getInitials(name),
                                                  style: const TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        // Show "+X more" indicator if there are more than 4 contacts
                                        if (widget.args.contactNames.length > 4)
                                          Positioned(
                                            left: 4 * 6.0,
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.white, width: 2),
                                                borderRadius: BorderRadius.circular(20),
                                                color: const Color(0xFF6B7280),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '+${widget.args.contactNames.length - 4}',
                                                  style: const TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Contact names
                                  Expanded(
                                    child: Text(
                                      _getFirstNames(widget.args.contactNames).join(' & '),
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        height: 20 / 16,
                                        color: const Color(0xFF374151),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1F2937),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Got it, thanks!',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.check, color: Colors.white, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Test confetti button (debug builds only)
                      if (kDebugMode) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              _playConfetti(includeCenter: true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.celebration, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Test Confetti 🎉',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                      
                      // Disclaimer
                      Text(
                        'Safe travels — we\'ll take it from here.',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          color: const Color(0xFF9CA3AF),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
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
        ],
        ),
      ),
    );
  }

  // Helper method to extract first names
  List<String> _getFirstNames(List<String> fullNames) {
    return fullNames.map((name) {
      final parts = name.split(' ');
      return parts.isNotEmpty ? parts.first : name;
    }).toList();
  }
}