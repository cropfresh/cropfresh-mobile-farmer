import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class AuthRepository {
  // DEV MODE: Set to true to bypass backend calls for local UI testing
  // Set to false when testing with real backend
  static const bool devMode = true;
  
  // In a real app, this should be in an environment config
  static const String baseUrl = 'http://10.0.2.2:3000/v1'; // 10.0.2.2 for Android Emulator
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ═══════════════════════════════════════════════════════════════════════════
  // REGISTRATION FLOW (Story 2.1)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> requestOtp(String phoneNumber) async {
    // DEV MODE: Bypass backend call
    if (devMode) {
      print('[DEV] Mock OTP sent to $phoneNumber');
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network
      return true;
    }
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/otp/request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber, 'userType': 'FARMER'}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        // Handle error (log it, throw exception, etc.)
        print('Request OTP failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error requesting OTP: $e');
      return false;
    }
  }

  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    // DEV MODE: Accept any 6-digit OTP
    if (devMode) {
      print('[DEV] Mock OTP verification for $phoneNumber with code $otp');
      if (otp.length == 6) {
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate network
        await _storage.write(key: 'jwt_token', value: 'dev_mock_token_${DateTime.now().millisecondsSinceEpoch}');
        return true;
      }
      return false;
    }
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/otp/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        if (token != null) {
          await _storage.write(key: 'jwt_token', value: token);
          return true;
        }
      }
      print('Verify OTP failed: ${response.body}');
      return false;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOGIN FLOW (Story 2.2)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Request OTP for login - checks if phone is registered first
  /// Returns: {success: bool, errorCode?: string, lockedUntil?: string}
  Future<Map<String, dynamic>> requestLoginOtp(String phoneNumber) async {
    // DEV MODE: Bypass backend call
    if (devMode) {
      print('[DEV] Mock Login OTP sent to $phoneNumber');
      await Future.delayed(const Duration(milliseconds: 500));
      return {'success': true};
    }
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/request-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': '+91$phoneNumber'}),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true};
      } else if (response.statusCode == 404) {
        return {'success': false, 'errorCode': 'PHONE_NOT_REGISTERED'};
      } else if (response.statusCode == 423) {
        return {
          'success': false, 
          'errorCode': 'ACCOUNT_LOCKED',
          'lockedUntil': data['locked_until'],
        };
      } else {
        return {'success': false, 'errorCode': data['error'] ?? 'UNKNOWN'};
      }
    } catch (e) {
      print('Error requesting login OTP: $e');
      return {'success': false, 'errorCode': 'NETWORK_ERROR'};
    }
  }

  /// Verify OTP for login and get JWT token
  /// Returns: {success: bool, errorCode?: string, user?: Map, lockedUntil?: string}
  Future<Map<String, dynamic>> verifyLoginOtp(String phoneNumber, String otp) async {
    // DEV MODE: Accept any 6-digit OTP
    if (devMode) {
      print('[DEV] Mock Login OTP verification for $phoneNumber with code $otp');
      if (otp.length == 6) {
        await Future.delayed(const Duration(milliseconds: 500));
        final mockToken = 'dev_login_token_${DateTime.now().millisecondsSinceEpoch}';
        await _storage.write(key: 'jwt_token', value: mockToken);
        await _storage.write(key: 'user_name', value: 'Farmer');
        await _storage.write(key: 'user_phone', value: phoneNumber);
        return {
          'success': true,
          'user': {'id': 1, 'name': 'Farmer', 'phone': phoneNumber},
        };
      }
      return {'success': false, 'errorCode': 'INVALID_OTP'};
    }
    
    try {
      final deviceId = await _getDeviceId();
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': '+91$phoneNumber',
          'otp': otp,
          'device_id': deviceId,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final token = data['token'];
        final user = data['user'];
        if (token != null) {
          await _storage.write(key: 'jwt_token', value: token);
          if (user != null) {
            await _storage.write(key: 'user_name', value: user['name'] ?? '');
            await _storage.write(key: 'user_phone', value: user['phone'] ?? '');
          }
          return {'success': true, 'user': user};
        }
      } else if (response.statusCode == 401) {
        return {'success': false, 'errorCode': 'INVALID_OTP'};
      } else if (response.statusCode == 423) {
        return {
          'success': false,
          'errorCode': 'ACCOUNT_LOCKED',
          'lockedUntil': data['locked_until'],
        };
      }
      
      return {'success': false, 'errorCode': data['error'] ?? 'UNKNOWN'};
    } catch (e) {
      print('Error verifying login OTP: $e');
      return {'success': false, 'errorCode': 'NETWORK_ERROR'};
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SESSION MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check if user is logged in with valid JWT
  /// TEMPORARY: Set to false to test full login flow
  Future<bool> isLoggedIn() async {
    // TEMPORARY: Return false to test full login flow
    // TODO: Remove this override after testing
    return false;
    
    // Original code (uncomment after testing):
    // final token = await _storage.read(key: 'jwt_token');
    // if (token == null || token.isEmpty) {
    //   return false;
    // }
    // 
    // // In DEV mode, any token is valid
    // if (devMode) {
    //   return true;
    // }
    // 
    // // TODO: Validate token expiry by decoding JWT
    // // For now, assume token is valid if it exists
    // return true;
  }

  /// Get stored user info
  Future<Map<String, String?>> getUserInfo() async {
    return {
      'name': await _storage.read(key: 'user_name'),
      'phone': await _storage.read(key: 'user_phone'),
    };
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_name');
    await _storage.delete(key: 'user_phone');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get unique device identifier for session binding
  Future<String> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown';
      }
    } catch (e) {
      print('Error getting device ID: $e');
    }
    return 'unknown-device';
  }
}
