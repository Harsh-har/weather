import 'package:dio/dio.dart';
import 'package:news_weather_hub/data/datasources/remote/news_api.dart';
import 'package:news_weather_hub/data/models/news/news_model.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:news_weather_hub/data/repositories/weather_repository.dart';

class NewsRepository {
  final NewsApi newsApi;
  final Box newsCacheBox;
  final String apiKey;

  NewsRepository({
    required this.newsApi,
    required this.newsCacheBox,
    required this.apiKey,
  });

  Future<NewsResponse> getHeadlines({
    String? country,
    String? category,
    int page = 1,
  }) async {
    try {
      final response = await newsApi.getTopHeadlines(
        apiKey: apiKey,
        country: country ?? 'us',
        category: category,
        page: page,
        pageSize: 20,
      );
      
      // Cache only first page
      if (page == 1) {
        await newsCacheBox.put('cached_news', response.toJson());
        await newsCacheBox.put('cached_news_time', DateTime.now().toIso8601String());
      }
      
      return response;
    } on DioException catch (e) {
      // Check connectivity
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) {
        throw Exception('No internet connection');
      }
      
      // Handle rate limiting
      if (e.response?.statusCode == 429) {
        throw Exception('API rate limit exceeded. Please try again later.');
      }
      
      // Try to get cached data
      if (page == 1) {
        final cached = newsCacheBox.get('cached_news');
        if (cached != null) {
          final cachedTime = newsCacheBox.get('cached_news_time');
          throw CacheAvailableException<NewsResponse>(
            NewsResponse.fromJson(cached),
            DateTime.parse(cachedTime),
          );
        }
      }
      
      rethrow;
    }
  }

  NewsResponse? getCachedNews() {
    final cached = newsCacheBox.get('cached_news');
    if (cached != null) {
      return NewsResponse.fromJson(cached);
    }
    return null;
  }

  DateTime? getCachedNewsTime() {
    final time = newsCacheBox.get('cached_news_time');
    if (time != null) {
      return DateTime.parse(time);
    }
    return null;
  }
}