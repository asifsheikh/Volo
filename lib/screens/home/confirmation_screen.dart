import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmationScreen extends StatelessWidget {
  final String fromCity;
  final String toCity;
  final List<String> contactNames;
  final List<String> contactAvatars;

  const ConfirmationScreen({
    Key? key,
    required this.fromCity,
    required this.toCity,
    required this.contactNames,
    required this.contactAvatars,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          // Cloudy background approximation
          Positioned(
            top: 60,
            left: 20,
            child: _cloudCircle(80, 0.13),
          ),
          Positioned(
            top: 180,
            right: 10,
            child: _cloudCircle(60, 0.10),
          ),
          Positioned(
            top: 320,
            left: 40,
            child: _cloudCircle(100, 0.08),
          ),
          Positioned(
            bottom: 120,
            right: 30,
            child: _cloudCircle(90, 0.12),
          ),
          Positioned(
            bottom: 40,
            left: 10,
            child: _cloudCircle(70, 0.10),
          ),

          // Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Cancel icon (top left)
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF6B7280), size: 28),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // App icon SVG with elevation
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(
                      'assets/app_icon.svg',
                      width: 128,
                      height: 128,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Flight route
                Center(
                  child: Column(
                    children: [
                      Text(
                        '${fromCity.toUpperCase()} → ${toCity.toUpperCase()}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                          height: 24 / 20,
                          color: const Color(0xFF4B5563),
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 96,
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              const Color(0xFF4B5563).withOpacity(0.5),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Title
                Text(
                  "You're all set!",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 28,
                    height: 32 / 28,
                    color: const Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    "We'll keep your selected contacts informed about your flight so you can fly with peace of mind.",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      height: 26 / 16,
                      color: const Color(0xFF4B5563),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 48),
                // Notifying card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
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
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Notifying',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w400,
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
                              ...contactAvatars.map((avatar) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white, width: 2),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: Image.asset(
                                          avatar,
                                          width: 36,
                                          height: 36,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  )),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  _getFirstNames(contactNames).join(' & '),
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    height: 20 / 16,
                                    color: const Color(0xFF374151),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // WhatsApp icon
                              SvgPicture.string(_whatsappSvg, width: 18, height: 18),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Button and disclaimer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
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
                      const SizedBox(height: 18),
                      Text(
                        'Safe travels — we\'ll take it from here.',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          color: const Color(0xFF9CA3AF),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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

// Helper for cloudy background
Widget _cloudCircle(double size, double opacity) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.white.withOpacity(opacity * 0.7),
          blurRadius: size * 0.5,
          spreadRadius: 1,
        ),
      ],
    ),
  );
}

// WhatsApp SVG as string - Fixed with triple double quotes
const String _whatsappSvg = """<svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg"><g clip-path="url(#clip0_220_838)"><g clip-path="url(#clip1_220_838)"><path d="M11.2121 2.65508C10.0664 1.50664 8.54062 0.875 6.91914 0.875C3.57227 0.875 0.848828 3.59844 0.848828 6.94531C0.848828 8.01445 1.12773 9.05898 1.6582 9.98047L0.796875 13.125L4.01523 12.2801C4.90117 12.7641 5.89922 13.0184 6.91641 13.0184H6.91914C10.2633 13.0184 13.0469 10.2949 13.0469 6.94805C13.0469 5.32656 12.3578 3.80352 11.2121 2.65508ZM6.91914 11.9957C6.01133 11.9957 5.12266 11.7523 4.34883 11.293L4.16562 11.1836L2.25703 11.684L2.76562 9.82188L2.64531 9.63047C2.13945 8.82656 1.87422 7.89961 1.87422 6.94531C1.87422 4.16445 4.13828 1.90039 6.92188 1.90039C8.26992 1.90039 9.53594 2.42539 10.4875 3.37969C11.4391 4.33398 12.0242 5.6 12.0215 6.94805C12.0215 9.73164 9.7 11.9957 6.91914 11.9957ZM9.68633 8.2168C9.53594 8.14023 8.78945 7.77383 8.65 7.72461C8.51055 7.67266 8.40938 7.64805 8.3082 7.80117C8.20703 7.9543 7.91719 8.29336 7.82695 8.39727C7.73945 8.49844 7.64922 8.51211 7.49883 8.43555C6.60742 7.98984 6.02227 7.63984 5.43438 6.63086C5.27852 6.36289 5.59023 6.38203 5.88008 5.80234C5.9293 5.70117 5.90469 5.61367 5.86641 5.53711C5.82812 5.46055 5.52461 4.71406 5.39883 4.41055C5.27578 4.11523 5.15 4.15625 5.05703 4.15078C4.96953 4.14531 4.86836 4.14531 4.76719 4.14531C4.66602 4.14531 4.50195 4.18359 4.3625 4.33398C4.22305 4.48711 3.83203 4.85352 3.83203 5.6C3.83203 6.34648 4.37617 7.06836 4.45 7.16953C4.52656 7.2707 5.51914 8.80195 7.04219 9.46094C8.00469 9.87656 8.38203 9.91211 8.86328 9.84102C9.15586 9.79727 9.76016 9.47461 9.88594 9.11914C10.0117 8.76367 10.0117 8.46016 9.97344 8.39727C9.93789 8.32891 9.83672 8.29063 9.68633 8.2168Z" fill="#6B7280"/></g></g><defs><clipPath id="clip0_220_838"><rect width="12.25" height="14" fill="white" transform="translate(0.796875)"/></clipPath><clipPath id="clip1_220_838"><path d="M0.796875 0H13.0469V14H0.796875V0Z" fill="white"/></clipPath></defs></svg>""";