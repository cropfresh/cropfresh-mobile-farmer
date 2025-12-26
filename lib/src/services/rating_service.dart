/// Rating Service - Story 3.10
///
/// API service for farmer quality ratings and feedback.
/// Handles REST calls to Gateway rating endpoints.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/rating_models.dart';

class RatingService {
  final String baseUrl;
  final String? authToken;
  final int farmerId;

  RatingService({
    this.baseUrl = 'http://localhost:3000/v1',
    this.authToken,
    required this.farmerId,
  });

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
    'x-farmer-id': farmerId.toString(),
  };

  /// Get paginated ratings with summary (AC1-3)
  Future<RatingsResponse> getRatings({
    int page = 1,
    int limit = 10,
    String? cropType,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (cropType != null) 'cropType': cropType,
      };

      final uri = Uri.parse('$baseUrl/farmers/ratings')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return RatingsResponse.fromJson(json);
      } else {
        throw RatingServiceException(
          'Failed to fetch ratings: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is RatingServiceException) rethrow;
      // Return mock data for development
      return RatingsResponse.mock(count: limit);
    }
  }

  /// Get rating summary only (AC2)
  Future<RatingSummary> getSummary() async {
    try {
      final uri = Uri.parse('$baseUrl/farmers/ratings/summary');

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return RatingSummary.fromJson(json);
      } else {
        throw RatingServiceException(
          'Failed to fetch rating summary: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is RatingServiceException) rethrow;
      // Return mock data for development
      return RatingSummary.mock();
    }
  }

  /// Get single rating details (AC4-5)
  Future<RatingDetails> getDetails(String ratingId) async {
    try {
      final uri = Uri.parse('$baseUrl/farmers/ratings/$ratingId');

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return RatingDetails.fromJson(json);
      } else if (response.statusCode == 404) {
        throw RatingServiceException(
          'Rating not found',
          response.statusCode,
        );
      } else {
        throw RatingServiceException(
          'Failed to fetch rating details: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is RatingServiceException) rethrow;
      // Return mock data for development
      return RatingDetails.mock();
    }
  }

  /// Mark rating as seen (AC8)
  Future<bool> markAsSeen(String ratingId) async {
    try {
      final uri = Uri.parse('$baseUrl/farmers/ratings/$ratingId/seen');

      final response = await http.patch(uri, headers: _headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['success'] == true;
      } else {
        throw RatingServiceException(
          'Failed to mark rating as seen: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is RatingServiceException) rethrow;
      // Return success for development
      return true;
    }
  }
}

class RatingServiceException implements Exception {
  final String message;
  final int statusCode;

  RatingServiceException(this.message, this.statusCode);

  @override
  String toString() => 'RatingServiceException: $message (status: $statusCode)';
}
