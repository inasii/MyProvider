import 'package:internet_provider/models/packageModel.dart';

sealed class PaymentType {}

class PackagePayment extends PaymentType {
  final InternetPackage package;
  final String phoneNumber;

  PackagePayment(this.package, {required this.phoneNumber});
}

class PulsaPayment extends PaymentType {
  final String amount;
  final String phoneNumber;

  PulsaPayment({
    required this.amount,
    required this.phoneNumber,
  });
}