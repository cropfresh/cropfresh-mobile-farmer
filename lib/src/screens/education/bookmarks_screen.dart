// Bookmarks Screen - Story 3.11
//
// Screen for viewing bookmarked and recently viewed content.
// AC7: Content Bookmarking & History
// AC9: Offline Support (download indicators)

import 'package:flutter/material.dart';
import '../../models/education_models.dart';
import '../../services/education_service.dart';
import '../education/article_detail_screen.dart';
import '../education/video_player_screen.dart';

class BookmarksScreen extends StatefulWidget {
  final int farmerId;
  final String? authToken;
  
  const BookmarksScreen({
    super.key,
    required this.farmerId,
    this.authToken,
  });

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen>
    with SingleTickerProviderStateMixin {
  late final EducationService _service;
  late final TabController _tabController;
  
  // Bookmarked content state
  List<EducationalContent> _bookmarkedContent = [];
  bool _isLoadingBookmarked = true;
  String? _bookmarkedError;
  
  // Viewed content state
  List<EducationalContent> _viewedContent = [];
  bool _isLoadingViewed = true;
  String? _viewedError;

  @override
  void initState() {
    super.initState();
    _service = EducationService(
      farmerId: widget.farmerId,
      authToken: widget.authToken,
    );
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadBookmarked();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && _isLoadingViewed && _viewedContent.isEmpty) {
      _loadViewed();
    }
  }

  Future<void> _loadBookmarked() async {
    setState(() {
      _isLoadingBookmarked = true;
      _bookmarkedError = null;
    });

    try {
      final response = await _service.getHistory(
        type: HistoryType.bookmarked,
        limit: 50,
      );
      
      setState(() {
        _bookmarkedContent = response.content;
        _isLoadingBookmarked = false;
      });
    } catch (e) {
      setState(() {
        _bookmarkedError = e.toString();
        _isLoadingBookmarked = false;
      });
    }
  }

  Future<void> _loadViewed() async {
    setState(() {
      _isLoadingViewed = true;
      _viewedError = null;
    });

    try {
      final response = await _service.getHistory(
        type: HistoryType.viewed,
        limit: 50,
      );
      
      setState(() {
        _viewedContent = response.content;
        _isLoadingViewed = false;
      });
    } catch (e) {
      setState(() {
        _viewedError = e.toString();
        _isLoadingViewed = false;
      });
    }
  }

  void _onContentTap(EducationalContent content) {
    switch (content.type) {
      case ContentType.video:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              content: content,
              farmerId: widget.farmerId,
              authToken: widget.authToken,
            ),
          ),
        );
        break;
      case ContentType.article:
      case ContentType.infographic:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(
              content: content,
              farmerId: widget.farmerId,
              authToken: widget.authToken,
            ),
          ),
        );
        break;
    }
  }

  Future<void> _removeBookmark(EducationalContent content) async {
    // Optimistic removal
    setState(() {
      _bookmarkedContent.removeWhere((c) => c.id == content.id);
    });
    
    try {
      await _service.toggleBookmark(content.id, false);
    } catch (e) {
      // Revert on failure
      await _loadBookmarked();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove bookmark')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Saved'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Bookmarked'),
            Tab(text: 'Recently Viewed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Bookmarked tab
          _buildBookmarkedTab(theme),
          // Recently viewed tab
          _buildViewedTab(theme),
        ],
      ),
    );
  }

  Widget _buildBookmarkedTab(ThemeData theme) {
    if (_isLoadingBookmarked) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bookmarkedError != null) {
      return _buildErrorState(theme, _bookmarkedError!, _loadBookmarked);
    }

    if (_bookmarkedContent.isEmpty) {
      return _buildEmptyState(
        theme,
        Icons.bookmark_border,
        'No bookmarks yet',
        'Bookmark content to access it offline',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookmarked,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookmarkedContent.length,
        itemBuilder: (context, index) {
          final content = _bookmarkedContent[index];
          return _BookmarkListItem(
            content: content,
            onTap: () => _onContentTap(content),
            onRemove: () => _removeBookmark(content),
          );
        },
      ),
    );
  }

  Widget _buildViewedTab(ThemeData theme) {
    if (_isLoadingViewed) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_viewedError != null) {
      return _buildErrorState(theme, _viewedError!, _loadViewed);
    }

    if (_viewedContent.isEmpty) {
      return _buildEmptyState(
        theme,
        Icons.history,
        'No history yet',
        'Content you view will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadViewed,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _viewedContent.length,
        itemBuilder: (context, index) {
          final content = _viewedContent[index];
          return _ViewHistoryListItem(
            content: content,
            onTap: () => _onContentTap(content),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    ThemeData theme,
    String error,
    VoidCallback onRetry,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text('Failed to load', style: theme.textTheme.titleMedium),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}


/// List item for bookmarked content with remove option
class _BookmarkListItem extends StatelessWidget {
  final EducationalContent content;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  
  const _BookmarkListItem({
    required this.content,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 60,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        content.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.image),
                        ),
                      ),
                      // Download indicator (AC9)
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.download_done,
                            size: 12,
                            color: Colors.white,
                            semanticLabel: 'Available offline',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildTypeBadge(theme),
                        const SizedBox(width: 8),
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
              
              // Remove button (48dp touch target)
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  icon: const Icon(Icons.bookmark_remove),
                  onPressed: onRemove,
                  tooltip: 'Remove bookmark',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(ThemeData theme) {
    final (icon, label) = switch (content.type) {
      ContentType.video => (Icons.play_arrow, 'Video'),
      ContentType.article => (Icons.article, 'Article'),
      ContentType.infographic => (Icons.image, 'Infographic'),
    };
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}


/// List item for view history with progress indicator
class _ViewHistoryListItem extends StatelessWidget {
  final EducationalContent content;
  final VoidCallback onTap;
  
  const _ViewHistoryListItem({
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail with progress
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 60,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        content.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.image),
                        ),
                      ),
                      // Progress bar
                      if (content.viewProgress > 0)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: LinearProgressIndicator(
                            value: content.viewProgress / 100,
                            backgroundColor: Colors.black38,
                            valueColor: AlwaysStoppedAnimation(
                              theme.colorScheme.primary,
                            ),
                            minHeight: 4,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
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
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        if (content.viewProgress > 0 && content.viewProgress < 100)
                          Text(
                            '${content.viewProgress}% complete',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          )
                        else if (content.viewProgress >= 100)
                          Text(
                            'Completed',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.tertiary,
                            ),
                          )
                        else
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
              
              // Arrow indicator
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
