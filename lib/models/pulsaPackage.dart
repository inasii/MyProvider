class PulsaPackage {
  final int id;
  final int price;

  PulsaPackage({
    required this.id,
    required this.price,
  });

  factory PulsaPackage.fromJson(Map<String, dynamic> json) {
    return PulsaPackage(
      id: json['id'],
      price: json['price'],
    );
  }
}
