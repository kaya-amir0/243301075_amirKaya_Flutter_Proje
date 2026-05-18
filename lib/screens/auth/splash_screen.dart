import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ps_kiralama/screens/musteri/musteri_ana_screen.dart';
import 'package:ps_kiralama/screens/satici/satici_ana_screen.dart';

class SplashScreen extends StatefulWidget {
  final String rol; // hangi role göre yönlendireceğiz

  const SplashScreen({super.key, required this.rol});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // 2 saniye oynat
    );

    _controller.forward(); // baştan oynat

    // 2 saniye sonra yönlendir
    Future.delayed(const Duration(seconds: 5), () {
      Future.delayed(const Duration(seconds: 2), () {
        if (widget.rol == 'satici') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SaticiAnaScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MusteriAnaScreen()),
          );
        }
      });

    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var x = MediaQuery.of(context).size.width;
    var y = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFF03167C), // aynı koyu lacivert
      body: Center(
        child: Hero(
          tag: "oyun_kolu",
          child: Lottie.asset(
            'assets/gaming2.json',
            width: x-100, // tam ekran genişlik
            height: y-100, // tam ekran yükseklik
            fit: BoxFit.contain,
            controller: _controller,
          ),
        ),
      ),
    );
  }
}
