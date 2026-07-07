import 'package:hive/hive.dart';
import 'package:news_weather_hub/data/models/bookmark/bookmark_model.dart';



@HiveType(typeId: 0)
class BookmarkAdapter extends TypeAdapter<BookmarkModel> {
  @override
  final int typeId = 0;

  @override
  BookmarkModel read(BinaryReader reader) {
    return BookmarkModel(
      id: reader.readString(),
      title: reader.readString(),
      description: reader.readString(),
      url: reader.readString(),
      imageUrl: reader.readString(),
      sourceName: reader.readString(),
      publishedAt: reader.readString(),
      savedAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, BookmarkModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description ?? '');
    writer.writeString(obj.url);
    writer.writeString(obj.imageUrl ?? '');
    writer.writeString(obj.sourceName);
    writer.writeString(obj.publishedAt);
    writer.writeString(obj.savedAt.toIso8601String());
  }
}

Future<void> registerHiveAdapters() async {
  Hive.registerAdapter(BookmarkAdapter());
  
  // Open boxes
  await Hive.openBox<BookmarkModel>('bookmarks');
  await Hive.openBox('weather_cache');
  await Hive.openBox('news_cache');
  await Hive.openBox('settings');
}