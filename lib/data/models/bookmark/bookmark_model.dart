import 'package:hive/hive.dart';


@HiveType(typeId: 0)
class BookmarkModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String? description;
  
  @HiveField(3)
  final String url;
  
  @HiveField(4)
  final String? imageUrl;
  
  @HiveField(5)
  final String sourceName;
  
  @HiveField(6)
  final String publishedAt;
  
  @HiveField(7)
  final DateTime savedAt;

  BookmarkModel({
    required this.id,
    required this.title,
    this.description,
    required this.url,
    this.imageUrl,
    required this.sourceName,
    required this.publishedAt,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': url,
      'imageUrl': imageUrl,
      'sourceName': sourceName,
      'publishedAt': publishedAt,
      'savedAt': savedAt.toIso8601String(),
    };
  }
}