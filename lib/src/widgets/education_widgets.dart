/// Education Widgets - Story 3.11
/// 
/// Reusable widgets for educational content display.
/// AC2: Content Library Display
/// AC5: Accessibility (48dp touch targets)
/// AC6: Personalized Recommendations

import 'package:flutter/material.dart';
import '../models/education_models.dart';

/// Content card widget for grid/list display
class ContentCard extends StatelessWidget {
  final EducationalContent content;
  final VoidCallback onTap;
  final VoidCallback? onBookmarkTap;
  
  const ContentCard({
    super.key,
    required this.content,
    required this.onTap,
    this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with badges
            Stack(
              children: [
                // Thumbnail image
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(
                    content.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        _getContentTypeIcon(),
                        size: 32,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                
                // Type badge (Video/Article)
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: _buildTypeBadge(theme),
                ),
                
                // New badge
                if (content.isNew)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'NEW',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onTertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                // Progress indicator for partially viewed
                if (content.viewProgress > 0 && content.viewProgress < 100)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: LinearProgressIndicator(
                      value: content.viewProgress / 100,
                      backgroundColor: Colors.black38,
                      valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                      minHeight: 3,
                    ),
                  ),
              ],
            ),
            
            // Content info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Expanded(
                      child: Text(
                        content.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Duration/Read time and bookmark
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getDurationText(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        // Bookmark button with 48dp touch target
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: IconButton(
                            icon: Icon(
                              content.isBookmarked 
                                  ? Icons.bookmark 
                                  : Icons.bookmark_border,
                              color: content.isBookmarked 
                                  ? theme.colorScheme.primary 
                                  : null,
                            ),
                            onPressed: onBookmarkTap,
                            tooltip: content.isBookmarked 
                                ? 'Remove bookmark' 
                                : 'Add bookmark',
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getContentTypeIcon() {
    switch (content.type) {
      case ContentType.video:
        return Icons.play_circle_outline;
      case ContentType.article:
        return Icons.article_outlined;
      case ContentType.infographic:
        return Icons.image_outlined;
    }
  }

  Widget _buildTypeBadge(ThemeData theme) {
    final (icon, label, color) = switch (content.type) {
      ContentType.video => (Icons.play_arrow, 'Video', theme.colorScheme.error),
      ContentType.article => (Icons.article, 'Article', theme.colorScheme.primary),
      ContentType.infographic => (Icons.image, 'Infographic', theme.colorScheme.secondary),
    };
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getDurationText() {
    switch (content.type) {
      case ContentType.video:
        if (content.durationSeconds != null) {
          final minutes = content.durationSeconds! ~/ 60;
          return '$minutes min';
        }
        return '';
      case ContentType.article:
      case ContentType.infographic:
        if (content.readTimeMinutes != null) {
          return '${content.readTimeMinutes} min read';
        }
        return '';
    }
  }
}


/// Skeleton loading placeholder for content cards
class ContentCardSkeleton extends StatelessWidget {
  const ContentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail placeholder
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Container(
              color: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          
          // Content placeholder
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 80,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 12,
                    width: 60,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/// Horizontal scrolling recommendation section
class RecommendedContentSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<EducationalContent> content;
  final void Function(EducationalContent) onContentTap;
  
  const RecommendedContentSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.onContentTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (content.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        
        // Horizontal list
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: content.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = content[index];
              return _RecommendationCard(
                content: item,
                onTap: () => onContentTap(item),
              );
            },
          ),
        ),
        
        const SizedBox(height: 8),
      ],
    );
  }
}


/// Card for recommendation horizontal list
class _RecommendationCard extends StatelessWidget {
  final EducationalContent content;
  final VoidCallback onTap;
  
  const _RecommendationCard({
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: 160,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      content.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.image),
                      ),
                    ),
                  ),
                  // Play button overlay for videos
                  if (content.type == ContentType.video)
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          content.title,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// Category tabs widget
class ContentCategoryTabs extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  
  const ContentCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: categories.map((category) {
          final isSelected = category == selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => onCategorySelected(category),
              selectedColor: theme.colorScheme.secondaryContainer,
              checkmarkColor: theme.colorScheme.onSecondaryContainer,
              labelStyle: TextStyle(
                color: isSelected 
                    ? theme.colorScheme.onSecondaryContainer 
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}


/// Badge widget for unseen content count
class ContentBadge extends StatelessWidget {
  final int count;
  
  const ContentBadge({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onError,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
