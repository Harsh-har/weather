import 'package:dio/dio.dart';
import 'package:news_weather_hub/data/datasources/remote/weather_api.dart';
import 'package:news_weather_hub/data/models/weather/weather_model.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class WeatherRepository {
  final WeatherApi weatherApi;
  final GeocodingApi geocodingApi;
  final Box weatherCacheBox;

  WeatherRepository({
    required this.weatherApi,
    required this.geocodingApi,
    required this.weatherCacheBox,
  });

  Future<WeatherResponse> getWeather(double lat, double lon) async {
    try {
      final response = await weatherApi.getWeather(
        latitude: lat,
        longitude: lon,
      );
      
      // Cache the response
      await weatherCacheBox.put('cached_weather', response.toJson());
      await weatherCacheBox.put('cached_time', DateTime.now().toIso8601String());
      
      return response;
    } on DioException catch (e) {
      // Check connectivity
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) {
        throw Exception('No internet connection');
      }
      
      // Try to get cached data
      final cached = weatherCacheBox.get('cached_weather');
      if (cached != null) {
        final cachedTime = weatherCacheBox.get('cached_time');
        throw CacheAvailableException<WeatherResponse>(
          WeatherResponse.fromJson(cached),
          DateTime.parse(cachedTime),
        );
      }
      
      rethrow;
    }
  }

  Future<List<LocationResult>> searchCity(String query) async {
    try {
      final response = await geocodingApi.searchCity(name: query);
      return response.results;
    } catch (e) {
      rethrow;
    }
  }

  WeatherResponse? getCachedWeather() {
    final cached = weatherCacheBox.get('cached_weather');
    if (cached != null) {
      return WeatherResponse.fromJson(cached);
    }
    return null;
  }

  DateTime? getCachedTime() {
    final time = weatherCacheBox.get('cached_time');
    if (time != null) {
      return DateTime.parse(time);
    }
    return null;
  }
}

class CacheAvailableException<T> implements Exception {
  final T cachedData;
  final DateTime cachedTime;

  CacheAvailableException(this.cachedData, this.cachedTime);
}