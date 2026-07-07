import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:news_weather_hub/data/models/bookmark/bookmark_model.dart';
import 'package:news_weather_hub/data/repositories/bookmark_repoistry.dart';
import 'package:news_weather_hub/presentations/providers/hive_provider.dart';

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  final box = ref.watch(bookmarkBoxProvider);
  return BookmarkRepository(bookmarkBox: box);
});

class BookmarkState {
  final List<BookmarkModel> bookmarks;
  final bool isLoading;

  BookmarkState({
    this.bookmarks = const [],
    this.isLoading = false,
  });

  BookmarkState copyWith({
    List<BookmarkModel>? bookmarks,
    bool? isLoading,
  }) {
    return BookmarkState(
      bookmarks: bookmarks ?? this.bookmarks,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class BookmarkNotifier extends StateNotifier<BookmarkState> {
  final BookmarkRepository repository;

  BookmarkNotifier(this.repository) : super(BookmarkState());

  void loadBookmarks() {
    state = state.copyWith(isLoading: true);
    final bookmarks = repository.getAllBookmarks();
    state = state.copyWith(
      bookmarks: bookmarks,
      isLoading: false,
    );
  }

  Future<void> addBookmark(BookmarkModel bookmark) async {
    await repository.addBookmark(bookmark);
    loadBookmarks();
  }

  Future<void> removeBookmark(String id) async {
    await repository.removeBookmark(id);
    loadBookmarks();
  }

  bool isBookmarked(String id) {
    return repository.isBookmarked(id);
  }

  Future<void> clearAll() async {
    await repository.clearAll();
    loadBookmarks();
  }
}

final bookmarkProvider = StateNotifierProvider<BookmarkNotifier, BookmarkState>((ref) {
  final repository = ref.watch(bookmarkRepositoryProvider);
  return BookmarkNotifier(repository);
});