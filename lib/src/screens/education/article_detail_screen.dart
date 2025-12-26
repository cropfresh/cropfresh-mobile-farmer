/// Article Detail Screen - Story 3.11
/// 
/// Display screen for articles and infographics with TTS narration.
/// AC4: Article & Infographic Display
/// AC5: Voice Narration (Accessibility)
/// AC8: Content Sharing

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/education_models.dart';
import '../../services/education_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final EducationalContent content;
  final int farmerId;
  final String? authToken;
  
  const ArticleDetailScreen({
    super.key,
    required this.content,
    required this.farmerId,
    this.authToken,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late final EducationService _service;
  late final FlutterTts _flutterTts;
  
  // TTS state
  bool _isSpeaking = false;
  bool _isPaused = false;
  String _currentLanguage = 'en-US';
  
  // Content state
  bool _isBookmarked = false;
  bool _isLoading = false;
  List<EducationalContent> _relatedContent = [];
  
  // Track reading progress
  final ScrollController _scrollController = ScrollController();
  double _readProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _service = EducationService(
      farmerId: widget.farmerId,
      authToken: widget.authToken,
    );
    _isBookmarked = widget.content.isBookmarked;
    
    _initTts();
    _loadRelatedContent();
    _scrollController.addListener(_trackReadProgress);
    
    // Track view on open
    _trackView();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    
    await _flutterTts.setLanguage(_currentLanguage);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
        _isPaused = false;
      });
    });
    
    _flutterTts.setErrorHandler((error) {
      setState(() {
        _isSpeaking = false;
        _isPaused = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('TTS Error: $error')),
      );
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _scrollController.dispose();
    // Track final progress
    _trackView(force: true);
    super.dispose();
  }

  Future<void> _loadRelatedContent() async {
    try {
      final response = await _service.getDetails(widget.content.id);
      setState(() {
        _relatedContent = response.relatedContent;
      });
    } catch (e) {
      // Silently fail - related content is not critical
    }
  }

  void _trackReadProgress() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      if (maxScroll > 0) {
        final progress = (_scrollController.offset / maxScroll).clamp(0.0, 1.0);
        setState(() => _readProgress = progress);
      }
    }
  }

  Future<void> _trackView({bool force = false}) async {
    final progressPercent = (_readProgress * 100).round();
    try {
      await _service.trackView(widget.content.id, progressPercent);
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _toggleTts() async {
    if (_isSpeaking) {
      if (_isPaused) {
        // Resume
        // Note: FlutterTts doesn't support pause/resume on all platforms
        // Re-speak from beginning for now
        await _speakContent();
      } else {
        // Pause (actually stops)
        await _flutterTts.stop();
        setState(() {
          _isSpeaking = false;
          _isPaused = false;
        });
      }
    } else {
      await _speakContent();
    }
  }

  Future<void> _speakContent() async {
    // Extract text content for TTS
    final textContent = _extractPlainText(widget.content.contentUrl);
    
    setState(() {
      _isSpeaking = true;
      _isPaused = false;
    });
    
    await _flutterTts.speak(textContent);
  }

  String _extractPlainText(String markdown) {
    // Simple markdown to plain text conversion
    // Remove headers, links, emphasis, etc.
    String text = markdown;
    
    // Remove headers
    text = text.replaceAll(RegExp(r'^#+\s*', multiLine: true), '');
    
    // Remove bold/italic
    text = text.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
    text = text.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');
    
    // Remove links (keep text)
    text = text.replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1');
    
    // Remove list markers
    text = text.replaceAll(RegExp(r'^[-*]\s+', multiLine: true), '');
    text = text.replaceAll(RegExp(r'^\d+\.\s+', multiLine: true), '');
    
    // Clean up extra whitespace
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    
    return text.trim();
  }

  Future<void> _changeLanguage() async {
    final languages = [
      ('English', 'en-US'),
      ('Hindi', 'hi-IN'),
      ('Kannada', 'kn-IN'),
      ('Tamil', 'ta-IN'),
      ('Telugu', 'te-IN'),
    ];
    
    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Language',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...languages.map((lang) => ListTile(
              title: Text(lang.$1),
              trailing: _currentLanguage == lang.$2
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () async {
                await _flutterTts.setLanguage(lang.$2);
                setState(() => _currentLanguage = lang.$2);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleBookmark() async {
    final newStatus = !_isBookmarked;
    
    // Optimistic update
    setState(() => _isBookmarked = newStatus);
    
    try {
      await _service.toggleBookmark(widget.content.id, newStatus);
    } catch (e) {
      // Revert on failure
      setState(() => _isBookmarked = !newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update bookmark')),
        );
      }
    }
  }

  Future<void> _shareContent() async {
    final deepLink = 'cropfresh://learn/${widget.content.id}';
    final shareText = '''Check out this farming tip from CropFresh!

${widget.content.title}

$deepLink''';
    
    await Share.share(
      shareText,
      subject: widget.content.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInfographic = widget.content.type == ContentType.infographic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.content.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Bookmark button
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? theme.colorScheme.primary : null,
            ),
            onPressed: _toggleBookmark,
            tooltip: _isBookmarked ? 'Remove bookmark' : 'Add bookmark',
          ),
          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareContent,
            tooltip: 'Share via WhatsApp',
          ),
        ],
      ),
      body: isInfographic 
          ? _buildInfographicView(theme)
          : _buildArticleView(theme),
      floatingActionButton: !isInfographic
          ? FloatingActionButton.extended(
              onPressed: _toggleTts,
              icon: Icon(_isSpeaking && !_isPaused ? Icons.stop : Icons.volume_up),
              label: Text(_isSpeaking && !_isPaused ? 'Stop' : 'Read to Me'),
              tooltip: 'Read article aloud',
            )
          : null,
    );
  }

  Widget _buildArticleView(ThemeData theme) {
    return Column(
      children: [
        // Reading progress indicator
        LinearProgressIndicator(
          value: _readProgress,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
          minHeight: 3,
        ),
        
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                if (widget.content.thumbnailUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.content.thumbnailUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        height: 200,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Title
                Text(
                  widget.content.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Meta info
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.content.formattedReadTime,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Language selector for TTS
                    TextButton.icon(
                      onPressed: _changeLanguage,
                      icon: const Icon(Icons.language, size: 16),
                      label: Text(_currentLanguage.split('-').first.toUpperCase()),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(48, 32),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Article content (markdown)
                _buildMarkdownContent(theme, widget.content.contentUrl),
                
                const SizedBox(height: 32),
                
                // Related content
                if (_relatedContent.isNotEmpty) ...[
                  Text(
                    'Related Content',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _relatedContent.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final content = _relatedContent[index];
                        return _buildRelatedContentCard(theme, content);
                      },
                    ),
                  ),
                ],
                
                const SizedBox(height: 80), // Space for FAB
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfographicView(ThemeData theme) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Zoomable infographic image
        InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            widget.content.contentUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load infographic',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Share button at bottom
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: SafeArea(
            child: FilledButton.icon(
              onPressed: _shareContent,
              icon: const Icon(Icons.share),
              label: const Text('Share via WhatsApp'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMarkdownContent(ThemeData theme, String markdown) {
    // Simple markdown renderer (in production, use flutter_markdown package)
    final lines = markdown.split('\n');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        // Headers
        if (line.startsWith('## ')) {
          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              line.substring(3),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        if (line.startsWith('### ')) {
          return Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              line.substring(4),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        
        // List items
        if (line.startsWith('- ') || line.startsWith('* ')) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: theme.textTheme.bodyLarge),
                Expanded(
                  child: Text(
                    _formatInlineText(line.substring(2)),
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          );
        }
        
        // Numbered list
        final numberedMatch = RegExp(r'^(\d+)\.\s+(.+)$').firstMatch(line);
        if (numberedMatch != null) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '${numberedMatch.group(1)}.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _formatInlineText(numberedMatch.group(2)!),
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          );
        }
        
        // Empty line
        if (line.trim().isEmpty) {
          return const SizedBox(height: 8);
        }
        
        // Regular paragraph
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _formatInlineText(line),
            style: theme.textTheme.bodyLarge,
          ),
        );
      }).toList(),
    );
  }

  String _formatInlineText(String text) {
    // Remove bold markers but keep text
    text = text.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
    text = text.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');
    return text;
  }

  Widget _buildRelatedContentCard(ThemeData theme, EducationalContent content) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(
              content: content,
              farmerId: widget.farmerId,
              authToken: widget.authToken,
            ),
          ),
        );
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surfaceContainerLow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                content.thumbnailUrl,
                height: 80,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  height: 80,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.image),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        content.type == ContentType.video 
                            ? Icons.play_circle_outline 
                            : Icons.article_outlined,
                        size: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        content.type == ContentType.video 
                            ? content.formattedDuration 
                            : content.formattedReadTime,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
