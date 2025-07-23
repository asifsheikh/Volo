import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/trip/trip_model.dart';
import '../../services/trip_service.dart';
import '../../features/add_flight/add_flight_screen.dart';
import '../../features/add_flight/controller/add_flight_controller.dart';

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
      backgroundColor: const Color(0xFFF7F8FA),
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
                        const Text(
                          'Flights',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                            height: 1.33, // 32px line height
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage your upcoming trips',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                          ),
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
                         color: const Color(0xFF047C7C),
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
                         color: Colors.white,
                         size: 14,
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
                color: Colors.white,
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
                  color: const Color(0xFF047C7C),
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF6B7280),
                labelStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 1.21, // 17px line height
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 1.21, // 17px line height
                ),
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
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF047C7C),
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
            const Text(
              'You don\'t have any upcoming flights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Everything you are all caught up!',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToAddFlight,
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Flight'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF047C7C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF047C7C),
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
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
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
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 40,
                                height: 40,
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
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 1.5, // 24px line height
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.firstFlight.airline,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          height: 1.33, // 16px line height
                          color: Color(0xFF6B7280),
                        ),
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
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.25, // 15px line height
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Flight route with times and dates
            Column(
              children: [
                // Flight path with IATA codes and dotted line
                Row(
                  children: [
                    // Departure IATA code
                    Text(
                      widget.firstFlight.departureAirport,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        height: 1.21, // 29px line height
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    
                    // Dotted line connecting departure to arrival
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
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        height: 1.21, // 29px line height
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Times, dates, and details
                Row(
                  children: [
                    // Departure details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.departureTime,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              height: 1.21, // 17px line height
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.departureDate,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              height: 1.25, // 15px line height
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getDummyGateInfo(),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              height: 1.33, // 16px line height
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Duration chip in center
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        _formatDuration(widget.trip.tripData.totalDuration),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          height: 1.25, // 15px line height
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),

                    // Arrival details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.arrivalTime,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              height: 1.21, // 17px line height
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.arrivalDate,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              height: 1.25, // 15px line height
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Passenger initials
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ..._getSimplePassengerInitials(),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
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
        return const Color(0xFF047C7C); // App theme primary
      case 'delayed 25 min':
        return const Color(0xFFD97706); // App theme warning
      case 'scheduled':
        return const Color(0xFF9CA3AF); // App theme secondary
      case 'cancelled':
        return const Color(0xFFDC2626); // App theme destructive
      default:
        return const Color(0xFF6B7280); // App theme text secondary
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
        return const Color(0xFF047C7C); // Teal
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

  String _getDummyGateInfo() {
    final random = Random();
    final terminals = ['T1', 'T2', 'T3'];
    final gates = ['A1', 'A7', 'B3', 'C12', 'D5', 'E8'];
    final terminal = terminals[random.nextInt(terminals.length)];
    final gate = gates[random.nextInt(gates.length)];
    return '$terminal - Gate $gate';
  }

  List<Widget> _getSimplePassengerInitials() {
    final random = Random();
    final initials = ['AS', 'MK', 'RJ', 'SP', 'AB'];
    final count = random.nextInt(3) + 2; // 2-4 passengers
    
    return List.generate(count, (index) {
      final initial = initials[random.nextInt(initials.length)];
      return Transform.translate(
        offset: Offset(-6.0 * index, 0), // Create overlap effect without negative margin
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF6B7280),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                height: 1.25, // 15px line height
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    });
  }
} 

// Custom painter for dotted line
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD1D5DB)
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