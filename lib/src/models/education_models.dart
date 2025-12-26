/// Education Models - Story 3.11
/// 
/// Data models for educational content, following patterns from rating_models.dart.

import 'dart:convert';

/// Content type enum
enum ContentType { video, article, infographic }

/// Content category enum
enum ContentCategory {
  harvest,
  storage,
  photography,
  handling,
  packaging,
  general,
}

/// Educational content item
class EducationalContent {
  final String id;
  final ContentType type;
  final String title;
  final Map<String, String>? titleRegional;
  final String? description;
  final String thumbnailUrl;
  final String contentUrl;
  final int? durationSeconds;
  final int? readTimeMinutes;
  final String language;
  final List<String> categories;
  final List<String> cropTypes;
  final bool isFeatured;
  final bool isNew;
  final bool isBookmarked;
  final int viewProgress;
  final DateTime? createdAt;

  EducationalContent({
    required this.id,
    required this.type,
    required this.title,
    this.titleRegional,
    this.description,
    required this.thumbnailUrl,
    required this.contentUrl,
    this.durationSeconds,
    this.readTimeMinutes,
    required this.language,
    required this.categories,
    required this.cropTypes,
    this.isFeatured = false,
    this.isNew = false,
    this.isBookmarked = false,
    this.viewProgress = 0,
    this.createdAt,
  });

  /// Get localized title based on language code
  String getLocalizedTitle(String languageCode) {
    if (titleRegional != null && titleRegional!.containsKey(languageCode)) {
      return titleRegional![languageCode]!;
    }
    return title;
  }

  /// Get duration as formatted string
  String get formattedDuration {
    if (durationSeconds == null) return '';
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds > 0 ? '${seconds}s' : ''}';
    }
    return '${seconds}s';
  }

  /// Get read time as formatted string
  String get formattedReadTime {
    if (readTimeMinutes == null) return '';
    return '$readTimeMinutes min read';
  }

  factory EducationalContent.fromJson(Map<String, dynamic> json) {
    return EducationalContent(
      id: json['id'] as String,
      type: _parseContentType(json['type'] as String),
      title: json['title'] as String,
      titleRegional: json['titleRegional'] != null
          ? Map<String, String>.from(json['titleRegional'] as Map)
          : null,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String,
      contentUrl: json['contentUrl'] as String,
      durationSeconds: json['durationSeconds'] as int?,
      readTimeMinutes: json['readTimeMinutes'] as int?,
      language: json['language'] as String? ?? 'en',
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      cropTypes: (json['cropTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isFeatured: json['isFeatured'] as bool? ?? false,
      isNew: json['isNew'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      viewProgress: json['viewProgress'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name.toUpperCase(),
      'title': title,
      'titleRegional': titleRegional,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'contentUrl': contentUrl,
      'durationSeconds': durationSeconds,
      'readTimeMinutes': readTimeMinutes,
      'language': language,
      'categories': categories,
      'cropTypes': cropTypes,
      'isFeatured': isFeatured,
      'isNew': isNew,
      'isBookmarked': isBookmarked,
      'viewProgress': viewProgress,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  static ContentType _parseContentType(String type) {
    switch (type.toUpperCase()) {
      case 'VIDEO':
        return ContentType.video;
      case 'ARTICLE':
        return ContentType.article;
      case 'INFOGRAPHIC':
        return ContentType.infographic;
      default:
        return ContentType.article;
    }
  }

  /// Create mock content for development
  static EducationalContent mock({int index = 0}) {
    final types = [ContentType.video, ContentType.article, ContentType.infographic];
    final categories = ['HARVEST', 'STORAGE', 'HANDLING', 'PHOTOGRAPHY'];
    
    return EducationalContent(
      id: 'mock-content-$index',
      type: types[index % 3],
      title: 'Educational Content ${index + 1}',
      titleRegional: {'kn': 'ಶೈಕ್ಷಣಿಕ ವಿಷಯ ${index + 1}'},
      description: 'Learn about farming best practices for better quality produce.',
      thumbnailUrl: 'https://picsum.photos/400/300?random=$index',
      contentUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      durationSeconds: (index + 1) * 60,
      language: 'en',
      categories: [categories[index % 4]],
      cropTypes: ['TOMATO', 'ONION'],
      isFeatured: index < 3,
      isNew: index < 2,
      isBookmarked: index % 2 == 0,
      viewProgress: index * 20 % 100,
      createdAt: DateTime.now().subtract(Duration(days: index)),
    );
  }
}

/// Content recommendation section
class ContentRecommendation {
  final String section;
  final String reason;
  final List<EducationalContent> content;

  ContentRecommendation({
    required this.section,
    required this.reason,
    required this.content,
  });

  factory ContentRecommendation.fromJson(Map<String, dynamic> json) {
    return ContentRecommendation(
      section: json['section'] as String,
      reason: json['reason'] as String,
      content: (json['content'] as List<dynamic>)
          .map((e) => EducationalContent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Pagination info
class ContentPagination {
  final int page;
  final int limit;
  final int total;
  final bool hasMore;

  ContentPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });

  factory ContentPagination.fromJson(Map<String, dynamic> json) {
    return ContentPagination(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      hasMore: json['hasMore'] as bool,
    );
  }
}

/// Response from GET /education/content
class ContentListResponse {
  final List<EducationalContent> content;
  final ContentPagination pagination;
  final List<ContentRecommendation> recommendations;
  final int unseenCount;

  ContentListResponse({
    required this.content,
    required this.pagination,
    required this.recommendations,
    required this.unseenCount,
  });

  factory ContentListResponse.fromJson(Map<String, dynamic> json) {
    return ContentListResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => EducationalContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: ContentPagination.fromJson(json['pagination'] as Map<String, dynamic>),
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => ContentRecommendation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      unseenCount: json['unseenCount'] as int? ?? 0,
    );
  }

  /// Create mock response for development
  static ContentListResponse mock({int count = 10}) {
    return ContentListResponse(
      content: List.generate(count, (i) => EducationalContent.mock(index: i)),
      pagination: ContentPagination(
        page: 1,
        limit: count,
        total: count + 5,
        hasMore: true,
      ),
      recommendations: [
        ContentRecommendation(
          section: 'Improve Your Score',
          reason: 'Based on your recent feedback',
          content: List.generate(3, (i) => EducationalContent.mock(index: i)),
        ),
      ],
      unseenCount: 5,
    );
  }
}

/// Response from GET /education/content/:id
class ContentDetailsResponse {
  final EducationalContent content;
  final List<EducationalContent> relatedContent;

  ContentDetailsResponse({
    required this.content,
    required this.relatedContent,
  });

  factory ContentDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ContentDetailsResponse(
      content: EducationalContent.fromJson(json),
      relatedContent: (json['relatedContent'] as List<dynamic>?)
              ?.map((e) => EducationalContent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// History type enum
enum HistoryType { viewed, bookmarked }

/// Response from GET /education/history
class ContentHistoryResponse {
  final List<EducationalContent> content;
  final ContentPagination pagination;

  ContentHistoryResponse({
    required this.content,
    required this.pagination,
  });

  factory ContentHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ContentHistoryResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => EducationalContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: ContentPagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }
}
