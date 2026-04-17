import 'dart:convert';

class InternetPackage {
  final int id;         
  final String name;
  final String quota;   
  final String description;
  final int pricePerMonth;
  final bool isPopular;
  final List<String> features;
  const InternetPackage({
    required this.id,
    required this.name,
    required this.quota,
    required this.description,
    required this.pricePerMonth,
    this.isPopular = false,
    required this.features,
  });

  int get ppn => (pricePerMonth * 0.11).round();
  int get total => pricePerMonth + ppn;

  factory InternetPackage.fromJson(Map<String, dynamic> json) {
    return InternetPackage(
      id: json['id'],
      name: json['name'],
      quota: '${json['quota']} GB',          
      description: json['description'],
      pricePerMonth: json['price'],   
      isPopular: json['is_popular'] ?? false,
      features: json['features'] is String
          ? List<String>.from(jsonDecode(json['features']))
          : List<String>.from(json['features'] ?? []),
    );
  }
}
