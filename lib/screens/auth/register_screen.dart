import 'package:flutter/material.dart';
import 'package:ps_kiralama/services/auth_service.dart';
import 'dart:async';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final adController = TextEditingController();
  final soyadController = TextEditingController();
  final telController = TextEditingController();
  final emailController = TextEditingController();
  final sifreController = TextEditingController();
  final authService = AuthService();

  bool yukleniyor = false;
  String _seciliRol = 'musteri'; // varsayılan müşteri
  List<Color> _renkler = [Color(0xFF0A0E21), Color(0xff0000af)];

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _renkler = _renkler.reversed.toList();
      });
    });
  }

  @override
  void dispose() {
    adController.dispose();
    soyadController.dispose();
    telController.dispose();
    emailController.dispose();
    sifreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // Hareketli arka plan
          AnimatedContainer(
            duration: const Duration(milliseconds: 1700),
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _renkler,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [

                  const SizedBox(height: 20),

                  const Text(
                    'Kayıt Ol',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Rol seçimi - Satıcı mı Müşteri mi
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _seciliRol = 'musteri'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _seciliRol == 'musteri'
                                  ? Colors.blue
                                  : Colors.transparent,
                              border: Border.all(color: Colors.blue),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.person, color: Colors.white, size: 30),
                                SizedBox(height: 8),
                                Text('Müşteri',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _seciliRol = 'satici'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _seciliRol == 'satici'
                                  ? Colors.blue
                                  : Colors.transparent,
                              border: Border.all(color: Colors.blue),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.store, color: Colors.white, size: 30),
                                SizedBox(height: 8),
                                Text('Satıcı',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Ad
                  _textField(adController, 'Ad', Icons.person),
                  const SizedBox(height: 12),

                  // Soyad
                  _textField(soyadController, 'Soyad', Icons.person_outline),
                  const SizedBox(height: 12),

                  // Tel
                  _textField(telController, 'Telefon', Icons.phone),
                  const SizedBox(height: 12),

                  // Email
                  _textField(emailController, 'Email', Icons.email),
                  const SizedBox(height: 12),

                  // Şifre
                  _textField(sifreController, 'Şifre', Icons.lock, gizle: true),
                  const SizedBox(height: 24),

                  // Kayıt Ol butonu
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: yukleniyor ? null : _kayitOl,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: yukleniyor
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Kayıt Ol',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Giriş yap linki
                  TextButton(
                    onPressed: () => Navigator.pop(context), // geri dön
                    child: const Text(
                      'Zaten hesabın var mı? Giriş Yap',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TextField'ları tekrar yazmamak için yardımcı fonksiyon
  Widget _textField(TextEditingController controller, String label, IconData icon, {bool gizle = false}) {
    return TextField(
      controller: controller,
      obscureText: gizle, // şifre alanı için gizle
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }

  Future<void> _kayitOl() async {
    setState(() => yukleniyor = true);

    try {
      await authService.kayitOl(
        email: emailController.text.trim(),
        sifre: sifreController.text.trim(),
        ad: adController.text.trim(),
        soyad: soyadController.text.trim(),
        tel: telController.text.trim(),
        rol: _seciliRol,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kayıt başarılı! Giriş yapabilirsiniz.')),
        );
        Navigator.pop(context); // login ekranına dön
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      setState(() => yukleniyor = false);
    }
  }
}