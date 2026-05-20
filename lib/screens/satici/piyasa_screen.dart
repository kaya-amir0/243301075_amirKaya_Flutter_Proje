import 'package:flutter/material.dart';
import 'package:ps_kiralama/screens/musteri/musteri_profil_screen.dart';
import 'package:ps_kiralama/screens/satici/profil_screen.dart';
import 'package:ps_kiralama/services/supabase_client.dart';

class PiyasaScreen extends StatefulWidget {
  const PiyasaScreen({super.key});

  @override
  State<PiyasaScreen> createState() => _PiyasaScreenState();
}

class _PiyasaScreenState extends State<PiyasaScreen> {

  final searchController = TextEditingController();
  String _secilenFiltre = 'En Güncel'; // varsayılan filtre

  final List<String> _filtreler = [
    'En Güncel',
    'Popüler',
    'En Ucuz',
    'Yakınımda',
  ];

  List<Map<String, dynamic>> _ilanlar = []; // ilanları tutacak liste

  @override
  void initState() {
    super.initState();
    _ilanlariGetir(); // sayfa açılınca çek
  }

  Future<void> _ilanlariGetir() async {
    final data = await supabase
        .from('ilanlar')
        .select('''
      ilan_id,
      fiyat,
      durum,
      konsollar (
        konsol_modeli,
        saticilar (
          satici_adi,
          satici_soyadi,
          satici_enlemi,
          satici_boylami
        )
      )
    ''')
        .eq('durum', 'AKTİF/HAZIR');
    print("gelen veri : $data");

    setState(() {
      _ilanlar = List<Map<String, dynamic>>.from(data);
    });

  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var x=MediaQuery.of(context).size.width;
    var y=MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min, // Row içeriği kadar yer kaplasın
            children: [
              Column(
                children: [
                  Text("Playstation ", style: TextStyle(fontSize: 15, color: Colors.black)),
                  Text("Zamanı", style: TextStyle(fontSize: 18, color: Colors.black)),
                ],
              ),
              SizedBox(
                width: 90,
                height: 90,
                child: Image.asset("assets/logo.png"),
              ),
            ],
          ),
        ),
        actions: [
          // Profil ikonu
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilScreen()),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade100,
                child: const Icon(Icons.person),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: searchController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Konsol veya satıcı ara...',
                hintStyle: TextStyle(color: Colors.black ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filtre chip'leri


          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _ilanlar.length,
              itemBuilder: (context, index) {
                final filtre = _filtreler[index];
                final secili = _secilenFiltre == filtre;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(filtre),
                    selected: secili,
                    onSelected: (_) => setState(() => _secilenFiltre = filtre),
                    selectedColor: Colors.black,
                    labelStyle: TextStyle(
                      color: secili ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    backgroundColor: Colors.grey.shade100,
                    checkmarkColor: Colors.white,
                  ),
                );
              },
            ),
          ),

          const Divider(height: 16),

          // İlan listesi
          Expanded(
            child: Expanded(
              child: _ilanlar.isEmpty
                  ? const Center(child: CircularProgressIndicator()) // yükleniyor
                  : ListView.builder(
                itemCount: _ilanlar.length,
                itemBuilder: (context, index) {
                  return _ilanKarti(_ilanlar[index]);
                },
              ),
            ),
          ),

        ],
      ),
    );
  }

  // İlan kartı widget'ı
// _ilanKarti fonksiyonunu güncelle:
  Widget _ilanKarti(Map<String, dynamic> ilan) {

    // verileri çek
    final konsol = ilan['konsollar'] as Map<String, dynamic>;
    final satici = konsol['saticilar'] as Map<String, dynamic>;

    final model = konsol['konsol_modeli'] ?? 'PS5';
    final fiyat = ilan['fiyat']?.toString() ?? '0';
    final durum = ilan['durum'] ?? 'AKTİF/HAZIR';
    final saticiAdi = '${satici['satici_adi']} ${satici['satici_soyadi']}';

    return Container(
      // ... aynı tasarım
      child: Row(
        children: [
          // Konsol görseli
          Image.asset(
            model == 'PS5' ? 'assets/ps5.png' : 'assets/ps4.png',
            width: MediaQuery.of(context).size.width/3,

            height: MediaQuery.of(context).size.height/10,
          ),

          // Bilgiler
          Row(
            children: [

              Column(
                children: [
                  Text("Model : "+model),
                  Text("Satıcı : "+saticiAdi),
                ],
              ),
              SizedBox(width: 40,),
              Column(
                children: [
                  if (durum=="AKTİF/HAZIR") Text("UYGUN",style: TextStyle(color: Colors.green,fontWeight: FontWeight
                  .bold),) else Text("KİRADA",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
                  Text('$fiyat TL'),
                ],
              ),
            ],

          ),
        ],
      ),
    );
  }

}












