import 'package:flutter/material.dart';
import 'package:internet_provider/api/packageServices.dart';
import 'package:internet_provider/api/pulsaServices.dart';
import 'package:internet_provider/models/paymentModel.dart';
import 'package:internet_provider/models/pulsaPackage.dart';
import 'package:internet_provider/theme/appframe.dart';
import 'package:intl/intl.dart';
import '../models/packageModel.dart';
import '../theme/appframe.dart';
import 'paymentScreen.dart';

class Packagescreen extends StatefulWidget {
  final String identifier;
  const Packagescreen({super.key, required this.identifier});

  @override
  State<Packagescreen> createState() => _PackagescreenState();
}

class _PackagescreenState extends State<Packagescreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  InternetPackage? _selected;
  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  List<InternetPackage> _packages = [];
  final PackageService _service = PackageService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchPackages();
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _selected = null);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchPackages() async {
  try {
    final data = await _service.getPackages();

    setState(() {
      _packages = data;
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beli Paket'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          onTap: (_) => setState(() => _selected = null),
          tabs: const [
            Tab(text: 'Kuota Internet'),
            Tab(text: 'Pulsa'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Kuota
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ..._packages.map((pkg) => _PackageCard(
                    package: pkg,
                    isSelected: _selected?.id == pkg.id,
                    currency: _currency,
                    onTap: () => setState(() => _selected = pkg),
                  )),
              const SizedBox(height: 100),
            ],
          ),

          // Tab PULSA
          _PulsaTab(
            phoneNumber: widget.identifier,
            currency: _currency,
          ),
        ],
      ),
      
      bottomNavigationBar: _tabController.index == 0 && _selected != null
          ? _BottomBar(
              package: _selected!,
              currency: _currency,
              onLanjut: _goToPayment,
            )
          : null,
    );
  }

  void _goToPayment() {
    if (_selected == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Paymentscreen(
          paymentType: PackagePayment(
            _selected!,
            phoneNumber: widget.identifier,
          ),
        ),
      ),
    );
  }
}

// ── Pulsa Tab-----------
class _PulsaTab extends StatefulWidget {
  final String phoneNumber;
  final NumberFormat currency;

  const _PulsaTab({
    required this.phoneNumber, 
    required this.currency
    });

  @override
  State<_PulsaTab> createState() => _PulsaTabState();
}


class _PulsaTabState extends State<_PulsaTab> {
  List<PulsaPackage> _pulsaList = [];
  bool _isLoading = true;
  final PulsaService _service = PulsaService();

  @override
  void initState() {
    super.initState();
    _fetchPulsa();
  }

  Future<void> _fetchPulsa() async {
    try {
      final data = await _service.getPulsa();

      setState(() {
        _pulsaList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error pulsa: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
  return ListView(
    padding: const EdgeInsets.all(16),
      children: [
        ..._pulsaList.map((pulsa) => GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Paymentscreen(
                paymentType: PulsaPayment(
                  amount: widget.currency.format(pulsa.price),
                  phoneNumber: widget.phoneNumber,
                ),
              ),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Appframe.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.phone_android, color: Appframe.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.currency.format(pulsa.price),
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Appframe.primaryDark)),
                      const Text('Pulsa reguler',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
          ),
        )).toList(),
      ],
    );
  }
}
// ── Pulsa Nominal Card ────────────────────────────────────────────────────────
class _PulsaNominalCard extends StatelessWidget {
  final PulsaPackage pulsa;
  final NumberFormat currency;
  final VoidCallback onTap;

  const _PulsaNominalCard({
    required this.pulsa,
    required this.currency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Appframe.primaryAccent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone_android, color: Appframe.primary, size: 24),
            const SizedBox(height: 6),
            Text(
              currency.format(pulsa.price),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Appframe.primaryDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final InternetPackage package;
  final bool isSelected;
  final NumberFormat currency;
  final VoidCallback onTap;

  const _PackageCard({
    required this.package,
    required this.isSelected,
    required this.currency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Appframe.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Appframe.primary : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (package.isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Appframe.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Terpopuler',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                Text(package.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Appframe.primaryDark)),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(currency.format(package.pricePerMonth),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700, color: Appframe.primaryDark)),
                    const Text('/bulan', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.speed, size: 16, color: Appframe.primary),
                const SizedBox(width: 4),
                Text(package.quota,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Appframe.primary)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(package.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: package.features
                  .map((f) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Appframe.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(f,
                            style: const TextStyle(fontSize: 11, color: Appframe.primaryDark)),
                      ))
                  .toList(),
            ),
            if (isSelected) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Icon(Icons.check_circle, color: Appframe.primary, size: 20),
                  SizedBox(width: 4),
                  Text('Dipilih', style: TextStyle(color: Appframe.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final InternetPackage package;
  final NumberFormat currency;
  final VoidCallback onLanjut;

  const _BottomBar({required this.package, required this.currency, required this.onLanjut});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(package.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(currency.format(package.total),
                  style: const TextStyle(
                      color: Appframe.primaryDark, fontWeight: FontWeight.w700, fontSize: 16)),
              const Text('sudah termasuk PPN', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: onLanjut,
              child: const Text('Lanjut ke Pembayaran'),
            ),
          ),
        ],
      ),
    );
  }
}