import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:news_weather_hub/data/models/bookmark/bookmark_model.dart';

final weatherCacheBoxProvider = Provider<Box>((ref) {
  return Hive.box('weather_cache');
});

final newsCacheBoxProvider = Provider<Box>((ref) {
  return Hive.box('news_cache');
});

final bookmarkBoxProvider = Provider<Box<BookmarkModel>>((ref) {
  return Hive.box<BookmarkModel>('bookmarks');
});