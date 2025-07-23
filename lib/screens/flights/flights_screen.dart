
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/trip/trip_model.dart';
import '../../services/trip_service.dart';
import '../../features/add_flight/add_flight_screen.dart';
import '../../features/add_flight/controller/add_flight_controller.dart';
import '../../theme/app_theme.dart';

class FlightsScreen extends StatefulWidget {
  final String username;
  
  const FlightsScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<FlightsScreen> createState() => _FlightsScreenState();
}

class _FlightsScreenState extends State<FlightsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Trip> _upcomingTrips = [];
  List<Trip> _pastTrips = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTrips();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTrips() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userId = TripService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final allTrips = await TripService.getUserTrips(userId);
      final now = DateTime.now();

      // Separate trips into upcoming and past
      final upcoming = <Trip>[];
      final past = <Trip>[];

      for (final trip in allTrips) {
        final departureTime = trip.tripData.departureTime;
        if (departureTime.isAfter(now)) {
          upcoming.add(trip);
        } else {
          past.add(trip);
        }
      }

      // Sort upcoming trips by departure time (earliest first)
      upcoming.sort((a, b) => a.tripData.departureTime.compareTo(b.tripData.departureTime));
      
      // Sort past trips by departure time (most recent first)
      past.sort((a, b) => b.tripData.departureTime.compareTo(a.tripData.departureTime));

      if (mounted) {
        setState(() {
          _upcomingTrips = upcoming;
          _pastTrips = past;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load trips: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToAddFlight() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (context) => AddFlightController(),
          child: const AddFlightScreen(),
        ),
      ),
    ).then((_) {
      // Refresh trips when returning from add flight
      _loadTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Flights',
                          style: AppTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage your upcoming trips',
                          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                                     // Add Flight Button
                   GestureDetector(
                     onTap: _navigateToAddFlight,
                     child: Container(
                       width: 40,
                       height: 40,
                       decoration: BoxDecoration(
                         color: AppTheme.primary,
                         borderRadius: BorderRadius.circular(9999),
                         boxShadow: [
                           BoxShadow(
                             color: Colors.black.withOpacity(0.1),
                             blurRadius: 4,
                             offset: const Offset(0, 4),
                           ),
                           BoxShadow(
                             color: Colors.black.withOpacity(0.1),
                             blurRadius: 10,
                             offset: const Offset(0, 10),
                           ),
                         ],
                       ),
                       child: const Icon(
                         Icons.add,
                         color: AppTheme.textOnPrimary,
                         size: 20,
                         weight: 900,
                       ),
                     ),
                   ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppTheme.textOnPrimary,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: AppTheme.labelLarge,
                unselectedLabelStyle: AppTheme.labelLarge,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Past'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUpcomingTab(),
                  _buildPastTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTab() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.primary,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTrips,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF047C7C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_upcomingTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flight_takeoff_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'You don\'t have any upcoming flights',
              style: AppTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Everything you are all caught up!',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToAddFlight,
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Flight'),
              style: AppTheme.primaryButton,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTrips,
      color: const Color(0xFF047C7C),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _upcomingTrips.length,
        itemBuilder: (context, index) {
          return _buildTripCard(_upcomingTrips[index]);
        },
      ),
    );
  }

  Widget _buildPastTab() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.primary,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTrips,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF047C7C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_pastTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No past flights yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your flight history will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTrips,
      color: const Color(0xFF047C7C),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _pastTrips.length,
        itemBuilder: (context, index) {
          return _buildTripCard(_pastTrips[index]);
        },
      ),
    );
  }

    Widget _buildTripCard(Trip trip) {
    final firstFlight = trip.tripData.flights.first;
    final lastFlight = trip.tripData.flights.last;
    final departureTime = trip.tripData.departureTime;
    final arrivalTime = departureTime.add(Duration(minutes: trip.tripData.totalDuration));
    final isMultiLeg = trip.tripData.flights.length > 1;
    
    // Format dates and times
    final departureFormattedTime = '${departureTime.hour > 12 ? departureTime.hour - 12 : departureTime.hour}:${departureTime.minute.toString().padLeft(2, '0')} ${departureTime.hour >= 12 ? 'PM' : 'AM'}';
    final arrivalFormattedTime = '${arrivalTime.hour > 12 ? arrivalTime.hour - 12 : arrivalTime.hour}:${arrivalTime.minute.toString().padLeft(2, '0')} ${arrivalTime.hour >= 12 ? 'PM' : 'AM'}';
    final departureFormattedDate = '${_getMonthName(departureTime.month)} ${departureTime.day}';
    final arrivalFormattedDate = '${_getMonthName(arrivalTime.month)} ${arrivalTime.day}';

    return _TripCard(
      trip: trip,
      firstFlight: firstFlight,
      lastFlight: lastFlight,
      departureTime: departureFormattedTime,
      arrivalTime: arrivalFormattedTime,
      departureDate: departureFormattedDate,
      arrivalDate: arrivalFormattedDate,
      isMultiLeg: isMultiLeg,
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (hours == 0) {
      return '$remainingMinutes min';
    } else if (remainingMinutes == 0) {
      return '$hours hr';
    } else {
      return '$hours hr $remainingMinutes min';
    }
  }
}

class _TripCard extends StatefulWidget {
  final Trip trip;
  final TripFlight firstFlight;
  final TripFlight lastFlight;
  final String departureTime;
  final String arrivalTime;
  final String departureDate;
  final String arrivalDate;
  final bool isMultiLeg;

  const _TripCard({
    required this.trip,
    required this.firstFlight,
    required this.lastFlight,
    required this.departureTime,
    required this.arrivalTime,
    required this.departureDate,
    required this.arrivalDate,
    required this.isMultiLeg,
  });

  @override
  State<_TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<_TripCard> {

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        border: Border.all(color: AppTheme.borderPrimary, width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with airline logo, flight number, and status
            Row(
              children: [
                // Airline logo
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.firstFlight.airlineLogo != null 
                        ? Colors.transparent 
                        : _getAirlineColor(widget.firstFlight.airline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: widget.firstFlight.airlineLogo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.firstFlight.airlineLogo!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              // Show initials while loading
                              return Container(
                                decoration: BoxDecoration(
                                  color: _getAirlineColor(widget.firstFlight.airline),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    _getAirlineInitials(widget.firstFlight.airline),
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: _getAirlineColor(widget.firstFlight.airline),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    _getAirlineInitials(widget.firstFlight.airline),
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Text(
                            _getAirlineInitials(widget.firstFlight.airline),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                // Flight number and airline name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.firstFlight.flightNumber,
                        style: AppTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.firstFlight.airline,
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_getRandomStatus()),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    _getRandomStatus(),
                    style: AppTheme.labelMedium.copyWith(color: AppTheme.textOnPrimary),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Row 1: IATA codes with dotted line
            Row(
              children: [
                // Departure IATA code
                Text(
                  widget.firstFlight.departureAirport,
                  style: AppTheme.headlineMedium,
                ),
                
                // Dotted line connecting departure to arrival (full width)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: CustomPaint(
                      painter: DottedLinePainter(),
                    ),
                  ),
                ),
                
                // Arrival IATA code
                Text(
                  widget.lastFlight.arrivalAirport,
                  style: AppTheme.headlineMedium,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Row 2: Times with duration badge in middle
            Row(
              children: [
                // Departure time
                Text(
                  widget.departureTime,
                  style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                ),
                
                // Duration badge in center
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        _formatDuration(widget.trip.tripData.totalDuration),
                        style: AppTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
                
                // Arrival time
                Text(
                  widget.arrivalTime,
                  style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Row 3: Dates
            Row(
              children: [
                // Departure date
                Text(
                  widget.departureDate,
                  style: AppTheme.bodySmall,
                ),
                
                // Empty space in middle
                const Expanded(child: SizedBox()),
                
                // Arrival date
                Text(
                  widget.arrivalDate,
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Row 4: Connection info and passenger contacts
            Row(
              children: [
                // Connection information (reserves 60% of space)
                Expanded(
                  flex: 6,
                  child: Text(
                    _getConnectionInfo(),
                    style: AppTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Passenger initials (reserves 40% of space)
                Expanded(
                  flex: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ..._getContactInitials(widget.trip),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (hours == 0) {
      return '$remainingMinutes min';
    } else if (remainingMinutes == 0) {
      return '$hours hr';
    } else {
      return '$hours hr $remainingMinutes min';
    }
  }

  String _getRandomStatus() {
    final random = Random();
    final statuses = ['On Time', 'Delayed 25 min'];
    return statuses[random.nextInt(statuses.length)];
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'on time':
        return AppTheme.primary;
      case 'delayed 25 min':
        return AppTheme.warning;
      case 'scheduled':
        return AppTheme.secondary;
      case 'cancelled':
        return AppTheme.destructive;
      default:
        return AppTheme.textSecondary;
    }
  }

  Color _getAirlineColor(String airline) {
    switch (airline.toLowerCase()) {
      case 'indigo':
        return const Color(0xFF2563EB); // Blue from Figma
      case 'emirates':
        return const Color(0xFFDC2626); // Red from Figma
      case 'air india':
        return const Color(0xFFEA580C); // Orange from Figma
      case 'british airways':
        return const Color(0xFF1E40AF); // Blue
      case 'lufthansa':
        return const Color(0xFF1F2937); // Dark gray
      default:
        return AppTheme.primary; // Use theme primary color
    }
  }

  String _getAirlineInitials(String airline) {
    switch (airline.toLowerCase()) {
      case 'indigo':
        return '6E';
      case 'emirates':
        return 'EK';
      case 'air india':
        return 'AI';
      case 'british airways':
        return 'BA';
      case 'lufthansa':
        return 'LH';
      default:
        return airline.split(' ').map((word) => word[0]).join('').toUpperCase();
    }
  }

  String _getConnectionInfo() {
    final flights = widget.trip.tripData.flights;
    
    // If there's only one flight, it's direct
    if (flights.length == 1) {
      return 'Direct flight';
    }
    
    // If there are multiple flights, show the connection points
    if (flights.length == 2) {
      // For 2 flights, show the connection point
      final connectionAirport = flights[0].arrivalAirport;
      final cityName = _getCityNameFromIATA(connectionAirport);
      return 'via $cityName';
    } else {
      // For more than 2 flights, show all connection cities
      final connectionCities = <String>[];
      for (int i = 0; i < flights.length - 1; i++) {
        final airport = flights[i].arrivalAirport;
        final cityName = _getCityNameFromIATA(airport);
        connectionCities.add(cityName);
      }
      return 'via ${connectionCities.join(', ')}';
    }
  }

  String _getCityNameFromIATA(String iataCode) {
    // Map of common IATA codes to city names
    final cityMap = {
      'DXB': 'Dubai',
      'AUH': 'Abu Dhabi',
      'DOH': 'Doha',
      'IST': 'Istanbul',
      'LHR': 'London',
      'CDG': 'Paris',
      'FRA': 'Frankfurt',
      'AMS': 'Amsterdam',
      'JFK': 'New York',
      'LAX': 'Los Angeles',
      'SFO': 'San Francisco',
      'ORD': 'Chicago',
      'BOM': 'Mumbai',
      'DEL': 'Delhi',
      'BLR': 'Bangalore',
      'MAA': 'Chennai',
      'HYD': 'Hyderabad',
      'CCU': 'Kolkata',
      'SIN': 'Singapore',
      'BKK': 'Bangkok',
      'HKG': 'Hong Kong',
      'NRT': 'Tokyo',
      'ICN': 'Seoul',
      'SYD': 'Sydney',
      'MEL': 'Melbourne',
      'YYZ': 'Toronto',
      'YVR': 'Vancouver',
      'YUL': 'Montreal',
    };
    
    return cityMap[iataCode] ?? iataCode; // Return city name if found, otherwise return IATA code
  }

  List<Widget> _getContactInitials(Trip trip) {
    final contacts = trip.contacts;
    
    // If no contacts, show a message
    if (contacts.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.textSecondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.textSecondary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            'No contacts informed',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 10,
            ),
          ),
        ),
      ];
    }
    
    // Limit to first 4 contacts to avoid overflow
    final displayContacts = contacts.take(4).toList();
    
    return List.generate(displayContacts.length, (index) {
      final contact = displayContacts[index];
      final initials = _getInitialsFromName(contact.name);
      
      return Transform.translate(
        offset: Offset(-6.0 * index, 0), // Create overlap effect
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              initials,
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.textOnPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    });
  }
  
  String _getInitialsFromName(String name) {
    if (name.isEmpty) return '?';
    
    final nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) {
      // First letter of first name + first letter of last name
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.length == 1) {
      // Just first letter of the name
      return nameParts[0][0].toUpperCase();
    }
    
    return '?';
  }
} 

// Custom painter for dotted line
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.secondary // Use theme secondary color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dashWidth = 4;
    const dashSpace = 4;
    double startX = 0;
    final endX = size.width;

    while (startX < endX) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 