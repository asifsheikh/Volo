import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/trip/trip_model.dart';
import '../../services/trip_service.dart';
import '../../features/add_flight/add_flight_screen.dart';
import '../../features/add_flight/controller/add_flight_controller.dart';
import '../../widgets/loading_dialog.dart';

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
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
                            fontSize: 28,
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
                         borderRadius: BorderRadius.circular(20),
                         boxShadow: [
                           BoxShadow(
                             color: const Color(0xFF047C7C).withOpacity(0.2),
                             blurRadius: 8,
                             offset: const Offset(0, 2),
                           ),
                         ],
                       ),
                       child: const Icon(
                         Icons.add,
                         color: Colors.white,
                         size: 20,
                       ),
                     ),
                   ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
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
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
    final isMultiLeg = trip.tripData.flights.length > 1;
    
    // Format date and time
    final formattedDate = '${_getMonthName(departureTime.month)} ${departureTime.day}, ${departureTime.year}';
    final formattedTime = '${departureTime.hour > 12 ? departureTime.hour - 12 : departureTime.hour}:${departureTime.minute.toString().padLeft(2, '0')} ${departureTime.hour >= 12 ? 'PM' : 'AM'}';

    return _TripCard(
      trip: trip,
      firstFlight: firstFlight,
      lastFlight: lastFlight,
      formattedDate: formattedDate,
      formattedTime: formattedTime,
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

  String _getAirportName(String airportCode) {
    // This would ideally come from a database or API
    // For now, using a simple mapping
    const airportNames = {
      'DEL': 'Delhi',
      'LHR': 'London',
      'DXB': 'Dubai',
      'SFO': 'San Francisco',
      'JFK': 'New York',
      'BOM': 'Mumbai',
      'PNQ': 'Pune',
      'DEE': 'Dee',
      'NRT': 'Tokyo',
      'DPS': 'Bali',
      'TRR': 'Tiruchirappalli',
      'KEP': 'Nepalgunj',
    };
    return airportNames[airportCode] ?? airportCode;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'on time':
        return const Color(0xFF047C7C); // Teal
      case 'delayed':
        return const Color(0xFFF59E0B); // Orange
      case 'scheduled':
        return const Color(0xFF6B7280); // Gray
      case 'cancelled':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'on time':
        return 'On Time';
      case 'delayed':
        return 'Delayed';
      case 'scheduled':
        return 'Scheduled';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Scheduled';
    }
  }
}

class _TripCard extends StatefulWidget {
  final Trip trip;
  final TripFlight firstFlight;
  final TripFlight lastFlight;
  final String formattedDate;
  final String formattedTime;
  final bool isMultiLeg;

  const _TripCard({
    required this.trip,
    required this.firstFlight,
    required this.lastFlight,
    required this.formattedDate,
    required this.formattedTime,
    required this.isMultiLeg,
  });

  @override
  State<_TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<_TripCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main card content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                                 // Header with route and status
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             _getRouteTitle(),
                             style: const TextStyle(
                               fontFamily: 'Inter',
                               fontWeight: FontWeight.w700,
                               fontSize: 16,
                               color: Color(0xFF1F2937),
                             ),
                           ),
                           const SizedBox(height: 2),
                           Text(
                             '${widget.firstFlight.airline} • ${widget.firstFlight.flightNumber}',
                             style: const TextStyle(
                               fontFamily: 'Inter',
                               fontWeight: FontWeight.w400,
                               fontSize: 12,
                               color: Color(0xFF6B7280),
                             ),
                           ),
                         ],
                       ),
                     ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(widget.trip.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(widget.trip.status),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Flight route
                Row(
                  children: [
                    // Departure
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.firstFlight.departureAirport,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getAirportName(widget.firstFlight.departureAirport),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Flight path visual
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF047C7C),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(1),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                  ),
                                                                     Container(
                                     width: 16,
                                     height: 16,
                                     decoration: BoxDecoration(
                                       color: const Color(0xFF047C7C),
                                       borderRadius: BorderRadius.circular(8),
                                     ),
                                     child: const Icon(
                                       Icons.flight,
                                       size: 12,
                                       color: Colors.white,
                                     ),
                                   ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrival
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.lastFlight.arrivalAirport,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getAirportName(widget.lastFlight.arrivalAirport),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Multi-leg indicator and date/time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.formattedDate} · ${widget.formattedTime}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                                         Text(
                       _getLayoverInfo(),
                       style: const TextStyle(
                         fontFamily: 'Inter',
                         fontWeight: FontWeight.w500,
                         fontSize: 12,
                         color: Color(0xFF047C7C),
                       ),
                     ),
                  ],
                ),
              ],
            ),
          ),

                     // Expandable section for multi-leg flights
           if (widget.trip.tripData.flights.length > 1) ...[
            // Divider
            Container(
              height: 1,
              color: Colors.grey[200],
            ),
            
            // Expand/Collapse button
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isExpanded ? 'Hide details' : 'Show details',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Color(0xFF047C7C),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: const Color(0xFF047C7C),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            // Expanded content
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: widget.trip.tripData.flights.map((flight) {
                    return _buildFlightDetail(flight);
                  }).toList(),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildFlightDetail(TripFlight flight) {
    final departureTime = flight.departureTime;
    final arrivalTime = flight.arrivalTime;
    
    final formattedDepartureTime = '${departureTime.hour > 12 ? departureTime.hour - 12 : departureTime.hour}:${departureTime.minute.toString().padLeft(2, '0')} ${departureTime.hour >= 12 ? 'PM' : 'AM'}';
    final formattedArrivalTime = '${arrivalTime.hour > 12 ? arrivalTime.hour - 12 : arrivalTime.hour}:${arrivalTime.minute.toString().padLeft(2, '0')} ${arrivalTime.hour >= 12 ? 'PM' : 'AM'}';

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Flight header
          Row(
            children: [
              Expanded(
                child: Text(
                  '${flight.airline} ${flight.flightNumber}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              Text(
                '${flight.duration} min',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Flight route details
          Row(
            children: [
              // Departure
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDepartureTime,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      flight.departureAirport,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Flight icon
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF047C7C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flight,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              
              // Arrival
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedArrivalTime,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      flight.arrivalAirport,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getRouteTitle() {
    final departureCity = _getAirportName(widget.firstFlight.departureAirport);
    final arrivalCity = _getAirportName(widget.lastFlight.arrivalAirport);
    return '$departureCity to $arrivalCity';
  }

  String _getLayoverInfo() {
    if (widget.trip.tripData.flights.length == 1) {
      return 'Direct flight';
    } else if (widget.trip.tripData.flights.length == 2) {
      final layoverAirport = widget.trip.tripData.flights[0].arrivalAirport;
      return 'Via ${_getAirportName(layoverAirport)}';
    } else if (widget.trip.tripData.flights.length > 2) {
      return '${widget.trip.tripData.flights.length - 1} stops';
    }
    return '';
  }

  String _getAirportName(String airportCode) {
    const airportNames = {
      'DEL': 'Delhi',
      'LHR': 'London',
      'DXB': 'Dubai',
      'SFO': 'San Francisco',
      'JFK': 'New York',
      'BOM': 'Mumbai',
      'PNQ': 'Pune',
      'DEE': 'Dee',
      'NRT': 'Tokyo',
      'DPS': 'Bali',
      'TRR': 'Tiruchirappalli',
      'KEP': 'Nepalgunj',
    };
    return airportNames[airportCode] ?? airportCode;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'on time':
        return const Color(0xFF047C7C);
      case 'delayed':
        return const Color(0xFFF59E0B);
      case 'scheduled':
        return const Color(0xFF6B7280);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'on time':
        return 'On Time';
      case 'delayed':
        return 'Delayed';
      case 'scheduled':
        return 'Scheduled';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Scheduled';
    }
  }
} 