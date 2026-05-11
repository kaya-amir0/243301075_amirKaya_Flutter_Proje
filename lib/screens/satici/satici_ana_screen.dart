import 'package:flutter/material.dart';
import 'package:ps_kiralama/screens/satici/satici_ilanlar_screen.dart';
import 'package:ps_kiralama/screens/satici/piyasa_screen.dart';
import 'package:ps_kiralama/screens/satici/kiralamalar_screen.dart';
import 'package:ps_kiralama/screens/satici/profil_screen.dart';

class SaticiAnaScreen extends StatefulWidget {
  const SaticiAnaScreen({super.key});

  @override
  State<SaticiAnaScreen> createState() => _SaticiAnaScreenState();
}

class _SaticiAnaScreenState extends State<SaticiAnaScreen> {

  int _secilenSayfa = 0; // hangi sekme seçili

  // Navigation bar'daki sayfalar
  final List<Widget> _sayfalar = [

    const PiyasaScreen(),
    const SaticiIlanlarScreen(),
    const KiralamalarScreen(),
    const ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.black12,

      body: _sayfalar[_secilenSayfa], // seçilen sayfayı göster

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
            icon: Icon(Icons.list_alt),
            label: 'İlanlarım',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Kiralalar',
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