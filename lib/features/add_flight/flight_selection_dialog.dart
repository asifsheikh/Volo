import 'package:flutter/material.dart';

class FlightSelectionDialog extends StatelessWidget {
  final List<Map<String, dynamic>> flights;
  final String ticketType;
  final Function(Map<String, dynamic>) onFlightSelected;
  final int? originalFlightCount; // Number of flights before deduplication

  const FlightSelectionDialog({
    super.key,
    required this.flights,
    required this.ticketType,
    required this.onFlightSelected,
    this.originalFlightCount,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF008080).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.flight_takeoff,
                    color: Color(0xFF008080),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDialogTitle(),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select which flight you want to add',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (originalFlightCount != null && originalFlightCount! > flights.length) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${originalFlightCount! - flights.length} duplicate flights removed automatically',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Flight options
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: flights.length,
                itemBuilder: (context, index) {
                  final flight = flights[index];
                  return _FlightOptionCard(
                    flight: flight,
                    index: index,
                    ticketType: ticketType,
                    onTap: () {
                      Navigator.of(context).pop();
                      onFlightSelected(flight);
                    },
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDialogTitle() {
    switch (ticketType) {
      case 'round-trip':
        return 'Round Trip Ticket';
      case 'multi-city':
        return 'Multi-City Ticket';
      default:
        return 'Multiple Flights';
    }
  }
}

class _FlightOptionCard extends StatelessWidget {
  final Map<String, dynamic> flight;
  final int index;
  final String ticketType;
  final VoidCallback onTap;

  const _FlightOptionCard({
    required this.flight,
    required this.index,
    required this.ticketType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final departureCity = flight['departureCity'] ?? '';
    final departureAirport = flight['departureAirport'] ?? '';
    final arrivalCity = flight['arrivalCity'] ?? '';
    final arrivalAirport = flight['arrivalAirport'] ?? '';
    final flightNumber = flight['flightNumber'] ?? '';
    final departureDate = flight['departureDate'] ?? '';
    final isLayover = flight['isLayover'] ?? false;
    final layoverCity = flight['layoverCity'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flight number and date
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF008080).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        flightNumber,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Color(0xFF008080),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(departureDate),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Route with layover info
                Column(
                  children: [
                    // Main route row with plane icon centered
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _AirportInfo(
                            city: departureCity,
                            airport: departureAirport,
                            isDeparture: true,
                          ),
                        ),
                        
                        // Flight arrow - perfectly centered between city names
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.flight_takeoff,
                            color: Colors.grey[400],
                            size: 16,
                          ),
                        ),
                        
                        Expanded(
                          child: _AirportInfo(
                            city: arrivalCity,
                            airport: arrivalAirport,
                            isDeparture: false,
                          ),
                        ),
                      ],
                    ),
                    
                    // Layover info below the route (if applicable)
                    if (isLayover) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Via $layoverCity',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                
                // Leg indicator for round-trip
                if (ticketType == 'round-trip') ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: index == 0 ? Colors.blue[50] : Colors.green[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      index == 0 ? 'Outbound' : 'Return',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        color: index == 0 ? Colors.blue[700] : Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

class _AirportInfo extends StatelessWidget {
  final String city;
  final String airport;
  final bool isDeparture;

  const _AirportInfo({
    required this.city,
    required this.airport,
    required this.isDeparture,
  });

  @override
  Widget build(BuildContext context) {
    final isIataCode = RegExp(r'^[A-Z]{3}$').hasMatch(airport.toUpperCase());
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // City name - primary focus for alignment
        Text(
          city,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        // Airport code/name - secondary information
        if (isIataCode) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              airport.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 10,
                color: Colors.green[700],
              ),
            ),
          ),
        ] else ...[
          Text(
            airport,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
} 