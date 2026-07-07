import 'package:dio/dio.dart';
import 'package:news_weather_hub/data/models/news/news_model.dart';

abstract class NewsApi {
  factory NewsApi(Dio dio, {String? baseUrl}) = _NewsApi;

  Future<NewsResponse> getTopHeadlines({
    required String apiKey,
    String? country,
    String? category,
    int? page,
    int? pageSize,
  });
}

class _NewsApi implements NewsApi {
  _NewsApi(this._dio, {String? baseUrl}) : _baseUrl = baseUrl ?? 'https://newsapi.org/v2';

  final Dio _dio;
  final String _baseUrl;

  @override
  Future<NewsResponse> getTopHeadlines({
    required String apiKey,
    String? country,
    String? category,
    int? page,
    int? pageSize,
  }) async {
    final response = await _dio.get(
      '$_baseUrl/top-headlines',
      queryParameters: {
        'apiKey': apiKey,
        if (country != null) 'country': country,
        if (category != null) 'category': category,
        if (page != null) 'page': page,
        if (pageSize != null) 'pageSize': pageSize,
      },
    );

    return NewsResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
