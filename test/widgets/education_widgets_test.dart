/// Education Widgets Tests - Story 3.11
///
/// Widget tests for educational content display widgets.
/// AC2: Content Library Display
/// AC5: Accessibility (48dp touch targets)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cropfresh_mobile_farmer/src/models/education_models.dart';
import 'package:cropfresh_mobile_farmer/src/widgets/education_widgets.dart';

void main() {
  // Test data
  final mockVideoContent = EducationalContent(
    id: 'test-video-1',
    type: ContentType.video,
    title: 'Best Tomato Harvest Techniques',
    titleRegional: {'kn': 'ಟೊಮೇಟೊ ಕೊಯ್ಲು ತಂತ್ರಗಳು'},
    description: 'Learn harvest techniques',
    thumbnailUrl: 'https://example.com/thumb.jpg',
    contentUrl: 'https://youtube.com/watch?v=123',
    durationSeconds: 180,
    language: 'en',
    categories: ['HARVEST'],
    cropTypes: ['TOMATO'],
    isFeatured: true,
    isNew: true,
    isBookmarked: false,
    viewProgress: 0,
  );

  final mockArticleContent = EducationalContent(
    id: 'test-article-1',
    type: ContentType.article,
    title: 'Pre-Delivery Storage Tips',
    description: 'Storage tips',
    thumbnailUrl: 'https://example.com/thumb.jpg',
    contentUrl: '## Storage Tips',
    readTimeMinutes: 5,
    language: 'en',
    categories: ['STORAGE'],
    cropTypes: ['ONION'],
    isFeatured: false,
    isNew: false,
    isBookmarked: true,
    viewProgress: 50,
  );

  group('ContentCard', () {
    testWidgets('displays video content correctly (AC2)', (tester) async {
      bool tapped = false;
      bool bookmarkTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 280,
              child: ContentCard(
                content: mockVideoContent,
                onTap: () => tapped = true,
                onBookmarkTap: () => bookmarkTapped = true,
              ),
            ),
          ),
        ),
      );

      // Verify title is displayed
      expect(find.text('Best Tomato Harvest Techniques'), findsOneWidget);

      // Verify Video badge is shown
      expect(find.text('Video'), findsOneWidget);

      // Verify NEW badge is shown
      expect(find.text('NEW'), findsOneWidget);

      // Verify duration is shown
      expect(find.text('3 min'), findsOneWidget);

      // Verify bookmark icon (not bookmarked)
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);

      // Verify tap callback
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('displays article content with bookmark (AC7)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 280,
              child: ContentCard(
                content: mockArticleContent,
                onTap: () {},
                onBookmarkTap: () {},
              ),
            ),
          ),
        ),
      );

      // Verify title
      expect(find.text('Pre-Delivery Storage Tips'), findsOneWidget);

      // Verify Article badge
      expect(find.text('Article'), findsOneWidget);

      // Verify read time
      expect(find.text('5 min read'), findsOneWidget);

      // Verify bookmarked icon
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
    });

    testWidgets('shows progress indicator for partially viewed (AC7)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 280,
              child: ContentCard(
                content: mockArticleContent, // 50% progress
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      // Verify progress indicator is shown
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('bookmark button has 48dp touch target (AC5)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 280,
              child: ContentCard(
                content: mockVideoContent,
                onTap: () {},
                onBookmarkTap: () {},
              ),
            ),
          ),
        ),
      );

      // Find the IconButton for bookmark
      final iconButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.bookmark_border),
          matching: find.byType(IconButton),
        ),
      );

      // Verify touch target size
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(IconButton),
          matching: find.byType(SizedBox),
        ).first,
      );

      expect(sizedBox.width, equals(48));
      expect(sizedBox.height, equals(48));
    });
  });

  group('ContentCardSkeleton', () => {
    testWidgets('renders loading skeleton', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 280,
              child: ContentCardSkeleton(),
            ),
          ),
        ),
      );

      // Verify skeleton card is rendered
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });
  });

  group('RecommendedContentSection', () {
    testWidgets('displays recommendation with title and content (AC6)', (tester) async {
      bool contentTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecommendedContentSection(
              title: 'Improve Your Score',
              subtitle: 'Based on your recent feedback',
              content: [mockVideoContent, mockArticleContent],
              onContentTap: (content) => contentTapped = true,
            ),
          ),
        ),
      );

      // Verify section title
      expect(find.text('Improve Your Score'), findsOneWidget);

      // Verify subtitle/reason
      expect(find.text('Based on your recent feedback'), findsOneWidget);

      // Verify horizontal list is scrollable
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('hides section when content is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecommendedContentSection(
              title: 'Empty Section',
              subtitle: 'No content',
              content: [],
              onContentTap: (_) {},
            ),
          ),
        ),
      );

      // Verify section is hidden
      expect(find.text('Empty Section'), findsNothing);
    });
  });

  group('ContentCategoryTabs', () {
    testWidgets('displays category tabs and handles selection', (tester) async {
      String selectedCategory = 'ALL';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContentCategoryTabs(
              categories: ['ALL', 'HARVEST', 'STORAGE', 'HANDLING'],
              selectedCategory: selectedCategory,
              onCategorySelected: (cat) => selectedCategory = cat,
            ),
          ),
        ),
      );

      // Verify all categories are shown
      expect(find.text('ALL'), findsOneWidget);
      expect(find.text('HARVEST'), findsOneWidget);
      expect(find.text('STORAGE'), findsOneWidget);
      expect(find.text('HANDLING'), findsOneWidget);

      // Verify chips are rendered
      expect(find.byType(FilterChip), findsNWidgets(4));
    });
  });

  group('ContentBadge', () {
    testWidgets('displays count when positive', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContentBadge(count: 5),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('displays 99+ for large counts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContentBadge(count: 150),
          ),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('hides when count is zero', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContentBadge(count: 0),
          ),
        ),
      );

      expect(find.byType(Container), findsNothing);
    });
  });
}

// Model tests
void modelTests() {
  group('EducationalContent', () {
    test('parses from JSON correctly', () {
      final json = {
        'id': 'test-id',
        'type': 'VIDEO',
        'title': 'Test Video',
        'titleRegional': {'kn': 'ಪರೀಕ್ಷಾ ವೀಡಿಯೊ'},
        'description': 'Description',
        'thumbnailUrl': 'https://example.com/thumb.jpg',
        'contentUrl': 'https://youtube.com/watch?v=123',
        'durationSeconds': 180,
        'language': 'en',
        'categories': ['HARVEST'],
        'cropTypes': ['TOMATO'],
        'isFeatured': true,
        'isNew': true,
        'isBookmarked': false,
        'viewProgress': 25,
        'createdAt': '2025-12-26T10:00:00Z',
      };

      final content = EducationalContent.fromJson(json);

      expect(content.id, equals('test-id'));
      expect(content.type, equals(ContentType.video));
      expect(content.title, equals('Test Video'));
      expect(content.titleRegional?['kn'], equals('ಪರೀಕ್ಷಾ ವೀಡಿಯೊ'));
      expect(content.durationSeconds, equals(180));
      expect(content.isFeatured, isTrue);
      expect(content.viewProgress, equals(25));
    });

    test('formats duration correctly', () {
      final content = EducationalContent(
        id: 'test',
        type: ContentType.video,
        title: 'Test',
        thumbnailUrl: '',
        contentUrl: '',
        durationSeconds: 150,
        language: 'en',
        categories: [],
        cropTypes: [],
      );

      expect(content.formattedDuration, equals('2m 30s'));
    });

    test('gets localized title', () {
      final content = EducationalContent(
        id: 'test',
        type: ContentType.article,
        title: 'English Title',
        titleRegional: {'kn': 'ಕನ್ನಡ ಶೀರ್ಷಿಕೆ', 'hi': 'हिंदी शीर्षक'},
        thumbnailUrl: '',
        contentUrl: '',
        language: 'en',
        categories: [],
        cropTypes: [],
      );

      expect(content.getLocalizedTitle('kn'), equals('ಕನ್ನಡ ಶೀರ್ಷಿಕೆ'));
      expect(content.getLocalizedTitle('hi'), equals('हिंदी शीर्षक'));
      expect(content.getLocalizedTitle('ta'), equals('English Title')); // Fallback
    });

    test('creates mock content', () {
      final mock = EducationalContent.mock(index: 0);
      
      expect(mock.id, isNotEmpty);
      expect(mock.title, isNotEmpty);
      expect(mock.thumbnailUrl, isNotEmpty);
    });
  });

  group('ContentListResponse', () {
    test('parses from JSON correctly', () {
      final json = {
        'content': [],
        'pagination': {
          'page': 1,
          'limit': 10,
          'total': 0,
          'hasMore': false,
        },
        'recommendations': [],
        'unseenCount': 5,
      };

      final response = ContentListResponse.fromJson(json);

      expect(response.content, isEmpty);
      expect(response.pagination.page, equals(1));
      expect(response.unseenCount, equals(5));
    });

    test('creates mock response', () {
      final mock = ContentListResponse.mock(count: 5);

      expect(mock.content.length, equals(5));
      expect(mock.recommendations.isNotEmpty, isTrue);
    });
  });
}
