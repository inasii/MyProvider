import 'dart:convert';
import 'package:http/http.dart' as http;

class OtpService {
  // Pakai IP ini supaya emulator bisa akses localhost PC
  static const String _baseUrl = 'http://10.0.2.2:8000/api';

  // Send OTP
  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send-otp'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'phone_number': phone}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // Verify OTP 
  static Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'phone_number': phone, 'otp': otp}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }
}