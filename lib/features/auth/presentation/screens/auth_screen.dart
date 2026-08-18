import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/theme/flokower_theme.dart';
import '../../../../shared/widgets/toast.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = 'Email dan password harus diisi');
      return;
    }
    if (!_isLogin && _nameController.text.isEmpty) {
      setState(() => _error = 'Nama harus diisi');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        await credential.user?.updateDisplayName(_nameController.text.trim());
      }
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'user-not-found': msg = 'Email tidak terdaftar'; break;
        case 'wrong-password': msg = 'Password salah'; break;
        case 'email-already-in-use': msg = 'Email sudah terdaftar'; break;
        case 'weak-password': msg = 'Password minimal 6 karakter'; break;
        case 'invalid-email': msg = 'Format email tidak valid'; break;
        case 'invalid-credential': msg = 'Email atau password salah'; break;
        default: msg = e.message ?? 'Terjadi kesalahan';
      }
      setState(() => _error = msg);
    } catch (e) {
      setState(() => _error = 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlokowerTheme.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              // Logo
              Center(
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: FlokowerTheme.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.local_florist_rounded, color: Colors.white, size: 36),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Flokower',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: FlokowerTheme.black, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Manajemen Inventaris & Penjualan Florist',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: FlokowerTheme.mediumGray),
              ),
              const SizedBox(height: 48),

              // Tab switcher
              Container(
                decoration: BoxDecoration(
                  color: FlokowerTheme.offWhite,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _isLoading ? null : () => setState(() { _isLogin = true; _error = null; }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isLogin ? FlokowerTheme.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _isLogin ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1))] : null,
                          ),
                          child: Text(
                            'Masuk',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: _isLogin ? FlokowerTheme.black : FlokowerTheme.mediumGray,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _isLoading ? null : () => setState(() { _isLogin = false; _error = null; }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isLogin ? FlokowerTheme.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: !_isLogin ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1))] : null,
                          ),
                          child: Text(
                            'Daftar',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: !_isLogin ? FlokowerTheme.black : FlokowerTheme.mediumGray,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              if (!_isLogin) ...[
                const Text('Nama', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FlokowerTheme.darkGray)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Nama Anda',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FlokowerTheme.darkGray)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'email@contoh.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FlokowerTheme.darkGray)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  hintText: 'Minimal 6 karakter',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
                obscureText: true,
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: FlokowerTheme.accentRedLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: FlokowerTheme.accentRed, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_error!, style: const TextStyle(color: FlokowerTheme.accentRed, fontSize: 13, fontWeight: FontWeight.w500))),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text(_isLogin ? 'Masuk' : 'Daftar', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
