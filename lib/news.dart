import 'package:cogni_news/article_detail.dart';
import 'package:cogni_news/colors.dart';
import 'package:flutter/material.dart';
import "dart:convert";
import "package:http/http.dart" as http;

class NewsResponse {
  final String status;
  final int totalResults;
  final List<Article> articles;

  NewsResponse({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      status: json['status'] as String? ?? '',
      totalResults: json['totalResults'] as int? ?? 0,
      articles:
          (json['articles'] as List<dynamic>?)
              ?.map((e) => Article.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'totalResults': totalResults,
      'articles': articles.map((e) => e.toJson()).toList(),
    };
  }
}

class Article {
  final Source source;
  final String? author;
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final DateTime? publishedAt;
  final String? content;

  Article({
    required this.source,
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      source: Source.fromJson(json['source'] as Map<String, dynamic>? ?? {}),
      author: json['author'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      url: json['url'] as String? ?? '',
      urlToImage: json['urlToImage'] as String?,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
      content: json['content'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source.toJson(),
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt?.toIso8601String(),
      'content': content,
    };
  }
}

class Source {
  final String? id;
  final String name;

  Source({this.id, required this.name});

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  NewsResponse? _newsData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    final newsApiUrl = Uri.parse(
      'https://newsapi.org/v2/everything?q=apple&from=2026-03-23&to=2026-03-23&sortBy=popularity&apiKey=e274aa8899864d818faae39afb7866f2',
    );
    final firebaseDbUrl = Uri.parse(
      'https://cogninews-3f6c1-default-rtdb.firebaseio.com/articles.json',
    );

    try {
      final response = await http.get(newsApiUrl);
      if (response.statusCode == 200) {
        // Save it into Firebase Realtime Database
        await http.put(firebaseDbUrl, body: response.body);

        final data = json.decode(response.body);
        setState(() {
          _newsData = NewsResponse.fromJson(data);
          _isLoading = false;
        });
      } else if (response.statusCode == 426) {
        // Returning 426 means it is running on deployed website, fetch from Firebase
        final firebaseResponse = await http.get(firebaseDbUrl);
        if (firebaseResponse.statusCode == 200) {
          final data = json.decode(firebaseResponse.body);
          setState(() {
            _newsData = NewsResponse.fromJson(data);
            _isLoading = false;
          });
        } else {
          setState(() {
            _error =
                'Failed to load news from Firebase (status ${firebaseResponse.statusCode})';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load news (status ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      // In case of any CORS or other errors that might mimic the deployed behavior
      try {
        final firebaseResponse = await http.get(firebaseDbUrl);
        if (firebaseResponse.statusCode == 200) {
          final data = json.decode(firebaseResponse.body);
          setState(() {
            _newsData = NewsResponse.fromJson(data);
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'Something went wrong. Please try again.';
            _isLoading = false;
          });
        }
      } catch (err) {
        setState(() {
          _error = 'Something went wrong. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  String _timeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: secondary),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: secondaryText),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  fetchNews();
                },
                style: ElevatedButton.styleFrom(backgroundColor: primary),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final articles = _newsData!.articles;

    if (articles.isEmpty) {
      return Center(
        child: Text(
          'No articles found.',
          style: TextStyle(fontSize: 16, color: secondaryText),
        ),
      );
    }

    return RefreshIndicator(
      color: primary,
      onRefresh: () async {
        setState(() {
          _isLoading = true;
          _error = null;
        });
        await fetchNews();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return _buildArticleCard(article);
        },
      ),
    );
  }

  Widget _buildArticleCard(Article article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleDetail(article: article),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  article.urlToImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          article.source.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _timeAgo(article.publishedAt),
                        style: TextStyle(fontSize: 12, color: secondaryText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                      height: 1.3,
                    ),
                  ),

                  if (article.description != null &&
                      article.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      article.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryText,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
