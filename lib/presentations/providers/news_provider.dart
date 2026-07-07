import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:news_weather_hub/data/datasources/remote/news_api.dart';
import 'package:news_weather_hub/data/repositories/news_repository.dart';
import 'package:news_weather_hub/data/repositories/weather_repository.dart';
import 'package:news_weather_hub/data/models/news/news_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:news_weather_hub/presentations/providers/dio_provider.dart';
import 'package:news_weather_hub/presentations/providers/hive_provider.dart';

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final newsApi = NewsApi(dio);
  final cacheBox = ref.watch(newsCacheBoxProvider);
  final apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
  
  return NewsRepository(
    newsApi: newsApi,
    newsCacheBox: cacheBox,
    apiKey: apiKey,
  );
});

class NewsState {
  final List<ArticleModel> articles;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final bool isCached;
  final DateTime? cachedTime;

  NewsState({
    this.articles = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.isCached = false,
    this.cachedTime,
  });

  NewsState copyWith({
    List<ArticleModel>? articles,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
    bool? isCached,
    DateTime? cachedTime,
  }) {
    return NewsState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isCached: isCached ?? this.isCached,
      cachedTime: cachedTime ?? this.cachedTime,
    );
  }
}

class NewsNotifier extends StateNotifier<NewsState> {
  final NewsRepository repository;

  NewsNotifier(this.repository) : super(NewsState());

  Future<void> fetchHeadlines({String? country, String? category}) async {
    if (state.isLoading) return;
    
    state = state.copyWith(
      isLoading: true,
      error: null,
      articles: [],
      currentPage: 1,
      hasMore: true,
    );
    
    try {
      final response = await repository.getHeadlines(
        country: country,
        category: category,
        page: 1,
      );
      
      state = state.copyWith(
        articles: response.articles,
        isLoading: false,
        hasMore: response.articles.length >= 20,
        isCached: false,
        error: null,
      );
    } on CacheAvailableException catch (e) {
      final cachedNews = repository.getCachedNews();
      state = state.copyWith(
        articles: cachedNews?.articles ?? [],
        isLoading: false,
        isCached: true,
        cachedTime: e.cachedTime,
        hasMore: false,
        error: null,
      );
    } catch (e) {
      // Try cache
      final cached = repository.getCachedNews();
      if (cached != null && cached.articles.isNotEmpty) {
        state = state.copyWith(
          articles: cached.articles,
          isLoading: false,
          isCached: true,
          cachedTime: repository.getCachedNewsTime(),
          hasMore: false,
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

  Future<void> loadMore({String? country, String? category}) async {
    if (state.isLoadingMore || !state.hasMore || state.isCached) return;
    
    state = state.copyWith(isLoadingMore: true);
    
    try {
      final nextPage = state.currentPage + 1;
      final response = await repository.getHeadlines(
        country: country,
        category: category,
        page: nextPage,
      );
      
      state = state.copyWith(
        articles: [...state.articles, ...response.articles],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: response.articles.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final newsProvider = StateNotifierProvider<NewsNotifier, NewsState>((ref) {
  final repository = ref.watch(newsRepositoryProvider);
  return NewsNotifier(repository);
});