import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_weather_hub/data/models/news/news_model.dart';
import 'package:news_weather_hub/data/models/bookmark/bookmark_model.dart';
import 'package:news_weather_hub/presentations/providers/bookmark_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class NewsDetailScreen extends ConsumerStatefulWidget {
  final ArticleModel article;

  const NewsDetailScreen({super.key, required this.article});

  @override
  ConsumerState<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends ConsumerState<NewsDetailScreen> {
  late Future<bool> _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = _checkBookmarkStatus();
  }

  Future<bool> _checkBookmarkStatus() async {
    final repo = ref.read(bookmarkRepositoryProvider);
    return repo.isBookmarked(widget.article.url ?? widget.article.title);
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final bookmarkState = ref.watch(bookmarkProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(article.source?.name ?? 'News'),
        actions: [
          FutureBuilder<bool>(
            future: _isBookmarked,
            builder: (context, snapshot) {
              final isBookmarked = snapshot.data ?? false;
              return IconButton(
                icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                onPressed: () => _toggleBookmark(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareArticle(),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () => _openInBrowser(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  article.urlToImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  article.author ?? 'Unknown Author',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  article.publishedAt != null
                      ? DateFormat('MMM d, yyyy HH:mm').format(
                          DateTime.parse(article.publishedAt!),
                        )
                      : 'Unknown date',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (article.description != null)
              Text(
                article.description!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 12),
            if (article.content != null)
              Text(
                article.content!,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              children: [
                _buildActionChip(
                  icon: Icons.share,
                  label: 'Share',
                  onTap: _shareArticle,
                ),
                _buildActionChip(
                  icon: Icons.open_in_browser,
                  label: 'Open in Browser',
                  onTap: _openInBrowser,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }

  Future<void> _toggleBookmark() async {
    final bookmarkNotifier = ref.read(bookmarkProvider.notifier);
    final article = widget.article;
    final id = article.url ?? article.title;

    if (await _isBookmarked) {
      await bookmarkNotifier.removeBookmark(id);
      setState(() {
        _isBookmarked = Future.value(false);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bookmark removed')),
      );
    } else {
      final bookmark = BookmarkModel(
        id: id,
        title: article.title,
        description: article.description,
        url: article.url ?? '',
        imageUrl: article.urlToImage,
        sourceName: article.source?.name ?? 'Unknown',
        publishedAt: article.publishedAt ?? DateTime.now().toIso8601String(),
        savedAt: DateTime.now(),
      );
      await bookmarkNotifier.addBookmark(bookmark);
      setState(() {
        _isBookmarked = Future.value(true);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bookmark added')),
      );
    }
  }

  Future<void> _shareArticle() async {
    final article = widget.article;
    final text = '${article.title}\n\n${article.description ?? ''}\n\nRead more: ${article.url ?? ''}';
    await Share.share(text);
  }

  Future<void> _openInBrowser() async {
    final url = widget.article.url;
    if (url != null && await canLaunch(url)) {
      await launch(url);
    }
  }
}