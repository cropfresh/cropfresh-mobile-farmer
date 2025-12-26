/// Educational Content Screen - Story 3.11
/// 
/// Main screen for browsing educational content.
/// AC1: Access Educational Content Section
/// AC2: Content Library Display
/// AC6: Personalized Recommendations

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../models/education_models.dart';
import '../../services/education_service.dart';
import '../education/article_detail_screen.dart';
import '../education/video_player_screen.dart';
import '../../widgets/education_widgets.dart';

class EducationalContentScreen extends StatefulWidget {
  final int farmerId;
  final String? authToken;
  
  const EducationalContentScreen({
    super.key,
    required this.farmerId,
    this.authToken,
  });

  @override
  State<EducationalContentScreen> createState() => _EducationalContentScreenState();
}

class _EducationalContentScreenState extends State<EducationalContentScreen>
    with SingleTickerProviderStateMixin {
  late final EducationService _service;
  late final TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  // State
  ContentListResponse? _response;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  String _selectedCategory = 'ALL';
  int _currentPage = 1;
  
  // Categories matching backend
  static const List<String> _categories = [
    'ALL',
    'HARVEST',
    'STORAGE',
    'HANDLING',
    'PHOTOGRAPHY',
    'PACKAGING',
  ];
  
  static const List<String> _categoryLabels = [
    'All',
    'Harvest',
    'Storage',
    'Handling',
    'Photography',
    'Packaging',
  ];

  @override
  void initState() {
    super.initState();
    _service = EducationService(
      farmerId: widget.farmerId,
      authToken: widget.authToken,
    );
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);
    _loadContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _selectedCategory = _categories[_tabController.index];
        _currentPage = 1;
        _response = null;
      });
      _loadContent();
    }
  }

  void _onScroll() {
    // Infinite scroll - load more when near bottom
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && (_response?.pagination.hasMore ?? false)) {
        _loadMore();
      }
    }
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _service.getContent(
        page: 1,
        limit: 10,
        category: _selectedCategory == 'ALL' ? null : _selectedCategory,
      );
      
      setState(() {
        _response = response;
        _currentPage = 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    
    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final response = await _service.getContent(
        page: nextPage,
        limit: 10,
        category: _selectedCategory == 'ALL' ? null : _selectedCategory,
      );
      
      setState(() {
        _response = ContentListResponse(
          content: [...?_response?.content, ...response.content],
          pagination: response.pagination,
          recommendations: _response?.recommendations ?? [],
          unseenCount: response.unseenCount,
        );
        _currentPage = nextPage;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _onRefresh() async {
    await _loadContent();
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

  Future<void> _onBookmarkTap(EducationalContent content) async {
    final newStatus = !content.isBookmarked;
    
    // Optimistically update UI
    setState(() {
      final index = _response?.content.indexWhere((c) => c.id == content.id);
      if (index != null && index >= 0) {
        // Create updated content list
        final updatedContent = List<EducationalContent>.from(_response!.content);
        updatedContent[index] = EducationalContent(
          id: content.id,
          type: content.type,
          title: content.title,
          titleRegional: content.titleRegional,
          description: content.description,
          thumbnailUrl: content.thumbnailUrl,
          contentUrl: content.contentUrl,
          durationSeconds: content.durationSeconds,
          readTimeMinutes: content.readTimeMinutes,
          language: content.language,
          categories: content.categories,
          cropTypes: content.cropTypes,
          isFeatured: content.isFeatured,
          isNew: content.isNew,
          isBookmarked: newStatus,
          viewProgress: content.viewProgress,
          createdAt: content.createdAt,
        );
        _response = ContentListResponse(
          content: updatedContent,
          pagination: _response!.pagination,
          recommendations: _response!.recommendations,
          unseenCount: _response!.unseenCount,
        );
      }
    });

    // Call API
    try {
      await _service.toggleBookmark(content.id, newStatus);
    } catch (e) {
      // Revert on failure
      await _loadContent();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update bookmark')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
        actions: [
          // Bookmarks navigation
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            tooltip: 'My Saved',
            onPressed: () {
              // TODO: Navigate to bookmarks screen
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categoryLabels.map((label) => Tab(text: label)).toList(),
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return _buildLoadingSkeleton();
    }

    if (_error != null) {
      return _buildErrorState(theme);
    }

    if (_response == null || _response!.content.isEmpty) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Recommendations section (only on ALL tab)
          if (_selectedCategory == 'ALL' && _response!.recommendations.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildRecommendationsSection(theme),
            ),
          
          // Content grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final content = _response!.content[index];
                  return ContentCard(
                    content: content,
                    onTap: () => _onContentTap(content),
                    onBookmarkTap: () => _onBookmarkTap(content),
                  );
                },
                childCount: _response!.content.length,
              ),
            ),
          ),
          
          // Loading more indicator
          if (_isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final rec in _response!.recommendations)
          RecommendedContentSection(
            title: rec.section,
            subtitle: rec.reason,
            content: rec.content,
            onContentTap: _onContentTap,
          ),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const ContentCardSkeleton(),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No content available',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for farming tips',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
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
          Text(
            'Failed to load content',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _loadContent,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
