import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  String newsText = 'Loading...';
  List<Map<String, dynamic>> articles = [];

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    final url =
        'https://newsapi.org/v2/everything?q=apple&from=2026-03-12&to=2026-03-12&sortBy=popularity&apiKey=e274aa8899864d818faae39afb7866f2';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['articles'] != null) {
        List<Map<String, dynamic>> fetchedArticles = [];
        for (var article in data['articles']) {
          print('Title: \u001b[1m${article['title']}\u001b[0m');
          print('Description: ${article['description']}');
          print('URL: ${article['url']}');
          print('---');
          fetchedArticles.add({
            'title': article['title'],
            'description': article['description'],
            'url': article['url'],
          });
        }
        setState(() {
          articles = fetchedArticles;
          newsText = '';
        });
      } else {
        setState(() {
          newsText = 'No articles found';
        });
      }
    } else {
      setState(() {
        newsText = 'Failed to load news';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(newsText),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: _buildArticleItem(article),
        );
      },
    );
  }

  Widget _buildArticleItem(Map<String, dynamic> article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          article['title'] ?? 'No Title',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(article['description'] ?? 'No Description'),
        const SizedBox(height: 8),
        if (article['url'] != null)
          SelectableText(
            article['url'],
            style: const TextStyle(color: Colors.blue),
          ),
      ],
    );
  }
}
