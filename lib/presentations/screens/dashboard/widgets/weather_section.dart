import 'package:flutter/material.dart';
import 'package:news_weather_hub/data/models/weather/weather_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:news_weather_hub/presentations/providers/settings_provider.dart';
import 'package:news_weather_hub/presentations/screens/dashboard/widgets/city_search_dialog.dart';

class WeatherSection extends ConsumerStatefulWidget {
  final WeatherResponse weather;
  final bool isCached;
  final DateTime? cachedTime;

  const WeatherSection({
    super.key,
    required this.weather,
    this.isCached = false,
    this.cachedTime,
  });

  @override
  ConsumerState<WeatherSection> createState() => _WeatherSectionState();
}

class _WeatherSectionState extends ConsumerState<WeatherSection> {
  String _cityName = 'Current Location';

  @override
  void initState() {
    super.initState();
    _getCityName();
  }

  Future<void> _getCityName() async {
    // In a real app, you'd reverse geocode or use the default city from settings
    final defaultCity = ref.read(defaultCityProvider);
    setState(() {
      _cityName = defaultCity;
    });
  }

  @override
  Widget build(BuildContext context) {
    final weather = widget.weather;
    final current = weather.current_weather;
    final weatherCode = current.weathercode;
    final weatherCondition = _getWeatherCondition(weatherCode);
    final isDayTime = _isDayTime();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDayTime
              ? [Colors.blue.shade400, Colors.lightBlue.shade100]
              : [Colors.indigo.shade900, Colors.purple.shade800],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with city search
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _cityName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => _showCitySearch(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Temperature
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${current.temperature.round()}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weatherCondition,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              _buildWeatherIcon(weatherCode, isDayTime),
            ],
          ),

          const SizedBox(height: 20),

          // Weather details
          Row(
            children: [
              _buildInfoTile(
                icon: Icons.water_drop,
                label: 'Humidity',
                value: '${current.temperature}%',
              ),
              _buildInfoTile(
                icon: Icons.air,
                label: 'Wind Speed',
                value: '${current.windspeed} km/h',
              ),
            ],
          ),

          if (widget.isCached) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: Colors.white.withOpacity(0.8), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Showing cached data from ${DateFormat('HH:mm').format(widget.cachedTime ?? DateTime.now())}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCitySearch(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CitySearchDialog(),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String label, required String value}) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getWeatherCondition(int code) {
    switch (code) {
      case 0:
        return 'Clear sky';
      case 1:
        return 'Mainly clear';
      case 2:
        return 'Partly cloudy';
      case 3:
        return 'Overcast';
      case 45:
      case 48:
        return 'Fog';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 80:
      case 81:
      case 82:
        return 'Rain showers';
      default:
        return 'Unknown';
    }
  }

  Widget _buildWeatherIcon(int code, bool isDay) {
    String icon;
    switch (code) {
      case 0:
        icon = isDay ? '☀️' : '🌙';
        break;
      case 1:
      case 2:
        icon = isDay ? '⛅' : '☁️';
        break;
      case 3:
        icon = '☁️';
        break;
      case 45:
      case 48:
        icon = '🌫️';
        break;
      case 51:
      case 53:
      case 55:
        icon = '🌧️';
        break;
      case 61:
      case 63:
      case 65:
        icon = '🌧️';
        break;
      case 71:
      case 73:
      case 75:
        icon = '🌨️';
        break;
      default:
        icon = '🌤️';
    }
    return Text(icon, style: const TextStyle(fontSize: 64));
  }

  bool _isDayTime() {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 18;
  }
}