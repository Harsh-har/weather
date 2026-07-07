import 'package:json_annotation/json_annotation.dart';

part 'weather_model.g.dart';

@JsonSerializable()
class WeatherResponse {
  final double latitude;
  final double longitude;
  final double elevation;
  final CurrentWeather current_weather;
  final DailyWeather daily;

  WeatherResponse({
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.current_weather,
    required this.daily,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      elevation: (json['elevation'] as num).toDouble(),
      current_weather: CurrentWeather.fromJson(
          json['current_weather'] as Map<String, dynamic>),
      daily: DailyWeather.fromJson(json['daily'] as Map<String, dynamic>),
    );
  }
  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'elevation': elevation,
        'current_weather': current_weather.toJson(),
        'daily': daily.toJson(),
      };
}

@JsonSerializable()
class CurrentWeather {
  final double temperature;
  final int weathercode;
  final double windspeed;
  final int winddirection;

  CurrentWeather({
    required this.temperature,
    required this.weathercode,
    required this.windspeed,
    required this.winddirection,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) =>
      _$CurrentWeatherFromJson(json);
  Map<String, dynamic> toJson() => _$CurrentWeatherToJson(this);
}

@JsonSerializable()
class DailyWeather {
  final List<String> time;
  final List<double> temperature_2m_max;
  final List<double> temperature_2m_min;
  final List<int> weathercode;

  DailyWeather({
    required this.time,
    required this.temperature_2m_max,
    required this.temperature_2m_min,
    required this.weathercode,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) =>
      _$DailyWeatherFromJson(json);
  Map<String, dynamic> toJson() => _$DailyWeatherToJson(this);
}

@JsonSerializable()
class GeocodingResponse {
  final List<LocationResult> results;

  GeocodingResponse({required this.results});

  factory GeocodingResponse.fromJson(Map<String, dynamic> json) =>
      _$GeocodingResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GeocodingResponseToJson(this);
}

@JsonSerializable()
class LocationResult {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1;

  LocationResult({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
  });

  factory LocationResult.fromJson(Map<String, dynamic> json) =>
      _$LocationResultFromJson(json);
  Map<String, dynamic> toJson() => _$LocationResultToJson(this);
}