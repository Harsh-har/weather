import 'package:flutter/material.dart';
import 'package:news_weather_hub/data/models/news/news_model.dart';
import 'package:intl/intl.dart';
import 'package:news_weather_hub/presentations/screens/dashboard/widgets/news_card.dart';
import 'package:news_weather_hub/presentations/screens/news_detail/news_details_screen.dart';

class NewsSection extends StatefulWidget {
  final List<ArticleModel> articles;
  final bool isCached;
  final DateTime? cachedTime;
  final VoidCallback onLoadMore;

  const NewsSection({
    super.key,
    required this.articles,
    this.isCached = false,
    this.cachedTime,
    required this.onLoadMore,
  });

  @override
  State<NewsSection> createState() => _NewsSectionState();
}

class _NewsSectionState extends State<NewsSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.newspaper, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Latest News',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.isCached) ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Offline ${DateFormat('HH:mm').format(widget.cachedTime ?? DateTime.now())}',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          controller: _scrollController,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.articles.length + 1, // +1 for loading indicator
          itemBuilder: (context, index) {
            if (index == widget.articles.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final article = widget.articles[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsDetailScreen(article: article),
                  ),
                );
              },
              child: NewsCard(article: article),
            );
          },
        ),
      ],
    );
  }
}