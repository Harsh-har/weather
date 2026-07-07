import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_weather_hub/core/utlis/error_view.dart';
import 'package:news_weather_hub/presentations/providers/news_provider.dart';
import 'package:news_weather_hub/presentations/providers/weather_provider.dart';
import 'package:news_weather_hub/presentations/screens/dashboard/widgets/forecast_section.dart';
import 'package:news_weather_hub/presentations/screens/dashboard/widgets/loading_widget.dart';
import 'package:news_weather_hub/presentations/screens/dashboard/widgets/news_section.dart';
import 'package:news_weather_hub/presentations/screens/dashboard/widgets/weather_section.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAllData();
    });
  }

  Future<void> _fetchAllData() async {
    final weatherNotifier = ref.read(weatherProvider.notifier);
    final newsNotifier = ref.read(newsProvider.notifier);
    
    // Get location and fetch weather
    // For now using default coordinates (London)
    await weatherNotifier.fetchWeather(51.5074, -0.1278);
    await newsNotifier.fetchHeadlines();
  }

  Future<void> _refreshAll() async {
    await _fetchAllData();
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherProvider);
    final newsState = ref.watch(newsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weather Section
              if (weatherState.isLoading && weatherState.data == null)
                const LoadingWidget()
              else if (weatherState.error != null && weatherState.data == null)
                ErrorView(
                  error: weatherState.error!,
                  onRetry: _fetchAllData,
                )
              else if (weatherState.data != null)
                WeatherSection(
                  weather: weatherState.data!,
                  isCached: weatherState.isCached,
                  cachedTime: weatherState.cachedTime,
                ),

              const SizedBox(height: 24),

              // Forecast Section
              if (weatherState.data != null)
                ForecastSection(weather: weatherState.data!),

              const SizedBox(height: 24),

              // News Section
              if (newsState.isLoading && newsState.articles.isEmpty)
                const LoadingWidget()
              else if (newsState.error != null && newsState.articles.isEmpty)
                ErrorView(
                  error: newsState.error!,
                  onRetry: _fetchAllData,
                )
              else if (newsState.articles.isNotEmpty)
                NewsSection(
                  articles: newsState.articles,
                  isCached: newsState.isCached,
                  cachedTime: newsState.cachedTime,
                  onLoadMore: () {
                    ref.read(newsProvider.notifier).loadMore();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}