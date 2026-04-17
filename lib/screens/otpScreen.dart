import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_provider/api/otpServices.dart';
import '../theme/appframe.dart';
import 'homeScreen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // 4 controller untuk 4 kotak OTP
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(4, (_) => FocusNode());

  bool _isLoading = false;
  String? _errorMsg;

  int _secondsLeft = 60; bool _isExpired = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 60;
    _isExpired = false;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        setState(() {
          _isExpired = true;
        });
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _resendOtp() async {
    final result = await OtpService.sendOtp(widget.phone);
    if (!mounted) return;
    if (result['success'] == true) {
      _startTimer();
      // Tampilkan OTP baru di popup (dev mode)
      final otp = result['otp']?.toString() ?? '-';
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('OTP generated (dev mode)'),
          content: Text(
            otp,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              color: Appframe.primary,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Oke'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to resend OTP')),
      );
    }
  }

  String get _otpValue =>
      _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 3) {
      // Pindah ke kotak berikutnya
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Backspace: kembali ke kotak sebelumnya
      _focusNodes[index - 1].requestFocus();
    }
    setState(() => _errorMsg = null);
  }

  Future<void> _verifikasi() async {
    if (_otpValue.length < 4) {
      setState(() => _errorMsg = 'Please enter 4-digit OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    
    final result = await OtpService.verifyOtp(widget.phone, _otpValue);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['message'] == 'Login Success') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(identifier: widget.phone),
      ),
    );
    } else if (result['message'] == 'OTP already expired') {
      _timer?.cancel();
      setState(() {
        _isExpired = true;
        _errorMsg = result['message'];
      });
      return;
    } else {
      setState(() => _errorMsg = result['message'] ?? 'OTP code is incorrect. Please try again.');
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
    }
  }

  @override
  void dispose() {
  _timer?.cancel(); // tambah ini
  for (final c in _controllers) c.dispose();
  for (final f in _focusNodes) f.dispose();
  super.dispose();
  }

// UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Appframe.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              Text(
                'Verificate OTP',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Appframe.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  children: [
                    const TextSpan(text: 'OTP code has been sent to '),
                    TextSpan(
                      text: widget.phone,
                      style: const TextStyle(
                        color: Appframe.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // 6 kotak OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (i) {
                  return SizedBox(
                    width: 60,
                    height: 56,
                    child: TextFormField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (v) => _onDigitChanged(i, v),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Appframe.primaryDark,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Appframe.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              // Error message
              if (_errorMsg != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMsg!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],

              const SizedBox(height: 32),
              Text(
                'Resend OTP in ${_secondsLeft}s',
                style: TextStyle(
                  color: _isExpired ? Appframe.primary : Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),

              // Tombol verifikasi
              ElevatedButton(
                onPressed: _isLoading ? null : _verifikasi,
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text('Verificate OTP'),
              ),
              const SizedBox(height: 20),

              // Kirim ulang
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Forgot OTP? ',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        // simulasi kirim ulang
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('OTP has been resent'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text(
                        'Resend OTP',
                        style: TextStyle(
                          color: Appframe.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Petunjuk dummy (bisa dihapus saat production)
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber[700], size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Mode dummy: gunakan OTP  1234',
                      style: TextStyle(
                        color: Colors.amber[800],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}