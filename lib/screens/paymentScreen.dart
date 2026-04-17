import 'package:flutter/material.dart';
import 'package:internet_provider/api/paymentServices.dart';
import 'package:internet_provider/models/paymentModel.dart';
import 'package:internet_provider/theme/appframe.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/packageModel.dart';
import '../theme/appframe.dart';
import 'successScreen.dart';

class Paymentscreen extends StatefulWidget {
  final PaymentType paymentType; 
  const Paymentscreen({super.key, required this.paymentType});

  @override
  State<Paymentscreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<Paymentscreen> {
  bool _isLoading = false;
  int? paymentId; 

  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  int get _total => switch (widget.paymentType) {
  PackagePayment p => p.package.total,
  PulsaPayment p => int.parse(p.amount.replaceAll(RegExp(r'[^0-9]'), '')),
  };

  // Data QRIS (dalam produksi ini berisi string QR dari payment gateway)
  String get _qrisData => switch (widget.paymentType) {
    PackagePayment p => 'MYPROVIDER|PKG:${p.package.id}|AMT:$_total|TRX:${DateTime.now().millisecondsSinceEpoch}',
    PulsaPayment p => 'MYPROVIDER|PULSA:${p.phoneNumber}|AMT:$_total|TRX:${DateTime.now().millisecondsSinceEpoch}',
  };

  // transaction ID pake tanggal waktu milisecond 5 karakter awal
  String get _transactionId =>
      'TRX${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
  
  @override
  void initState() {
    super.initState();
    _createPayment(); 
  }

  Future<void> _createPayment() async {
    String type;
    String name;
    int amount;
    String phoneNumber;

    if (widget.paymentType is PulsaPayment) {
      final pulsa = widget.paymentType as PulsaPayment;

      type = 'pulsa';
      name = pulsa.amount;
      amount = int.parse(pulsa.amount.replaceAll(RegExp(r'[^0-9]'), ''));
      phoneNumber = pulsa.phoneNumber;

    } else {
      final pkg = widget.paymentType as PackagePayment;

      type = 'package';
      name = pkg.package.name;
      amount = pkg.package.pricePerMonth;
      phoneNumber = pkg.phoneNumber;
    }

    final result = await PaymentService.createPayment(
      phoneNumber: phoneNumber,
      type: type,
      name: name,
      amount: amount,
      packageId: widget.paymentType is PackagePayment
        ? (widget.paymentType as PackagePayment).package.id
        : null,
    );

    if (result['success']) {
      paymentId = result['data']['id']; 
    }
  }

  Future<void> _confirmPayment() async {
    if (paymentId == null) {
      print("Payment ID not found. Cannot confirm payment.");
      return;
    }

    setState(() => _isLoading = true);

    final result = await PaymentService.updatePayment(paymentId!);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessScreen(
            payment: widget.paymentType,
            transactionId: _transactionId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran QRIS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Ringkasan
            _SectionCard(
              title: 'Ringkasan Pesanan',
              child: switch (widget.paymentType) {
                PackagePayment p => _RingkasanPaket(package: p.package, currency: _currency),
                PulsaPayment p => _RingkasanPulsa(amount: p.amount, phoneNumber: p.phoneNumber, currency: _currency),
                },
              
            ),
            const SizedBox(height: 16),

            // QRIS
            _SectionCard(
              title: 'Scan QRIS',
              child: Column(
                children: [
                  // Logo QRIS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('QRIS',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 2)),
                      ),
                      const SizedBox(width: 8),
                      Text('MyProvider', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Appframe.primaryLight, width: 2),
                    ),
                    child: QrImageView(
                      data: _qrisData,
                      version: QrVersions.auto,
                      size: 200,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Appframe.primaryDark,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Appframe.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    _currency.format(_total),
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Appframe.primaryDark),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Berlaku 15 menit · Semua e-wallet & m-banking',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),

                  // Accepted apps
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: ['GoPay', 'OVO', 'Dana', 'ShopeePay', 'BCA', 'Mandiri', 'BNI']
                        .map((app) => Chip(
                              label: Text(app, style: const TextStyle(fontSize: 11)),
                              padding: EdgeInsets.zero,
                              backgroundColor: Appframe.primaryLight,
                              side: BorderSide.none,
                              labelStyle: const TextStyle(color: Appframe.primaryDark),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isLoading ? null : _confirmPayment,
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('Saya Sudah Membayar'),
            ),
            const SizedBox(height: 12),

            Text(
              'Klik tombol di atas setelah pembayaran berhasil.\nTransaksi akan diverifikasi otomatis.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Appframe.primaryDark)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  const _Row({required this.label, required this.value, this.isBold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: isBold ? 15 : 13,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
                  color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }
}

class _RingkasanPaket extends StatelessWidget {
  final InternetPackage package;
  final NumberFormat currency;
  const _RingkasanPaket({required this.package, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Row(label: 'Paket', value: '${package.name} ${package.quota}'),
        _Row(label: 'Periode', value: '1 Bulan'),
        _Row(label: 'Harga', value: currency.format(package.pricePerMonth)),
        _Row(label: 'PPN 11%', value: currency.format(package.ppn)),
        const Divider(),
        _Row(
          label: 'Total Bayar',
          value: currency.format(package.total),
          isBold: true,
          valueColor: Appframe.primaryDark,
        ),
      ],
    );
  }
}

class _RingkasanPulsa extends StatelessWidget {
  final String amount;
  final String phoneNumber;
  final NumberFormat currency;
  const _RingkasanPulsa({
    required this.amount,
    required this.phoneNumber,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Row(label: 'Nomor HP', value: phoneNumber),
        _Row(label: 'Nominal Pulsa', value: amount),
        const Divider(),
        _Row(
          label: 'Total Bayar',
          value: amount,
          isBold: true,
          valueColor: Appframe.primaryDark,
        ),
      ],
    );
  }
}