import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_typography.dart';
import '../../models/rating_models.dart';
import '../../widgets/rating_widgets.dart';

/// Rating Detail Screen - Story 3.10 (Task 6)
///
/// Full rating details with:
/// - Rating info and buyer comment (AC4)
/// - Quality issues with icons (AC4)
/// - Improvement recommendations (AC5)
/// - Tutorial links (AC5)
/// - Photo comparison (AC4, optional)
/// - Voice announcement (AC9)
///
/// Follows: Material Design 3, Voice-First UX, 48dp touch targets,
/// WCAG 2.2 AA+ accessibility.

class RatingDetailScreen extends StatefulWidget {
  final String ratingId;

  const RatingDetailScreen({
    super.key,
    required this.ratingId,
  });

  @override
  State<RatingDetailScreen> createState() => _RatingDetailScreenState();
}

class _RatingDetailScreenState extends State<RatingDetailScreen> {
  RatingDetails? _details;
  bool _isLoading = true;
  String? _error;

  // TTS for voice-first UX (AC9)
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _setupTts();
    _loadDetails();
  }

  Future<void> _setupTts() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.5);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Replace with actual API call + mark as seen
      await Future.delayed(const Duration(milliseconds: 600));

      setState(() {
        _details = RatingDetails.mock();
        _isLoading = false;
      });

      // Auto-read details for voice-first UX (AC9)
      _speakDetails();
    } catch (e) {
      setState(() {
        _error = 'Failed to load rating details.';
        _isLoading = false;
      });
    }
  }

  Future<void> _speakDetails() async {
    if (_details == null) return;

    setState(() => _isSpeaking = true);
    await _tts.speak(_details!.ttsAnnouncement);
  }

  void _openTutorial(String tutorialId) {
    // TODO: Navigate to tutorial screen (Story 3.11)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening tutorial: $tutorialId'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rating Details'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isSpeaking
                ? () {
                    _tts.stop();
                    setState(() => _isSpeaking = false);
                  }
                : _speakDetails,
            icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
            tooltip: _isSpeaking ? 'Stop reading' : 'Read aloud',
          ),
        ],
      ),
      body: _buildBody(colorScheme),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _details == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(_error ?? 'Something went wrong'),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _loadDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating header card
          _buildRatingHeader(colorScheme),

          const SizedBox(height: AppSpacing.lg),

          // Buyer comment (AC4)
          if (_details!.comment != null && _details!.comment!.isNotEmpty)
            _buildCommentCard(colorScheme),

          if (_details!.comment != null && _details!.comment!.isNotEmpty)
            const SizedBox(height: AppSpacing.lg),

          // Quality issues (AC4, AC5)
          if (_details!.hasIssues) ...[
            Text(
              'Quality Issues',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...List.generate(_details!.qualityIssues.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: QualityIssueCard(
                  issue: _details!.qualityIssues[index],
                ),
              );
            }),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Recommendations (AC5)
          if (_details!.hasRecommendations) ...[
            Text(
              'Improvement Suggestions',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...List.generate(_details!.recommendations.length, (index) {
              final rec = _details!.recommendations[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: RecommendationCard(
                  recommendation: rec,
                  onTutorialTap: rec.hasTutorial
                      ? () => _openTutorial(rec.tutorialId!)
                      : null,
                ),
              );
            }),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Encouraging message (AC5)
          if (_details!.rating < 4)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Each order helps you improve! Keep learning and growing.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Ratings Impact Info (AC7)
          const SizedBox(height: AppSpacing.lg),
          const RatingsImpactCard(),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildRatingHeader(ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            // Crop icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  _details!.cropIcon,
                  style: const TextStyle(fontSize: 32),
                  semanticsLabel: _details!.cropType,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_details!.formattedQuantity} ${_details!.cropType}',
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _details!.formattedDate,
                    style: AppTypography.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Star rating - wrap in Flexible to prevent overflow
            Flexible(
              flex: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < _details!.rating
                            ? Icons.star
                            : Icons.star_outline,
                        color: index < _details!.rating
                            ? AppColors.starFilled
                            : colorScheme.outline,
                        size: 20, // Reduced from 24
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_details!.rating}/5',
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCard(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.comment_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Buyer Comment',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _details!.comment!,
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
