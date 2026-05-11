import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ps_kiralama/screens/auth/register_screen.dart';
import 'package:ps_kiralama/screens/auth/splash_screen.dart';
import 'package:ps_kiralama/services/auth_service.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {

  final emailController = TextEditingController();
  final sifreController = TextEditingController();
  final authService = AuthService();
  bool yukleniyor = false;
  late AnimationController _controller; // animasyon kontrolcüsü
  List<Color> _renkler = [Color(0xFF0A0E21), Color(0xff0000af)];
  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _renkler = _renkler.reversed.toList();
      });
    });


    _controller = AnimationController(
      vsync: this, // SingleTickerProviderStateMixin sayesinde çalışır
      duration: const Duration(milliseconds: 239),
    );
    // her karakter girilince animasyonu baştan oynat
    emailController.addListener(_animasyonuOynat);
    sifreController.addListener(_animasyonuOynat);

  }

  void _animasyonuOynat() {
    if (_controller.value >= 0.9) {
      // sona geldi, önce başa sar (animasyon yok, anında)
      _controller.value = 0.0;
    }
    // her zaman 0.1 ileri git
    _controller.animateTo(
      _controller.value + 0.1,
      duration: const Duration(milliseconds: 275),
    );
  }

  @override
  void dispose() { // bu sayfadan çıkarken temizleme yapar.
    _controller.dispose();
    emailController.dispose();
    sifreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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

                  const SizedBox(height: 40),


                  Hero(
                    tag: "oyun_kolu",
                    child: Lottie.asset(
                      'assets/gaming2.json',
                      width: 250,
                      height: 250, //animasyonu direkt uygulayıp boyutlarını girdim
                      controller: _controller, // interaktifleştirmek için controller verdim.
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'SANİYELER İÇİNDE PLAYSTATİON KİRALA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),


                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.email, color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blue, width: 2),
                            ),
                          ),
                        ),
                      ),





                    ],
                  ),

                  const SizedBox(height: 16),


                  TextField(
                    controller: sifreController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      labelStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Giriş Yap butonu
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: yukleniyor ? null : _girisYap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: yukleniyor
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Giriş Yap',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Kayıt ol linki
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>RegisterScreen()));
                    },
                    child: const Text(
                      'Hesabın yok mu? Kayıt Ol',
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

  Future<void> _girisYap() async {
    setState(() => yukleniyor = true);

    try {
      final rol = await authService.girisYap(
        email: emailController.text.trim(),
        sifre: sifreController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => SplashScreen(rol: rol),
            transitionDuration: const Duration(milliseconds: 800), // geçiş süresi
            reverseTransitionDuration: const Duration(milliseconds: 800),
          ),
        );
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


