import 'package:flutter/material.dart';
import 'package:ps_kiralama/screens/musteri/musteri_piyasa_screen.dart';
import 'package:ps_kiralama/screens/musteri/kiralamalarim_screen.dart';
import 'package:ps_kiralama/screens/musteri/musteri_profil_screen.dart';

class MusteriAnaScreen extends StatefulWidget {
  const MusteriAnaScreen({super.key});

  @override
  State<MusteriAnaScreen> createState() => _MusteriAnaScreenState();
}

class _MusteriAnaScreenState extends State<MusteriAnaScreen> {

  int _secilenSayfa = 0;

  final List<Widget> _sayfalar = [
    const MusteriPiyasaScreen(),
    const KiralamalarimScreen(),
    const MusteriProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: _sayfalar[_secilenSayfa],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _secilenSayfa,
        onTap: (index) => setState(() => _secilenSayfa = index),
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Piyasa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Kiralamalarım',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}