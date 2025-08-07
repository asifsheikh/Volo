import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../services/flight_api_service.dart';
import '../../../../theme/app_theme.dart';

class FlightResultsScreen extends StatelessWidget {
  final FlightSearchResponse searchResponse;
  final String departureCity;
  final String arrivalCity;
  final String date;

  const FlightResultsScreen({
    Key? key,
    required this.searchResponse,
    required this.departureCity,
    required this.arrivalCity,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allFlights = [...searchResponse.bestFlights, ...searchResponse.otherFlights];
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
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
        child: Column(
          children: [
            // Route summary
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          departureCity,
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
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flight_takeoff,
                      color: AppTheme.textOnPrimary,
                      size: 16,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          arrivalCity,
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
              decoration: AppTheme.cardDecoration,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${allFlights.length} flights found',
                    style: AppTheme.bodyMedium,
                  ),
                  Text(
                    'From \$${_getLowestPrice(allFlights)}',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.success,
                      fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }

  Widget _buildNoResultsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.flight_takeoff,
            size: 64,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No flights found',
            style: AppTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildFlightCard(FlightOption flight, bool isBest) {
    final mainFlight = flight.flights.first;
    final isDirect = flight.flights.length == 1;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          // Flight header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isBest ? AppTheme.success.withOpacity(0.1) : Colors.transparent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Airline logo
                if (mainFlight.airlineLogo != null)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(mainFlight.airlineLogo!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.borderPrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.flight,
                      color: AppTheme.textSecondary,
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
                        style: AppTheme.titleMedium,
                      ),
                      Text(
                        mainFlight.flightNumber,
                        style: AppTheme.bodyMedium,
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
                      style: AppTheme.titleLarge,
                    ),
                    if (isBest)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.success,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Best',
                          style: AppTheme.labelSmall.copyWith(color: AppTheme.textOnPrimary),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Flight details
          Padding(
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
                            style: AppTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mainFlight.departureAirport.id,
                            style: AppTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    
                    // Duration and stops
                    Column(
                      children: [
                        Text(
                          _formatDuration(flight.totalDuration),
                          style: AppTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDirect ? AppTheme.success.withOpacity(0.1) : AppTheme.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isDirect ? 'Direct' : '${flight.flights.length - 1} stop${flight.flights.length > 2 ? 's' : ''}',
                            style: AppTheme.labelSmall.copyWith(
                              color: isDirect ? AppTheme.success : AppTheme.warning,
                            ),
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
                            style: AppTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mainFlight.arrivalAirport.id,
                            style: AppTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Additional info
                if (mainFlight.airplane != null || mainFlight.extensions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (mainFlight.airplane != null)
                          Text(
                            'Aircraft: ${mainFlight.airplane}',
                            style: AppTheme.bodySmall,
                          ),
                        if (mainFlight.extensions.isNotEmpty)
                          Text(
                            mainFlight.extensions.first,
                            style: AppTheme.bodySmall,
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

  int _getLowestPrice(List<FlightOption> flights) {
    if (flights.isEmpty) return 0;
    return flights.map((flight) => flight.price).reduce((a, b) => a < b ? a : b);
  }
} 