import 'package:hive/hive.dart';
import 'package:news_weather_hub/data/models/bookmark/bookmark_model.dart';

class BookmarkRepository {
  final Box<BookmarkModel> bookmarkBox;

  BookmarkRepository({required this.bookmarkBox});

  Future<void> addBookmark(BookmarkModel bookmark) async {
    await bookmarkBox.put(bookmark.id, bookmark);
  }

  Future<void> removeBookmark(String id) async {
    await bookmarkBox.delete(id);
  }

  List<BookmarkModel> getAllBookmarks() {
    return bookmarkBox.values.toList();
  }

  bool isBookmarked(String id) {
    return bookmarkBox.containsKey(id);
  }

  Future<void> clearAll() async {
    await bookmarkBox.clear();
  }
}