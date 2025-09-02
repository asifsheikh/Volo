import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:intl/intl.dart';
import '../../../../services/flight_api_service.dart';
import '../../../../services/network_service.dart';
import '../../../../widgets/network_error_widget.dart';
import '../../../add_contacts/presentation/screens/add_trip_contacts_screen.dart';
import '../../../add_contacts/domain/entities/add_contacts_state.dart' as domain;
import '../../../../theme/app_theme.dart';

class FlightSelectScreen extends StatefulWidget {
  final String departureIata;
  final String arrivalIata;
  final String departureCity;
  final String arrivalCity;
  final String date;
  final String? flightNumber;

  const FlightSelectScreen({
    Key? key,
    required this.departureIata,
    required this.arrivalIata,
    required this.departureCity,
    required this.arrivalCity,
    required this.date,
    this.flightNumber,
  }) : super(key: key);

  @override
  State<FlightSelectScreen> createState() => _FlightSelectScreenState();
}

class _FlightSelectScreenState extends State<FlightSelectScreen> with TickerProviderStateMixin {
  int? _expandedIndex;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Future<FlightSearchResponse> _searchFuture;

  Future<FlightSearchResponse> _createSearchFuture() {
    return FlightApiService.searchFlights(
      departureIata: widget.departureIata,
      arrivalIata: widget.arrivalIata,
      date: widget.date,
      flightNumber: widget.flightNumber,
    );
  }

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
    _searchFuture = _createSearchFuture();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper to get city name by IATA code from airports array
  String _cityNameForIata(String iata, FlightSearchResponse response) {
    for (final airportInfo in response.airports) {
      for (final dep in airportInfo.departure) {
        if (dep.airport.id == iata) return dep.city;
      }
      for (final arr in airportInfo.arrival) {
        if (arr.airport.id == iata) return arr.city;
      }
    }
    return iata;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
          splashRadius: 24,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Your Flight',
              style: AppTheme.headlineMedium.copyWith(fontSize: 22),
            ),
            Text(
              '${snapshot.data != null ? [...snapshot.data!.bestFlights, ...snapshot.data!.otherFlights].length : 0} flights found',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: FutureBuilder<FlightSearchResponse>(
          future: _searchFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildSkeletonLoading();
            } else if (snapshot.hasError) {
              return _buildNetworkError(snapshot.error);
            } else if (!snapshot.hasData || (snapshot.data!.bestFlights.isEmpty && snapshot.data!.otherFlights.isEmpty)) {
              return _buildNoResultsError();
            }
            final response = snapshot.data!;
            final flights = [...response.bestFlights, ...response.otherFlights];
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: flights.length,
              itemBuilder: (context, index) {
                return _buildJourneyCard(flights[index], index, response);
              },
            );
          },
        ),
      ),
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
                              height: 15,
                              decoration: BoxDecoration(
                                color: Colors.grey[300]!.withOpacity(_fadeAnimation.value * 0.6 + 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 80,
                              height: 15,
                              decoration: BoxDecoration(
                                color: Colors.grey[300]!.withOpacity(_fadeAnimation.value * 0.6 + 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Price skeleton
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[300]!.withOpacity(_fadeAnimation.value * 0.6 + 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300]!.withOpacity(_fadeAnimation.value * 0.6 + 0.2),
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildNetworkError(dynamic error) {
    NetworkError networkError;
    
    if (error is NetworkError) {
      networkError = error;
    } else {
      // Convert generic error to NetworkError
      networkError = NetworkError(
        type: NetworkErrorType.unknown,
        message: error.toString(),
      );
    }

    return NetworkErrorWidget(
      error: networkError,
      onRetry: () {
        // Create a fresh future so FutureBuilder runs again
        setState(() {
          _searchFuture = _createSearchFuture();
        });
      },
    );
  }

  Widget _buildNoResultsError() {
    return NetworkErrorWidget(
      error: NetworkError(
        type: NetworkErrorType.notFound,
        message: 'No flights found for the specified route and date. Try adjusting your search criteria.',
      ),
      customTitle: 'No Flights Found',
      onRetry: () {
        // Retry the search by rebuilding the widget
        setState(() {});
      },
    );
  }

  Widget _buildJourneyCard(FlightOption option, int index, FlightSearchResponse response) {
    final flights = option.flights;
    final first = flights.first;
    final last = flights.last;
    final depIata = first.departureAirport.id;
    final arrIata = last.arrivalAirport.id;
    final depCity = _cityNameForIata(depIata, response);
    final arrCity = _cityNameForIata(arrIata, response);
    final depTime = _formatTime(first.departureAirport.time);
    final arrTime = _formatTime(last.arrivalAirport.time);
    final totalDuration = option.totalDuration;
    final stops = flights.length - 1;
    final layovers = option.layovers ?? [];
    final airlines = flights.map((f) => f.airline).toSet().toList();
    final airlineLogos = flights.map((f) => f.airlineLogo).where((l) => l != null && l.isNotEmpty).toSet().toList();
    final flightNumbers = flights.map((f) => f.flightNumber).join(' · ');
    final airplanes = flights.map((f) => f.airplane).where((a) => a != null && a.isNotEmpty).join(', ');
    final isExpanded = _expandedIndex == index;

    // Layover summary
    String layoverSummary = '';
    if (stops == 0) {
      layoverSummary = 'Direct';
    } else if (layovers.isNotEmpty) {
      final lay = layovers.first;
      layoverSummary = '${stops} stop: ${lay['id']} (${_formatDuration(lay['duration'])})';
    } else {
      layoverSummary = '${stops} stop';
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedIndex = _expandedIndex == index ? null : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isExpanded ? Border.all(color: const Color(0xFF1F2937), width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isExpanded ? 0.10 : 0.04),
              blurRadius: isExpanded ? 16 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (airlineLogos.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      airlineLogos.first!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.contain,
                    ),
                  ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$depTime – $arrTime',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$depCity → $arrCity',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Color(0xFF374151),
                        ),
                      ),
                      Text(
                        '$depIata → $arrIata',
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
            if (isExpanded) ...[
              const SizedBox(height: 16),
              // Timeline for segments and layovers
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < flights.length; i++) ...[
                    _buildItinerarySegment(flights[i]),
                    if (i < flights.length - 1 && layovers.isNotEmpty)
                      _buildLayoverInfo(layovers[i]),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 10),
              Row(
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
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Find departure and arrival images and thumbnails from response.airports
                    String depImage = '', depThumb = '', arrImage = '', arrThumb = '';
                    for (final airportInfo in response.airports) {
                      for (final dep in airportInfo.departure) {
                        if (dep.airport.id == depIata) {
                          depImage = dep.image ?? '';
                          depThumb = dep.thumbnail ?? '';
                        }
                      }
                      for (final arr in airportInfo.arrival) {
                        if (arr.airport.id == arrIata) {
                          arrImage = arr.image ?? '';
                          arrThumb = arr.thumbnail ?? '';
                        }
                      }
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddTripContactsScreen(
                          args: domain.AddContactsArgs(
                            selectedFlight: option,
                            departureCity: depCity,
                            departureAirportCode: depIata,
                            departureImage: depImage,
                            departureThumbnail: depThumb,
                            arrivalCity: arrCity,
                            arrivalAirportCode: arrIata,
                            arrivalImage: arrImage,
                            arrivalThumbnail: arrThumb,
                          ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    'Track Flight',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 3,
                    shadowColor: Colors.black.withOpacity(0.05),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentDetail(Flight flight, int idx, int total) {
    final depIata = flight.departureAirport.id;
    final arrIata = flight.arrivalAirport.id;
    final depTime = _formatTime(flight.departureAirport.time);
    final arrTime = _formatTime(flight.arrivalAirport.time);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (flight.airlineLogo != null && flight.airlineLogo!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  flight.airlineLogo!,
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    '${flight.airline} ${flight.flightNumber} · ${flight.airplane ?? ''}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Color(0xFF374151),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    '$depIata $depTime → $arrIata $arrTime',
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
          ),
        ],
      ),
    );
  }

  // New: Build a timeline segment for the itinerary
  Widget _buildItinerarySegment(Flight flight) {
    final depIata = flight.departureAirport.id;
    final arrIata = flight.arrivalAirport.id;
    final depTime = _formatTime(flight.departureAirport.time);
    final arrTime = _formatTime(flight.arrivalAirport.time);
    final flightNum = flight.airline != null && flight.flightNumber != null
        ? '${flight.airline} ${flight.flightNumber}'
        : (flight.airline ?? flight.flightNumber ?? '');
    final aircraft = flight.airplane ?? '';
    String secondLine = '';
    if (flightNum.isNotEmpty && aircraft.isNotEmpty) {
      secondLine = '$flightNum · $aircraft';
    } else if (flightNum.isNotEmpty) {
      secondLine = flightNum;
    } else if (aircraft.isNotEmpty) {
      secondLine = aircraft;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Airline logo or fallback
          flight.airlineLogo != null && flight.airlineLogo!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  child: Image.network(
                    flight.airlineLogo!,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                )
              : CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF1F2937),
                  child: Text(
                    (flight.airline ?? '?').substring(0, 2).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter',
                    ),
                  ),
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