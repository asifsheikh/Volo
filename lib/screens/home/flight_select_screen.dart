import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/flight_api_service.dart';

class FlightSelectScreen extends StatefulWidget {
  final Future<FlightSearchResponse> searchFuture;
  final String departureCity;
  final String arrivalCity;
  final String date;

  const FlightSelectScreen({
    Key? key,
    required this.searchFuture,
    required this.departureCity,
    required this.arrivalCity,
    required this.date,
  }) : super(key: key);

  @override
  State<FlightSelectScreen> createState() => _FlightSelectScreenState();
}

class _FlightSelectScreenState extends State<FlightSelectScreen> {
  int? _expandedIndex;

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
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).pop(),
          splashRadius: 24,
        ),
        title: const Text(
          'Pick Your Flight',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Color(0xFF111827),
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: FutureBuilder<FlightSearchResponse>(
          future: widget.searchFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F2937)),
                ),
              );
            } else if (snapshot.hasError) {
              return _buildError(snapshot.error.toString());
            } else if (!snapshot.hasData || (snapshot.data!.bestFlights.isEmpty && snapshot.data!.otherFlights.isEmpty)) {
              return _buildError('No flights found. Try different search criteria.');
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

  Widget _buildError(String message) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 56, color: Color(0xFF9CA3AF)),
              const SizedBox(height: 16),
              Text(
                'Oops!',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
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
              for (int i = 0; i < flights.length; i++) ...[
                _buildSegmentDetail(flights[i], i, flights.length),
                if (i < flights.length - 1 && layovers.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.airline_stops, size: 18, color: Color(0xFF6B7280)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Layover: ${layovers[i]['id']} (${_formatDuration(layovers[i]['duration'])})',
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    'Track Flight',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2937),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 6,
                    shadowColor: Colors.black.withOpacity(0.08),
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