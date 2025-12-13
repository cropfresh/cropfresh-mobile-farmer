import 'dart:convert';
import 'package:http/http.dart' as http;

/// Profile Service - Story 2.7
/// API layer for profile management operations
class ProfileService {
  static const String _baseUrl = 'http://localhost:3000/v1';
  
  final String? _authToken;
  
  ProfileService({String? authToken}) : _authToken = authToken;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  /// Get current user profile
  Future<ProfileResponse> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/profile'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProfileResponse.fromJson(data['data']);
      } else {
        throw ProfileException('Failed to load profile');
      }
    } catch (e) {
      throw ProfileException('Network error: $e');
    }
  }

  /// Update farmer profile
  Future<void> updateFarmerProfile({
    String? languagePreference,
    List<String>? farmingTypes,
    String? village,
    String? taluk,
    String? district,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (languagePreference != null) body['language_preference'] = languagePreference;
      if (farmingTypes != null) body['farming_types'] = farmingTypes;
      if (village != null) body['village'] = village;
      if (taluk != null) body['taluk'] = taluk;
      if (district != null) body['district'] = district;

      final response = await http.patch(
        Uri.parse('$_baseUrl/users/profile'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw ProfileException(error['error']?['message'] ?? 'Update failed');
      }
    } catch (e) {
      if (e is ProfileException) rethrow;
      throw ProfileException('Network error: $e');
    }
  }

  /// Get profile change history
  Future<List<ProfileAuditEntry>> getProfileHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/profile/history?limit=$limit&offset=$offset'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final entries = data['data']['entries'] as List;
        return entries.map((e) => ProfileAuditEntry.fromJson(e)).toList();
      } else {
        throw ProfileException('Failed to load history');
      }
    } catch (e) {
      if (e is ProfileException) rethrow;
      throw ProfileException('Network error: $e');
    }
  }

  /// Initiate field verification (UPI, email, phone)
  Future<VerificationResponse> initiateVerification({
    required String fieldName,
    required String newValue,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/profile/verify'),
        headers: _headers,
        body: jsonEncode({
          'field_name': fieldName,
          'new_value': newValue,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VerificationResponse.fromJson(data['data']);
      } else {
        final error = jsonDecode(response.body);
        throw ProfileException(error['error']?['message'] ?? 'Verification failed');
      }
    } catch (e) {
      if (e is ProfileException) rethrow;
      throw ProfileException('Network error: $e');
    }
  }

  /// Confirm field verification with token (OTP)
  Future<void> confirmVerification({
    required String fieldName,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/profile/verify/confirm'),
        headers: _headers,
        body: jsonEncode({
          'field_name': fieldName,
          'token': token,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw ProfileException(error['error']?['message'] ?? 'Confirmation failed');
      }
    } catch (e) {
      if (e is ProfileException) rethrow;
      throw ProfileException('Network error: $e');
    }
  }
}

/// Profile Response Model
class ProfileResponse {
  final String userType;
  final Map<String, dynamic>? profile;
  final List<PendingVerification> pendingVerifications;

  ProfileResponse({
    required this.userType,
    this.profile,
    this.pendingVerifications = const [],
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      userType: json['user_type'] ?? '',
      profile: json['profile'],
      pendingVerifications: (json['pending_verifications'] as List?)
          ?.map((e) => PendingVerification.fromJson(e))
          .toList() ?? [],
    );
  }
}

/// Pending Verification Model
class PendingVerification {
  final String fieldName;
  final String status;
  final DateTime expiresAt;

  PendingVerification({
    required this.fieldName,
    required this.status,
    required this.expiresAt,
  });

  factory PendingVerification.fromJson(Map<String, dynamic> json) {
    return PendingVerification(
      fieldName: json['field_name'] ?? '',
      status: json['status'] ?? 'pending',
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }
}

/// Profile Audit Entry Model
class ProfileAuditEntry {
  final int id;
  final String fieldName;
  final String? oldValue;
  final String? newValue;
  final DateTime changedAt;

  ProfileAuditEntry({
    required this.id,
    required this.fieldName,
    this.oldValue,
    this.newValue,
    required this.changedAt,
  });

  factory ProfileAuditEntry.fromJson(Map<String, dynamic> json) {
    return ProfileAuditEntry(
      id: json['id'] ?? 0,
      fieldName: json['field_name'] ?? '',
      oldValue: json['old_value'],
      newValue: json['new_value'],
      changedAt: DateTime.parse(json['changed_at']),
    );
  }
}

/// Verification Response Model
class VerificationResponse {
  final String message;
  final String verificationType;
  final int expiresInSeconds;

  VerificationResponse({
    required this.message,
    required this.verificationType,
    required this.expiresInSeconds,
  });

  factory VerificationResponse.fromJson(Map<String, dynamic> json) {
    return VerificationResponse(
      message: json['message'] ?? '',
      verificationType: json['verification_type'] ?? '',
      expiresInSeconds: json['expires_in_seconds'] ?? 600,
    );
  }
}

/// Profile Exception
class ProfileException implements Exception {
  final String message;
  ProfileException(this.message);
  
  @override
  String toString() => message;
}
