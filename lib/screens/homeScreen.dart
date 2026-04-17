import 'package:flutter/material.dart';
import 'package:internet_provider/models/packageModel.dart';
import 'package:internet_provider/models/pulsaPackage.dart';
import 'package:internet_provider/screens/historyScreen.dart';
import 'package:internet_provider/screens/loginScreen.dart';
import 'package:internet_provider/screens/packageScreen.dart';
import 'package:internet_provider/screens/paymentScreen.dart';
import 'package:internet_provider/screens/profileScreen.dart' hide SizedBox;
import 'package:internet_provider/api/pulsaServices.dart';
import '../models/paymentModel.dart';
import '../theme/appframe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/src/widgets/basic.dart' hide SizedBox;


class HomeScreen extends StatefulWidget {
  final String identifier;
  const HomeScreen({super.key, required this.identifier});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  //ambil display name
  String get displayName {
    final id = widget.identifier;
    if (id.contains('@')) return id.split('@').first;
    if (id.startsWith('0') || id.startsWith('+')) {
      return id.length > 7
          ? '${id.substring(0, 4)}****${id.substring(id.length - 3)}'
          : id;
    }
    return id.isEmpty ? 'Pengguna' : id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(displayName: displayName,identifier: widget.identifier, onLogout: () => _confirmLogout(context)),
          Packagescreen(identifier: widget.identifier),
          //_PlaceholderTab(icon: Icons.headset_mic_outlined, label: 'Bantuan'),
          ProfileScreen(phoneNumber: widget.identifier),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

// HOME TAB ---------------------------------------------------------

class _HomeTab extends StatefulWidget {
  final String displayName;
  final String identifier;
  final VoidCallback onLogout;
  const _HomeTab({required this.displayName,required this.identifier, required this.onLogout});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  List<InternetPackage> _packages = [];
  List<PulsaPackage> _pulsaList = [];
  bool isLoadingPulsa = true;
  bool isLoadingPackage = true;

  final PulsaService _service = PulsaService();

  int quota = 0;
  int pulsa = 0;

  @override
  void initState() {
    super.initState();
    _fetchPackages();
    _fetchPulsa();
    _fetchUser(); 
  }

  Future<void> _fetchPackages() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/packages'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _packages = data.map((e) => InternetPackage.fromJson(e)).toList();
          isLoadingPackage = false;
        });
      } else {
        setState(() => isLoadingPackage = false);
      }
    } catch (e) {
      setState(() => isLoadingPackage = false);
    }
  }

  Future<void> _fetchPulsa() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/pulsa'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _pulsaList = data.map((e) => PulsaPackage.fromJson(e)).toList();
          isLoadingPulsa = false;
        });
      } else {
        setState(() => isLoadingPulsa = false);
      }
    } catch (e) {
      setState(() => isLoadingPulsa = false);
    }
  }

  Future<void> _fetchUser() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/user/${widget.identifier}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          pulsa = data['pulsa'] ?? 0;
          quota = data['quota'] ?? 0;
        });
      }
    } catch (e) {
      print("Error user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ---------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color:Appframe.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.wifi, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Text('MyProvider',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('Halo, ${widget.displayName} !',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  const Text('Paket aktif hingga 30 April 2025',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 20),

                  // untuk sisa Pulsa, Sisa Kuota==============================
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _HeaderStat(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Sisa Pulsa',
                          value: 'Rp $pulsa',
                        ),
                        _vDivider(),
                        _HeaderStat(
                          icon: Icons.data_usage_outlined,
                          label: 'Sisa Kuota',
                          value: '$quota GB',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Main menus Icons======================================
            /*Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  /*_IconMenu(
                    icon: Icons.inventory_2_outlined,
                    label: 'Beli paket',
                    color: Appframe.primary,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => Packagescreen(identifier: identifier))),
                  ),
                  const SizedBox(height: 20),
                  _IconMenu(
                    icon: Icons.receipt_long_outlined,
                    label: 'Transaksi',
                    color: Appframe.primary,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const HistoryScreen())),
                  ),
                  _IconMenu(
                    icon: Icons.card_giftcard_outlined,
                    label: 'Kirim Hadiah',
                    color: const Color(0xFFE91E63),
                    onTap: () {},
                  ),
                  _IconMenu(
                    icon: Icons.stars_outlined,
                    label: 'Poin',
                    color: const Color(0xFFFF9800),
                    onTap: () {},
                  ),*/
                ],
              ),
            ),*/

            const SizedBox(height: 15),

            // ── Rekomendasi Paket ------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Rekomendasi Paket',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => Packagescreen(identifier: widget.identifier))),
                    child: const Text('Lihat semua',
                        style: TextStyle(fontSize: 13, color: Appframe.primary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            
            SizedBox(
              height: 150,
              child: isLoadingPackage
                  ? const Center(child: CircularProgressIndicator())
                  : _packages.isEmpty
                      ? const Center(child: Text('Tidak ada paket tersedia'))
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          children: _packages.map((package) => _PackageCard(
                            package: package,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Paymentscreen(
                                  paymentType: PackagePayment(
                                    package,
                                    phoneNumber: widget.identifier,
                                  ),
                                ),
                              ),
                            ),
                          )).toList(),
                        ),
            ),

            const SizedBox(height: 24),

            // Isi Pulsa===================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Isi Pulsa',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  GestureDetector(
                    onTap: ()  => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => Packagescreen(identifier: widget.identifier))),
                    child: const Text('Lihat semua',
                        style: TextStyle(fontSize: 13, color: Appframe.primary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.1,
                children: _pulsaList.map((pulsa) {
                  return _PulsaCard(
                    amount: 'Rp ${pulsa.price}',
                    phoneNumber: widget.identifier,
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 40,
        color: Colors.white.withOpacity(0.3),
        margin: const EdgeInsets.symmetric(horizontal: 4),
      );
}

//Header ========================================================
class _HeaderStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _HeaderStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
              textAlign: TextAlign.center),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

//Menu ICon ==========================================================
class _IconMenu extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _IconMenu(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// Paket Card ============================================
class _PackageCard extends StatelessWidget {
  final InternetPackage package;
  final VoidCallback? onTap;
  const _PackageCard(
      { 
    required this.package,
    this.onTap,});

  @override
  Widget build(BuildContext context) {
    // tag & warna berdasarkan id paket
   /* final tagInfo = {
      'basic': ('Hemat', const Color(0xFF4CAF50)),
      'turbo': ('Terpopuler', Appframe.primary),
      'ultra': ('Terbaik', const Color(0xFF9C27B0)),
      'giga': ('Premium', const Color(0xFFE91E63)),
    };
    final tag = tagInfo[package.id]?.$1 ?? package.name;
    final tagColor = tagInfo[package.id]?.$2 ?? Appframe.primary;*/

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 148,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                //color: tagColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              /*child: Text(tag,
                  style: TextStyle(
                      color: tagColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),*/
            ),
            const SizedBox(height: 8),
            Text(package.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Appframe.primaryDark)),
            Text(package.quota,
                style: const TextStyle(
                    fontSize: 12,
                    color: Appframe.primary,
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            Text('Rp ${package.pricePerMonth}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Appframe.primaryDark)),
            const Text('/bulan',
                style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
  
}

// Pulsa Card
class _PulsaCard extends StatelessWidget {
  final String amount;
  final String phoneNumber;
  const _PulsaCard({required this.amount,required this.phoneNumber,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Paymentscreen(
            paymentType: PulsaPayment(
              amount: amount,
              phoneNumber: phoneNumber, // ← identifier masuk sini
              )
            ),
          ),
        ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Appframe.primaryAccent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone_android, color: Appframe.primary, size: 20),
            const SizedBox(height: 4),
            Text(amount,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Appframe.primaryDark),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─── BOTTOM NAV ──────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Appframe.primary,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle:
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      backgroundColor: Colors.white,
      elevation: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Beli',
        ),
        /*BottomNavigationBarItem(
          icon: Icon(Icons.headset_mic_outlined),
          activeIcon: Icon(Icons.headset_mic),
          label: 'Bantuan',
        ),*/
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Akun',
        ),
      ],
    );
  }
}

// ─── PLACEHOLDER TAB ─────────────────────────────────────────────────────────
class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PlaceholderTab({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 60, color: Appframe.primaryAccent),
          const SizedBox(height: 12),
          Text('Halaman $label',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Appframe.primaryDark)),
          const SizedBox(height: 8),
          const Text('Segera hadir',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}