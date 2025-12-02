import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  // In a real app, this should be in an environment config
  static const String baseUrl = 'http://10.0.2.2:3000/v1'; // 10.0.2.2 for Android Emulator
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> requestOtp(String phoneNumber) async {
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

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }
}
