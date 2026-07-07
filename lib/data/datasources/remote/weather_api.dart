import 'package:dio/dio.dart';
import 'package:news_weather_hub/data/models/weather/weather_model.dart';

abstract class WeatherApi {
  factory WeatherApi(Dio dio, {String baseUrl}) = WeatherApiImpl;

  Future<WeatherResponse> getWeather({
    required double latitude,
    required double longitude,
    bool currentWeather = true,
    String daily = 'temperature_2m_max,temperature_2m_min,weathercode',
    String timezone = 'auto',
  });
}

abstract class GeocodingApi {
  factory GeocodingApi(Dio dio, {String baseUrl}) = GeocodingApiImpl;

  Future<GeocodingResponse> searchCity({
    required String name,
    int count = 10,
  });
}

class WeatherApiImpl implements WeatherApi {
  final Dio _dio;
  final String _baseUrl;

  WeatherApiImpl(this._dio, {String? baseUrl}) 
      : _baseUrl = baseUrl ?? 'https://api.open-meteo.com';

  @override
  Future<WeatherResponse> getWeather({
    required double latitude,
    required double longitude,
    bool currentWeather = true,
    String daily = 'temperature_2m_max,temperature_2m_min,weathercode',
    String timezone = 'auto',
  }) async {
    final response = await _dio.get(
      '$_baseUrl/v1/forecast',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'current_weather': currentWeather,
        'daily': daily,
        'timezone': timezone,
      },
    );

    return WeatherResponse.fromJson(response.data as Map<String, dynamic>);
  }
}

class GeocodingApiImpl implements GeocodingApi {
  final Dio _dio;
  final String _baseUrl;

  GeocodingApiImpl(this._dio, {String? baseUrl}) 
      : _baseUrl = baseUrl ?? 'https://geocoding-api.open-meteo.com';

  @override
  Future<GeocodingResponse> searchCity({
    required String name,
    int count = 10,
  }) async {
    final response = await _dio.get(
      '$_baseUrl/v1/search',
      queryParameters: {
        'name': name,
        'count': count,
      },
    );

    return GeocodingResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
