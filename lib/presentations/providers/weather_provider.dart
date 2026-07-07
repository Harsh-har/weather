import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:news_weather_hub/data/datasources/remote/weather_api.dart';
import 'package:news_weather_hub/data/repositories/weather_repository.dart';
import 'package:news_weather_hub/data/models/weather/weather_model.dart';
import 'package:news_weather_hub/presentations/providers/dio_provider.dart';
import 'package:news_weather_hub/presentations/providers/hive_provider.dart';

// Repository provider
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final weatherApi = WeatherApi(dio);
  final geocodingApi = GeocodingApi(dio);
  final cacheBox = ref.watch(weatherCacheBoxProvider);
  
  return WeatherRepository(
    weatherApi: weatherApi,
    geocodingApi: geocodingApi,
    weatherCacheBox: cacheBox,
  );
});

// Weather state
class WeatherState {
  final WeatherResponse? data;
  final bool isLoading;
  final String? error;
  final bool isCached;
  final DateTime? cachedTime;

  WeatherState({
    this.data,
    this.isLoading = false,
    this.error,
    this.isCached = false,
    this.cachedTime,
  });

  WeatherState copyWith({
    WeatherResponse? data,
    bool? isLoading,
    String? error,
    bool? isCached,
    DateTime? cachedTime,
  }) {
    return WeatherState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isCached: isCached ?? this.isCached,
      cachedTime: cachedTime ?? this.cachedTime,
    );
  }
}

class WeatherNotifier extends StateNotifier<WeatherState> {
  final WeatherRepository repository;

  WeatherNotifier(this.repository) : super(WeatherState());

  Future<void> fetchWeather(double lat, double lon) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final weather = await repository.getWeather(lat, lon);
      state = state.copyWith(
        data: weather,
        isLoading: false,
        isCached: false,
        error: null,
      );
    } on CacheAvailableException catch (e) {
      state = state.copyWith(
        data: e.cachedData,
        isLoading: false,
        isCached: true,
        cachedTime: e.cachedTime,
        error: null,
      );
    } catch (e) {
      // Try to load from cache
      final cached = repository.getCachedWeather();
      if (cached != null) {
        state = state.copyWith(
          data: cached,
          isLoading: false,
          isCached: true,
          cachedTime: repository.getCachedTime(),
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      }
    }
  }

  Future<List<LocationResult>> searchCity(String query) async {
    try {
      return await repository.searchCity(query);
    } catch (e) {
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  final repository = ref.watch(weatherRepositoryProvider);
  return WeatherNotifier(repository);
});