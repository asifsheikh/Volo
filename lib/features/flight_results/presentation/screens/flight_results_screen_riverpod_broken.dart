import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_theme.dart';
import '../providers/flight_results_provider.dart';
import '../../domain/entities/flight_results_state.dart' as domain;

/// Flight Results Screen using Riverpod + Clean Architecture
class FlightResultsScreen extends ConsumerStatefulWidget {
  final String departureCity;
  final String arrivalCity;
  final String date;
  final String? flightNumber;

  const FlightResultsScreen({
    Key? key,
    required this.departureCity,
    required this.arrivalCity,
    required this.date,
    this.flightNumber,
  }) : super(key: key);

  @override
  ConsumerState<FlightResultsScreen> createState() => _FlightResultsScreenState();
}

class _FlightResultsScreenState extends ConsumerState<FlightResultsScreen> {
  @override
  Widget build(BuildContext context) {
    final flightResultsAsync = ref.watch(flightResultsProviderProvider(
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
          'Flight Results',
          style: AppTheme.headlineMedium,
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: flightResultsAsync.when(
          data: (flightResults) => _buildFlightResultsContent(flightResults),
          loading: () => _buildLoadingContent(),
          error: (error, stackTrace) => _buildErrorContent(error.toString()),
        ),
      ),
    );
  }

  Widget _buildFlightResultsContent(domain.FlightResultsState flightResults) {
    final allFlights = [...flightResults.bestFlights, ...flightResults.otherFlights];
    
    return Column(
      children: [
        // Route summary
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flightResults.departureCity,
                      style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Departure',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.textPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.flight_takeoff,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      flightResults.arrivalCity,
                      style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Arrival',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Results count and price info
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${allFlights.length} flights found',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'From \$${_getLowestPrice(allFlights)}',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.success,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Flight list
        Expanded(
          child: allFlights.isEmpty
              ? _buildNoResultsWidget()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: allFlights.length,
                  itemBuilder: (context, index) {
                    final flight = allFlights[index];
                    return _buildFlightCard(flight, index == 0);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLoadingContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Searching for flights...'),
        ],
      ),
    );
  }

  Widget _buildErrorContent(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading flights',
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
              ref.invalidate(flightResultsProviderProvider(
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

  Widget _buildNoResultsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flight_takeoff,
            size: 64,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 16),
          Text(
            'No flights found',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightCard(domain.FlightOption flight, bool isBest) {
    final mainFlight = flight.flights.first;
    final isDirect = flight.flights.length == 1;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Flight header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isBest ? const Color(0xFF059669).withOpacity(0.1) : Colors.transparent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Airline logo
                if (flight.airlineLogo != null)
                  Container(
                    width: 40,
                    height: 40,
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
                    width: 40,
                    height: 40,
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
                
                const SizedBox(width: 12),
                
                // Flight info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mainFlight.airline,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        mainFlight.flightNumber,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${flight.price}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      isDirect ? 'Direct' : '${flight.flights.length} stops',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Flight details
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Time and duration
                Row(
                  children: [
                    // Departure
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatTime(mainFlight.departureAirport.time),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mainFlight.departureAirport.id,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Duration
                    Column(
                      children: [
                        Container(
                          width: 60,
                          height: 1,
                          color: const Color(0xFFE5E7EB),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDuration(flight.totalDuration),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    
                    // Arrival
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatTime(mainFlight.arrivalAirport.time),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mainFlight.arrivalAirport.id,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Additional info
                if (mainFlight.airplane != null || (mainFlight.extensions?.isNotEmpty ?? false))
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (mainFlight.airplane != null)
                          Text(
                            'Aircraft: ${mainFlight.airplane}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Color(0xFF374151),
                            ),
                          ),
                        if (mainFlight.extensions?.isNotEmpty ?? false)
                          Text(
                            mainFlight.extensions!.first,
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
          ),
        ],
      ),
    );
  }

  String _formatTime(String timeString) {
    try {
      final dateTime = DateTime.parse(timeString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return timeString;
    }
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}m';
    }
  }

  int _getLowestPrice(List<domain.FlightOption> flights) {
    if (flights.isEmpty) return 0;
    return flights.map((flight) => flight.price).reduce((a, b) => a < b ? a : b);
  }
} 