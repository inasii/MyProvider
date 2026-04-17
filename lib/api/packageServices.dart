import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/packageModel.dart';

class PackageService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<List<InternetPackage>> getPackages() async {
    final response = await http.get(
      Uri.parse('$baseUrl/packages'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => InternetPackage.fromJson(json)).toList();
    } else {
      throw Exception('Gagal load data: ${response.statusCode}');
    }
  }
}