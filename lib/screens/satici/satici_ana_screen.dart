import 'package:flutter/material.dart';
import 'package:ps_kiralama/screens/satici/ilan_ekle_screen.dart';
import 'package:ps_kiralama/screens/satici/satici_ilanlar_screen.dart';
import 'package:ps_kiralama/screens/satici/piyasa_screen.dart';
import 'package:ps_kiralama/screens/satici/kiralamalar_screen.dart';


class SaticiAnaScreen extends StatefulWidget {
  const SaticiAnaScreen({super.key});

  @override
  State<SaticiAnaScreen> createState() => _SaticiAnaScreenState();
}

class _SaticiAnaScreenState extends State<SaticiAnaScreen> {

  int _secilenSayfa = 0;

  final List<Widget> _sayfalar = [
    const PiyasaScreen(),
    const SaticiIlanlarScreen(),
    const IlanEkleScreen(),
    const KiralamalarScreen(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: _secilenSayfa == 2
          ? _sayfalar[_secilenSayfa == 0 ? 0 : _secilenSayfa]
          : _sayfalar[_secilenSayfa],

      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            // Piyasa
            _navItem(Icons.store, 'Piyasa', 0),

            // İlanlarım
            _navItem(Icons.list_alt, 'İlanlarım', 1),

            // Ortadaki + butonu
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>IlanEkleScreen()));
              },
              child: Container( 
                width: 55,
                height: 55,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),

            // Kiralalar
            _navItem(Icons.history, 'Kiralalar', 3),

            // Profil
            _navItem(Icons.person, 'Profil', 4),

          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final secili = _secilenSayfa == index;
    return GestureDetector(
      onTap: () => setState(() => _secilenSayfa = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: secili ? Colors.black : Colors.grey, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: secili ? Colors.black : Colors.grey,
              fontSize: 11,
              fontWeight: secili ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}