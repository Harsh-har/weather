import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:news_weather_hub/core/app.dart';
import 'package:news_weather_hub/data/datasources/local/hive_adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load();
  
  // Initialize Hive
  await Hive.initFlutter();
  await registerHiveAdapters();
  
  // Run the app with ProviderScope
  runApp(
    const ProviderScope(
      child: NewsWeatherApp(),
    ),
  );
}