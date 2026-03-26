import 'package:cogni_news/colors.dart';
import 'package:cogni_news/news.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Strips HTML tags and removes the NewsAPI truncation marker [+N chars].
String _cleanContent(String raw) {
  String cleaned = raw.replaceAll(RegExp(r'<[^>]*>'), ' ');
  cleaned = cleaned.replaceAll(RegExp(r'\[\+\d+ chars\]'), '');
  cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
  return cleaned;
}

class ArticleDetail extends StatefulWidget {
  final Article article;

  const ArticleDetail({super.key, required this.article});

  @override
  State<ArticleDetail> createState() => _ArticleDetailState();
}

class _ArticleDetailState extends State<ArticleDetail> {
  bool _isSaved = false;
  bool _isLoading = true;

  String get _docId =>
      Uri.encodeComponent(widget.article.url).replaceAll('%', '_');

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_articles')
        .doc(_docId)
        .get();
    if (mounted) {
      setState(() {
        _isSaved = doc.exists;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    final user = FirebaseAuth.instance.currentUser;

    // Not signed in — show snackbar
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in first to save articles.'),
          backgroundColor: primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_articles')
        .doc(_docId);

    if (_isSaved) {
      await ref.delete();
      if (mounted) {
        setState(() => _isSaved = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Article removed from saved.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } else {
      await ref.set(widget.article.toJson());
      if (mounted) {
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Article saved!'),
            backgroundColor: primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

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
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} '
        'at ${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  tooltip: _isSaved ? 'Remove bookmark' : 'Bookmark article',
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      _isSaved ? Icons.bookmark : Icons.bookmark_border,
                      key: ValueKey(_isSaved),
                      color: primary,
                      size: 26,
                    ),
                  ),
                  onPressed: _toggleBookmark,
                ),
        ],
      ),
      body: ListView(
        children: [
          // Article image
          if (widget.article.urlToImage != null &&
              widget.article.urlToImage!.isNotEmpty)
            Image.network(
              widget.article.urlToImage!,
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
                        widget.article.source.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (widget.article.publishedAt != null)
                      Text(
                        _formatDate(widget.article.publishedAt),
                        style: TextStyle(fontSize: 13, color: secondaryText),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  widget.article.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Author
                if (widget.article.author != null &&
                    widget.article.author!.isNotEmpty)
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
                            widget.article.author!,
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
                if (widget.article.description != null &&
                    widget.article.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      widget.article.description!,
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryText,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),

                // Content
                if (widget.article.content != null &&
                    widget.article.content!.isNotEmpty)
                  Text(
                    _cleanContent(widget.article.content!),
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
                      final uri = Uri.parse(widget.article.url);
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
