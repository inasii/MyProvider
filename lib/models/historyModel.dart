class PaymentHistory {
  final String type;
  final String name;
  final int amount;
  final String status;
  final String date;

  PaymentHistory({
    required this.type,
    required this.name,
    required this.amount,
    required this.status,
    required this.date,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      type: json['type'],
      name: json['name'],
      amount: json['amount'],
      status: json['status'],
      date: json['created_at'],
    );
  }
}