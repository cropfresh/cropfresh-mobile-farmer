import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_typography.dart';
import '../../models/rating_models.dart';
import '../../widgets/rating_widgets.dart';
import 'rating_detail_screen.dart';

/// Ratings Summary Screen - Story 3.10 (Task 5)
///
/// Main ratings screen with:
/// - Overall rating badge (AC1, AC2)
/// - Star distribution chart (AC2)
/// - Trend line chart (AC6)
/// - Paginated ratings list (AC3)
/// - Voice announcement support (AC9)
/// - Empty/error states (AC10)
///
/// Follows: Material Design 3, Voice-First UX, 48dp touch targets,
/// responsive layout, smooth animations, WCAG 2.2 AA+.

class RatingsSummaryScreen extends StatefulWidget {
  const RatingsSummaryScreen({super.key});

  @override
  State<RatingsSummaryScreen> createState() => _RatingsSummaryScreenState();
}

class _RatingsSummaryScreenState extends State<RatingsSummaryScreen>
    with SingleTickerProviderStateMixin {
  // State
  RatingSummary? _summary;
  List<RatingListItem> _ratings = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  // TTS for voice-first UX (AC9)
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  // Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Scroll controller for infinite scroll
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupTts();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _setupTts() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreRatings();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Replace with actual API call via RatingService
      await Future.delayed(const Duration(milliseconds: 800));

      final response = RatingsResponse.mock(count: 10);

      setState(() {
        _summary = response.summary;
        _ratings = response.ratings;
        _hasMore = response.hasMore;
        _isLoading = false;
      });

      _fadeController.forward();

      // Auto-announce for voice-first UX (AC9)
      if (_summary != null && _summary!.hasRatings) {
        _speakSummary();
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load ratings. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreRatings() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 400));

      final response = RatingsResponse.mock(count: 5);
      setState(() {
        _ratings.addAll(response.ratings);
        _hasMore = _ratings.length < 30; // Mock limit
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _speakSummary() async {
    if (_summary == null) return;

    setState(() => _isSpeaking = true);
    await _tts.speak(_summary!.ttsAnnouncement);
  }

  void _stopSpeaking() async {
    await _tts.stop();
    setState(() => _isSpeaking = false);
  }

  void _navigateToDetail(RatingListItem rating) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RatingDetailScreen(ratingId: rating.id),
      ),
    ).then((_) {
      // Refresh to update seen status
      _loadData();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Ratings'),
        centerTitle: true,
        actions: [
          // Voice toggle button (AC9)
          IconButton(
            onPressed: _isSpeaking ? _stopSpeaking : _speakSummary,
            icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
            tooltip: _isSpeaking ? 'Stop reading' : 'Read ratings aloud',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppSpacing.md),
            Text('Loading ratings...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_summary == null || !_summary!.hasRatings) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Summary header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    // Overall rating card (AC1, AC2)
                    RatingSummaryCard(
                      summary: _summary!,
                      onVoiceRead: _speakSummary,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Star distribution chart (AC2)
                    StarDistributionChart(
                      breakdown: _summary!.starBreakdown,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Trend chart (AC6)
                    if (_summary!.monthlyTrend.isNotEmpty)
                      RatingTrendChart(
                        trend: _summary!.monthlyTrend,
                      ),

                    const SizedBox(height: AppSpacing.lg),

                    // Section header
                    Row(
                      children: [
                        Text(
                          'Recent Ratings',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (_summary!.hasUnseen)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_summary!.unseenCount} new',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Ratings list (AC3)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= _ratings.length) {
                      // Loading more indicator
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final rating = _ratings[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: RatingListItemCard(
                        rating: rating,
                        onTap: () => _navigateToDetail(rating),
                      ),
                    );
                  },
                  childCount: _ratings.length + (_hasMore ? 1 : 0),
                ),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_outline,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No ratings yet',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Complete your first order to receive ratings from buyers.',
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              _error!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
