import 'package:flutter/material.dart';
import 'package:internet_provider/theme/appframe.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
 
// Model=======================
 
enum HistoryType { paket, pulsa }
 
enum HistoryStatus { sukses, gagal }
 
class PurchaseHistory {
  final String id;
  final String title;
  final String subtitle;
  final int amount;
  final DateTime date;
  final HistoryType type;
  final HistoryStatus status;
 
  PurchaseHistory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
    required this.status,
  });
}

// Screen================================================
 
class HistoryScreen extends StatefulWidget {
  final String phoneNumber;

  const HistoryScreen({super.key, required this.phoneNumber});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<PurchaseHistory> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/payments/${widget.phoneNumber}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          history = data.map<PurchaseHistory>((item) {
            return PurchaseHistory(
              id: item['id'].toString(),
              title: item['type'] == 'pulsa'
                  ? 'Pulsa Rp ${item['amount']}'
                  : item['name'],
              subtitle: item['phone_number'],
              amount: item['amount'],
              date: DateTime.parse(item['created_at']),
              type: item['type'] == 'pulsa'
                  ? HistoryType.pulsa
                  : HistoryType.paket,
              status: item['status'] == 'success'
                  ? HistoryStatus.sukses
                  : HistoryStatus.gagal,
            );
          }).toList();

          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
 
    // Kelompokkan berdasarkan bulan
    final Map<String, List<PurchaseHistory>> grouped = {};
    for (final item in history) {
      final key = DateFormat('MMMM yyyy').format(item.date);
      grouped.putIfAbsent(key, () => []).add(item);
    }
 
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        backgroundColor: Appframe.primary,
        foregroundColor: Colors.white,
        title: const Text('Riwayat Transaksi'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
                child: Text(entry.key,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey)),
              ),
              ...entry.value.map((item) => _HistoryCard(
                    item: item,
                    currency: currency,
                    onTap: () => showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(24))),
                      builder: (_) =>
                          _DetailSheet(item: item, currency: currency),
                    ),
                  )),
            ],
          );
        }).toList(),
      ),
    );
  }
}
 
class _HistoryCard extends StatelessWidget {
  final PurchaseHistory item;
  final NumberFormat currency;
  final VoidCallback onTap;
  const _HistoryCard({required this.item, required this.currency, required this.onTap});
 
  Color get _statusColor => switch (item.status) {
        HistoryStatus.sukses => Appframe.primary,
        HistoryStatus.gagal => Colors.red,
      };
 
  String get _statusLabel => switch (item.status) {
        HistoryStatus.sukses => 'Sukses',
        HistoryStatus.gagal => 'Gagal',
      };
 
  IconData get _typeIcon => item.type == HistoryType.paket
      ? Icons.wifi_rounded
      : Icons.phone_android_rounded;
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: Appframe.primaryLight,
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(_typeIcon, color: Appframe.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(item.subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(DateFormat('dd MMM yyyy, HH:mm').format(item.date),
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(currency.format(item.amount),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Appframe.primaryDark)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(_statusLabel,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _statusColor)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
 
class _DetailSheet extends StatelessWidget {
  final PurchaseHistory item;
  final NumberFormat currency;
  const _DetailSheet({required this.item, required this.currency});
 
  Color get _statusColor => switch (item.status) {
        HistoryStatus.sukses => Appframe.primary,
        HistoryStatus.gagal => Colors.red,
      };
 
  String get _statusLabel => switch (item.status) {
        HistoryStatus.sukses => 'Sukses',
        HistoryStatus.gagal => 'Gagal',
      };
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2))),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(
              item.status == HistoryStatus.sukses
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: _statusColor,
              size: 36,
            ),
          ),
          const SizedBox(height: 8),
          Text(_statusLabel,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _statusColor)),
          const SizedBox(height: 4),
          Text(currency.format(item.amount),
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Appframe.primaryDark)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                _DetailRow(label: 'Produk', value: item.title),
                const SizedBox(height: 8),
                _DetailRow(label: 'Keterangan', value: item.subtitle),
                const SizedBox(height: 8),
                _DetailRow(label: 'Tanggal', value: DateFormat('dd MMM yyyy, HH:mm').format(item.date)),
                const SizedBox(height: 8),
                _DetailRow(label: 'No. Transaksi', value: item.id),
                const SizedBox(height: 8),
                _DetailRow(label: 'Metode Bayar', value: 'QRIS'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Unduh Bukti'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Appframe.primary,
                      side: const BorderSide(color: Appframe.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Tutup'),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
 
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});
 
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600))),
      ],
    );
  }
}