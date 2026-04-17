import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:internet_provider/models/historyModel.dart';

class PaymentService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<Map<String, dynamic>> createPayment({
    required String phoneNumber,
    required String type,
    required String name,
    required int amount,
    int? packageId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payment'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'phone_number': phoneNumber,
        'type': type,
        'name': name,
        'amount': amount,
        'package_id': packageId,
      }),
    );

    return jsonDecode(response.body);
  }

  // Update payment status to success
  static Future<Map<String, dynamic>> updatePayment(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payment/$id/success'),
      headers: {'Accept': 'application/json'},
    );

    return jsonDecode(response.body);
  }

  // Fetch payment history
  static Future<List<PaymentHistory>> getHistory(String phone) async {
  final response = await http.get(
    Uri.parse('$baseUrl/payments/$phone'),
  );

  final List data = jsonDecode(response.body);

  return data.map((e) => PaymentHistory.fromJson(e)).toList();
}
}