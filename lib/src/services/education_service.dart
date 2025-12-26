/// Education Service - Story 3.11
///
/// API service for farmer educational content.
/// Handles REST calls to Gateway education endpoints.
/// Follows patterns from rating_service.dart.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/education_models.dart';

class EducationService {
  final String baseUrl;
  final String? authToken;
  final int farmerId;

  EducationService({
    this.baseUrl = 'http://localhost:3000/v1',
    this.authToken,
    required this.farmerId,
  });

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
        'x-farmer-id': farmerId.toString(),
      };

  /// Get educational content list with recommendations (AC1-2, AC6)
  Future<ContentListResponse> getContent({
    int page = 1,
    int limit = 10,
    String? category,
    String? cropType,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (category != null) 'category': category,
        if (cropType != null) 'cropType': cropType,
      };

      final uri = Uri.parse('$baseUrl/farmers/education/content')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ContentListResponse.fromJson(json);
      } else {
        throw EducationServiceException(
          'Failed to fetch content: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is EducationServiceException) rethrow;
      // Return mock data for development
      return ContentListResponse.mock(count: limit);
    }
  }

  /// Get content details (AC3-4)
  Future<ContentDetailsResponse> getDetails(String contentId) async {
    try {
      final uri = Uri.parse('$baseUrl/farmers/education/content/$contentId');

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ContentDetailsResponse.fromJson(json);
      } else if (response.statusCode == 404) {
        throw EducationServiceException(
          'Content not found',
          response.statusCode,
        );
      } else {
        throw EducationServiceException(
          'Failed to fetch content details: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is EducationServiceException) rethrow;
      // Return mock data for development
      return ContentDetailsResponse(
        content: EducationalContent.mock(),
        relatedContent: List.generate(3, (i) => EducationalContent.mock(index: i + 10)),
      );
    }
  }

  /// Track view progress (AC3, AC7)
  Future<bool> trackView(String contentId, int progressPercent) async {
    try {
      final uri = Uri.parse('$baseUrl/farmers/education/content/$contentId/view');

      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode({'progressPercent': progressPercent}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['success'] == true;
      } else {
        throw EducationServiceException(
          'Failed to track view: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is EducationServiceException) rethrow;
      // Return success for development
      return true;
    }
  }

  /// Toggle bookmark (AC7)
  Future<bool> toggleBookmark(String contentId, bool bookmarked) async {
    try {
      final uri = Uri.parse('$baseUrl/farmers/education/content/$contentId/bookmark');

      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode({'bookmarked': bookmarked}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['bookmarked'] == true;
      } else {
        throw EducationServiceException(
          'Failed to toggle bookmark: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is EducationServiceException) rethrow;
      // Return expected state for development
      return bookmarked;
    }
  }

  /// Get farmer's content history (AC7)
  Future<ContentHistoryResponse> getHistory({
    HistoryType type = HistoryType.viewed,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'type': type == HistoryType.bookmarked ? 'bookmarked' : 'viewed',
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$baseUrl/farmers/education/history')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ContentHistoryResponse.fromJson(json);
      } else {
        throw EducationServiceException(
          'Failed to fetch history: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is EducationServiceException) rethrow;
      // Return mock data for development
      return ContentHistoryResponse(
        content: List.generate(5, (i) => EducationalContent.mock(index: i)),
        pagination: ContentPagination(page: page, limit: limit, total: 5, hasMore: false),
      );
    }
  }
}

class EducationServiceException implements Exception {
  final String message;
  final int statusCode;

  EducationServiceException(this.message, this.statusCode);

  @override
  String toString() => 'EducationServiceException: $message (status: $statusCode)';
}
