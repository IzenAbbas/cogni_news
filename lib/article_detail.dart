import 'package:cogni_news/colors.dart';
import 'package:cogni_news/news.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Strips HTML tags and removes the NewsAPI truncation marker [+N chars].
String _cleanContent(String raw) {
  // Remove HTML tags
  String cleaned = raw.replaceAll(RegExp(r'<[^>]*>'), ' ');
  // Remove the [+NNN chars] truncation marker
  cleaned = cleaned.replaceAll(RegExp(r'\[\+\d+ chars\]'), '');
  // Collapse multiple whitespace / newlines into a single space
  cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
  return cleaned;
}

class ArticleDetail extends StatelessWidget {
  final Article article;

  const ArticleDetail({super.key, required this.article});

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Container(
          decoration: BoxDecoration(
            border: BoxBorder.all(width: 1, color: primary),
            borderRadius: BorderRadius.circular(12.0),
            color: const Color.fromARGB(67, 211, 70, 27),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Text(
              'CogniNews',
              style: TextStyle(
                color: primary,
                fontFamily: 'Georgia',
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          // Article image
          if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
            Image.network(
              article.urlToImage!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                height: 260,
                child: const Center(
                  child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                ),
              ),
              height: 260,
              width: double.infinity,
            )
          else
            Container(
              color: Colors.grey[300],
              height: 260,
              width: double.infinity,
              child: Center(
                child: Icon(Icons.article, size: 64, color: Colors.grey[500]),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source badge & date
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        article.source.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (article.publishedAt != null)
                      Text(
                        _formatDate(article.publishedAt),
                        style: TextStyle(fontSize: 13, color: secondaryText),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  article.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Author
                if (article.author != null && article.author!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: primary.withValues(alpha: 0.15),
                          child: Icon(Icons.person, size: 16, color: primary),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            article.author!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: secondaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                Divider(color: Colors.grey[300]),
                const SizedBox(height: 12),

                // Description
                if (article.description != null &&
                    article.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      article.description!,
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryText,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),

                // Content
                if (article.content != null && article.content!.isNotEmpty)
                  Text(
                    _cleanContent(article.content!),
                    style: TextStyle(
                      fontSize: 15,
                      color: primaryText,
                      height: 1.6,
                    ),
                  ),

                const SizedBox(height: 24),

                // Read full article button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(article.url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Read Full Article'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
