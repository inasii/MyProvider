import 'package:flutter/material.dart';
import 'package:internet_provider/screens/historyScreen.dart';
import 'package:internet_provider/screens/loginScreen.dart';
import 'package:internet_provider/theme/appframe.dart';
import 'package:intl/intl.dart';
import '../models/packageModel.dart';

class ProfileScreen extends StatefulWidget {
  final String phoneNumber;

  const ProfileScreen({super.key, required this.phoneNumber});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Placeholder Name';
  String _email = 'user@email.com';
  late String _phone;

  @override
  void initState() {
    super.initState();
    _phone = widget.phoneNumber;
  }
  

  void _openEditDialog() {
    final nameCtrl = TextEditingController(text: _name);
    final emailCtrl = TextEditingController(text: _email);
    final phoneCtrl = TextEditingController(text: _phone);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text('Edit Profil',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Appframe.primaryDark)),
              const SizedBox(height: 20),
              _EditField(controller: nameCtrl, label: 'Nama Lengkap', icon: Icons.person_outline),
              const SizedBox(height: 12),
              //edot field email
              _EditField(
                controller: emailCtrl,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              //edit field no telp
              /*_EditField(
                controller: phoneCtrl,
                label: 'Nomor HP',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),*/
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _name = nameCtrl.text.trim().isEmpty ? _name : nameCtrl.text.trim();
                      _email = emailCtrl.text.trim().isEmpty ? _email : emailCtrl.text.trim();
                      _phone = phoneCtrl.text.trim().isEmpty ? _phone : phoneCtrl.text.trim();
                      
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Profil berhasil diperbarui'),
                        backgroundColor: Appframe.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  child: const Text('Simpan Perubahan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout() {
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(80, 36),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: Text(
          'PROFIL',
          style: TextStyle(
              color: Appframe.primary,
              fontSize: 20,
              fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_rounded, color: Appframe.primary),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 8),

          // ── Avatar + Info ────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Appframe.primaryLight,
                        border: Border.all(color: Appframe.primary, width: 2.5),
                      ),
                      child: const Icon(Icons.account_circle_outlined,
                          size: 70, color: Appframe.primaryDark),
                    ),
                    
                  ],
                ),
                const SizedBox(height: 12),
                Text(_name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Appframe.primaryDark)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: _openEditDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Appframe.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Appframe.primaryAccent),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined, size: 14, color: Appframe.primary),
                        SizedBox(width: 4),
                        Text('Edit Profil',
                            style: TextStyle(
                                fontSize: 13,
                                color: Appframe.primary,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Info Card =======================================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _InfoRow(icon: Icons.phone_outlined, label: 'Nomor HP', value: _phone),
                const Divider(height: 20),
                _InfoRow(icon: Icons.email_outlined, label: 'Email', value: _email)
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Menu List ────────────────────────────────────────────────
          ...List.generate(customListTiles.length, (index) {
            final tile = customListTiles[index];
            final isLogout = tile.title == 'Log Out';
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              color: Colors.white,
              child: ListTile(
                onTap: () {
                      if (isLogout) {
                      _confirmLogout();
                      } else if (tile.title == 'Riwayat transaksi') {
                      Navigator.push(context,
                      MaterialPageRoute(builder: (_) => HistoryScreen(
                        phoneNumber: _phone,
                      )));
                      } else {
                      tile.onTap?.call();
                      }
                    },
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isLogout
                        ? Colors.red.withOpacity(0.1)
                        : Appframe.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(tile.icon,
                      color: isLogout ? Colors.red : Appframe.primary,
                      size: 20),
                ),
                title: Text(
                  tile.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isLogout ? Colors.red : Colors.black87,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: isLogout ? Colors.red : Colors.grey,
                ),
              ),
            );
          }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Edit Field ───────────────────────────────────────────────────────────────
class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  const _EditField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Appframe.primary, size: 20),
      ),
    );
  }
}

// ── Info Row ─────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Appframe.primary, size: 18),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.black87)),
          ],
        ),
      ],
    );
  }
}

// ── Custom List Tile Model ────────────────────────────────────────────────────
class CustomListTile {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  CustomListTile({
    required this.icon,
    required this.title,
    this.onTap,
  });
}

List<CustomListTile> customListTiles = [
  CustomListTile(
    icon: Icons.receipt_long_outlined,
    title: 'Riwayat transaksi',
    
  ),
  /*CustomListTile(
    icon: Icons.location_on_outlined,
    title: 'Location',
    onTap: () {},
  ),
  CustomListTile(
    icon: Icons.notifications_on_outlined,
    title: 'Notifications',
    onTap: () {},
  ),
  CustomListTile(
    icon: Icons.lock_outline,
    title: 'Ubah Password',
    onTap: () {},
  ),*/
  CustomListTile(
    icon: Icons.logout,
    title: 'Log Out',
  ),
];


