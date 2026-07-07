import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_weather_hub/core/theme/app_theme.dart';
import 'package:news_weather_hub/presentations/providers/settings_provider.dart';
import 'package:news_weather_hub/presentations/screens/dashboard/dashboard_screen.dart';

class NewsWeatherApp extends ConsumerWidget {
  const NewsWeatherApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: 'News & Weather Hub',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}