import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/appframe.dart';
import 'otpScreen.dart';
import '../api/otpServices.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  bool _isLoading = false;

  String? _validatePhone(String? val) {
    if (val == null || val.isEmpty) return 'Wajib diisi';
    if (!RegExp(r'^(\+62|62|0)[0-9]{8,12}$').hasMatch(val)) {
      return 'Invalid phone number format (e.g: 08123456789)';
    }
    return null;
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // simulasi kirim OTP

    final result = await OtpService.sendOtp(_phoneCtrl.text.trim());

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      final otp = result['otp']?.toString() ?? '-';

      // pop up for OTP code (dev mode)
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('OTP Code (Dev Mode)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Your OTP Code:'),
              const SizedBox(height: 12),
              Text(
                otp,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: Appframe.primary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // Setelah dialog ditutup, baru pindah ke OTP screen
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(phone: _phoneCtrl.text.trim()),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to send OTP')),
      );
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }
  
  //UI Login Screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                // Logo
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Appframe.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.wifi, color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'MyProvider',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Appframe.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Center(
                  child: Text(
                    'Fast connection, smooth life',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ),
                const SizedBox(height: 48),

                Text(
                  'Input your phone number',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Appframe.primaryDark,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                    'We will send an OTP code to your phone number',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
                const SizedBox(height: 20),

                // Phone field
                TextFormField(
                  controller: _phoneCtrl,
                  validator: _validatePhone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Nomor HP',
                    hintText: '08123456789',
                    prefixIcon: Icon(Icons.phone_outlined, color: Appframe.primary),
                  ),
                ),
                const SizedBox(height: 24),

                // Lanjutkan button
                ElevatedButton(
                  onPressed: _isLoading ? null : _continue,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Continue'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}