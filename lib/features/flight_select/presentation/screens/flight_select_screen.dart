import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_theme.dart';
import '../../../../features/add_contacts/screens/add_contacts_screen.dart';
import '../providers/flight_select_provider.dart';
import '../../domain/entities/flight_select_state.dart' as domain;

/// Flight Select Screen using Riverpod + Clean Architecture
class FlightSelectScreen extends ConsumerStatefulWidget {
  final String departureCity;
  final String arrivalCity;
  final String date;
  final String? flightNumber;

  const FlightSelectScreen({
    Key? key,
    required this.departureCity,
    required this.arrivalCity,
    required this.date,
    this.flightNumber,
  }) : super(key: key);

  @override
  ConsumerState<FlightSelectScreen> createState() => _FlightSelectScreenState();
}

class _FlightSelectScreenState extends ConsumerState<FlightSelectScreen> with TickerProviderStateMixin {
  int? _expandedIndex;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper to get city name by IATA code from airports array
  String _cityNameForIata(String iata, domain.FlightSelectState state) {
    for (final airportInfo in state.airports) {
      if (airportInfo.id == iata) return airportInfo.name;
    }
    return iata;
  }

  @override
  Widget build(BuildContext context) {
    final flightSelectAsync = ref.watch(flightSelectProviderProvider(
      departureCity: widget.departureCity,
      arrivalCity: widget.arrivalCity,
      date: widget.date,
      flightNumber: widget.flightNumber,
    ));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
          splashRadius: 24,
        ),
        title: Text(
          'Choose Your Flight',
          style: AppTheme.headlineMedium.copyWith(fontSize: 22),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: flightSelectAsync.when(
          data: (flightSelectState) => _buildFlightSelectContent(flightSelectState),
          loading: () => _buildSkeletonLoading(),
          error: (error, stackTrace) => _buildNetworkError(error.toString()),
        ),
      ),
    );
  }

  Widget _buildFlightSelectContent(domain.FlightSelectState flightSelectState) {
    final flights = [...flightSelectState.bestFlights, ...flightSelectState.otherFlights];
    
    if (flights.isEmpty) {
      return _buildNoResultsError();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: flights.length,
      itemBuilder: (context, index) {
        return _buildJourneyCard(flights[index], index, flightSelectState);
      },
    );
  }

  Widget _buildSkeletonLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: 6, // Show 6 skeleton cards
      itemBuilder: (context, index) {
        return _buildSkeletonCard();
      },
    );
  }

  Widget _buildSkeletonCard() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Airline logo skeleton
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey[300]!.withOpacity(_fadeAnimation.value * 0.6 + 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time skeleton
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.grey[300]!.withOpacity(_fadeAnimation.value * 0.6 + 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.grey[300]!.withOpacity(_fadeAnimation.value * 0.6 + 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Route skeleton
                        Container(
                          width: 120,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[300]!.withOpacity(_fadeAnimation.value * 0.6 + 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Airport codes skeleton
                        Container(
                          width: 80,
                          height: 15,
                          decoration: BoxDecoration(
                            color: Colors.grey[300]!.withOpacity(_fadeAnimation.value * 0.6 + 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Duration and stops skeleton
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.grey[300]!.withOpacity(_fadeAnimation.value * 0.6 + 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 100,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.grey[300]!.withOpacity(_fadeAnimation.value * 0.6 + 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Airlines skeleton
                        Container(
                          width: 140,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey[300]!.withOpacity(_fadeAnimation.value * 0.6 + 0.2),
                            borderRadius: BorderRadius.circular(4),
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
      },
    );
  }

  Widget _buildNetworkError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Network Error',
            style: AppTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(flightSelectProviderProvider(
                departureCity: widget.departureCity,
                arrivalCity: widget.arrivalCity,
                date: widget.date,
                flightNumber: widget.flightNumber,
              ));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flight_takeoff,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No flights found',
            style: AppTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyCard(domain.FlightOption flight, int index, domain.FlightSelectState state) {
    final isExpanded = _expandedIndex == index;
    final flights = flight.flights;
    final totalDuration = flight.totalDuration;
    final layovers = flight.layovers ?? [];
    final airlines = flights.map((f) => f.airline).toSet().toList();
    
    // Calculate layover summary
    String layoverSummary = '';
    if (flights.length > 1) {
      layoverSummary = '${flights.length - 1} stop${flights.length > 2 ? 's' : ''}';
    } else {
      layoverSummary = 'Direct';
    }

    // Get first and last flight details
    final firstFlight = flights.first;
    final lastFlight = flights.last;
    final depIata = firstFlight.departureAirport.id;
    final arrIata = lastFlight.arrivalAirport.id;
    final depTime = _formatTime(firstFlight.departureAirport.time);
    final arrTime = _formatTime(lastFlight.arrivalAirport.time);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedIndex = isExpanded ? null : index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Airline logo
                  if (flight.airlineLogo != null)
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(flight.airlineLogo!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.flight,
                        color: Color(0xFF6B7280),
                        size: 20,
                      ),
                    ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$depTime - $arrTime',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                size: 16,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_cityNameForIata(depIata, state)} → ${_cityNameForIata(arrIata, state)}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$depIata - $arrIata',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              _formatDuration(totalDuration),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                layoverSummary,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: Color(0xFF6B7280),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Flexible(
                          child: Text(
                            airlines.join(' · '),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: Color(0xFF374151),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 16),
            // Timeline for segments and layovers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < flights.length; i++) ...[
                    _buildItinerarySegment(flights[i]),
                    if (i < flights.length - 1 && layovers.isNotEmpty)
                      _buildLayoverInfo(layovers[i]),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(height: 1, color: Color(0xFFE5E7EB)),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Airlines:',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      airlines.join(' · '),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xFF1F2937),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to add contacts screen with required args
                    final departureAirportCode = flight.flights.first.departureAirport.id;
                    final arrivalAirportCode = flight.flights.last.arrivalAirport.id;
                    
                    print('Flight Select Debug: departureAirportCode = $departureAirportCode');
                    print('Flight Select Debug: arrivalAirportCode = $arrivalAirportCode');
                    
                    final args = AddContactsScreenArgs(
                      selectedFlight: flight,
                      departureCity: widget.departureCity,
                      departureAirportCode: departureAirportCode,
                      departureImage: '',
                      departureThumbnail: '',
                      arrivalCity: widget.arrivalCity,
                      arrivalAirportCode: arrivalAirportCode,
                      arrivalImage: '',
                      arrivalThumbnail: '',
                    );
                    
                    print('Flight Select Debug: AddContactsScreenArgs created with IATA codes: ${args.departureAirportCode}, ${args.arrivalAirportCode}');
                    
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddContactsScreen(args: args),
                      ),
                    );
                  },
                  style: AppTheme.primaryButton,
                  icon: const Icon(Icons.people, size: 20),
                  label: const Text(
                    'Add Contacts',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildItinerarySegment(domain.Flight flight) {
    final depIata = flight.departureAirport.id;
    final arrIata = flight.arrivalAirport.id;
    final depTime = _formatTime(flight.departureAirport.time);
    final arrTime = _formatTime(flight.arrivalAirport.time);
    
    String secondLine = '';
    if (flight.airplane != null) {
      secondLine = 'Aircraft: ${flight.airplane}';
    }
    if (flight.extensions?.isNotEmpty ?? false) {
      if (secondLine.isNotEmpty) secondLine += ' • ';
      secondLine += flight.extensions!.first;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFF059669),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: const Icon(Icons.flight, size: 12, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$depIata $depTime → $arrIata $arrTime',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (secondLine.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    secondLine,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // New: Build layover info row
  Widget _buildLayoverInfo(Map layover) {
    return Padding(
      padding: const EdgeInsets.only(left: 44, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: const Icon(Icons.schedule, size: 12, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Layover in ${layover['id']} – ${_formatDuration(layover['duration'])}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String timeString) {
    try {
      final dateTime = DateTime.parse(timeString.replaceAll(' ', 'T'));
      return DateFormat('h:mm a').format(dateTime.toLocal());
    } catch (e) {
      return timeString;
    }
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) {
      return '${hours} hr ${mins} min';
    } else if (hours > 0) {
      return '${hours} hr';
    } else {
      return '${mins} min';
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMMM d').format(date);
    } catch (e) {
      return dateString;
    }
  }
} 