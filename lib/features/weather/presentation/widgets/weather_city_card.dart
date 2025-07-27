import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/weather_state.dart' as domain;
import '../../../../theme/app_theme.dart';

/// Weather city card widget to display weather information
class WeatherCityCard extends ConsumerWidget {
  final domain.WeatherState weather;
  final bool isDeparture;
  final VoidCallback? onTap;

  const WeatherCityCard({
    Key? key,
    required this.weather,
    this.isDeparture = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getWeatherGradient(weather.current.weather_condition),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Weather icon background
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                _getWeatherIcon(weather.current.weather_icon),
                size: 80,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // City name and departure/arrival indicator
                  Row(
                    children: [
                      Icon(
                        isDeparture ? Icons.flight_takeoff : Icons.flight_land,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          weather.cityName,
                          style: AppTheme.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // Weather information
                  Row(
                    children: [
                      // Temperature
                      Text(
                        '${weather.current.temperature.round()}°C',
                        style: AppTheme.headlineMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Weather description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              weather.current.weather_description.toUpperCase(),
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Humidity: ${weather.current.humidity}%',
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getWeatherGradient(String weatherCondition) {
    switch (weatherCondition.toLowerCase()) {
      case 'clear':
        return [
          const Color(0xFF4A90E2), // Sky blue
          const Color(0xFF87CEEB), // Light sky blue
        ];
      case 'clouds':
      case 'cloudy':
        return [
          const Color(0xFF6B7280), // Gray
          const Color(0xFF9CA3AF), // Light gray
        ];
      case 'rain':
      case 'rainy':
      case 'drizzle':
        return [
          const Color(0xFF374151), // Dark gray
          const Color(0xFF6B7280), // Gray
        ];
      case 'snow':
      case 'snowy':
        return [
          const Color(0xFFE5E7EB), // Light gray
          const Color(0xFFF3F4F6), // Very light gray
        ];
      case 'haze':
      case 'fog':
      case 'mist':
        return [
          const Color(0xFF9CA3AF), // Gray
          const Color(0xFFD1D5DB), // Light gray
        ];
      case 'thunderstorm':
        return [
          const Color(0xFF1F2937), // Dark gray
          const Color(0xFF374151), // Gray
        ];
      default:
        return [
          const Color(0xFF4A90E2), // Default sky blue
          const Color(0xFF87CEEB), // Light sky blue
        ];
    }
  }

  IconData _getWeatherIcon(String weatherIcon) {
    // Map OpenWeatherMap icon codes to Flutter icons
    switch (weatherIcon) {
      case '01d': // clear sky day
        return Icons.wb_sunny;
      case '01n': // clear sky night
        return Icons.nightlight_round;
      case '02d': // few clouds day
      case '02n': // few clouds night
        return Icons.cloud;
      case '03d': // scattered clouds day
      case '03n': // scattered clouds night
        return Icons.cloud;
      case '04d': // broken clouds day
      case '04n': // broken clouds night
        return Icons.cloud;
      case '09d': // shower rain day
      case '09n': // shower rain night
        return Icons.grain;
      case '10d': // rain day
      case '10n': // rain night
        return Icons.water_drop;
      case '11d': // thunderstorm day
      case '11n': // thunderstorm night
        return Icons.thunderstorm;
      case '13d': // snow day
      case '13n': // snow night
        return Icons.ac_unit;
      case '50d': // mist day
      case '50n': // mist night
        return Icons.waves;
      default:
        return Icons.wb_sunny;
    }
  }
} 