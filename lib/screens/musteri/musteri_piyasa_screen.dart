import 'package:flutter/material.dart';
import 'package:ps_kiralama/screens/musteri/musteri_profil_screen.dart';
import 'package:ps_kiralama/services/supabase_client.dart';

class MusteriPiyasaScreen extends StatefulWidget {
  const MusteriPiyasaScreen({super.key});

  @override
  State<MusteriPiyasaScreen> createState() => _MusteriPiyasaScreenState();
}

class _MusteriPiyasaScreenState extends State<MusteriPiyasaScreen> {

  final searchController = TextEditingController();
  String _secilenFiltre = 'En Güncel';
  List<Map<String, dynamic>> _ilanlar = [];
  bool _yukleniyor = true;

  final List<String> _filtreler = [
    'En Güncel',
    'Popüler',
    'En Ucuz',
    'Yakınımda',
  ];

  @override
  void initState() {
    super.initState();
    _ilanlariGetir();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _ilanlariGetir() async {
    setState(() => _yukleniyor = true);

    try {
      final data = await supabase
          .from('ilanlar')
          .select('''
          ilan_id,
          fiyat,
          durum,
          konsollar (
            konsol_modeli,
            saticilar (
              satici_id,
              satici_adi,
              satici_soyadi,
              satici_enlemi,
              satici_boylami 
            )
          )
        ''')
          .eq('durum', 'AKTİF/HAZIR');

      print('İlanlar: $data'); // bunu ekle

      setState(() {
        _ilanlar = List<Map<String, dynamic>>.from(data);

        _yukleniyor = false;
      });
    } catch (e) {
      print('Hata: $e'); // bunu ekle
      setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtrelenmis = _ilanlar.where((ilan) {
      final konsol = ilan['konsollar'] as Map<String, dynamic>?;
      final satici = konsol?['saticilar'] as Map<String, dynamic>?;
      final model = konsol?['konsol_modeli'] ?? '';
      final ad = '${satici?['satici_adi'] ?? ''} ${satici?['satici_soyadi'] ?? ''}';
      return model.toLowerCase().contains(searchController.text.toLowerCase()) ||
          ad.toLowerCase().contains(searchController.text.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: const [
                Text("Playstation", style: TextStyle(fontSize: 12, color: Colors.black)),
                Text("Zamanı", style: TextStyle(fontSize: 15, color: Colors.black)),
              ],
            ),

            SizedBox(
              width: 70,
              height: 70,
              child: Image.asset("assets/logo.png"),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MusteriProfilScreen()),
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
              itemCount: _filtreler.length,
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
            child: _yukleniyor
                ? const Center(child: CircularProgressIndicator())
                : filtrelenmis.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Aktif ilan bulunamadı.',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtrelenmis.length,
              itemBuilder: (context, index) {
                return _ilanKarti(filtrelenmis[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _ilanKarti(Map<String, dynamic> ilan) {
    final konsol = ilan['konsollar'] as Map<String, dynamic>?;
    final satici = konsol?['saticilar'] as Map<String, dynamic>?;

    if (konsol == null || satici == null) return const SizedBox();

    final model = konsol['konsol_modeli'] ?? 'PS5';
    final fiyat = ilan['fiyat']?.toString() ?? '0';
    final saticiAdi = '${satici['satici_adi']} ${satici['satici_soyadi']}';

    return GestureDetector(
      onTap: () => _kiralamaDialog(ilan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [

              // Konsol görseli
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    model == 'PS5' ? 'assets/ps5.png' : 'assets/ps4.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Bilgiler
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      saticiAdi,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const Text(' 4.8  ', style: TextStyle(fontSize: 12)),
                        Icon(Icons.location_on, color: Colors.grey.shade400, size: 16),
                        Text(' 2 km', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),

              // Fiyat
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$fiyat TL',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text('/gün', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Kirala',
                      style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  void _kiralamaDialog(Map<String, dynamic> ilan) {
    DateTime? baslangic;
    DateTime? bitis;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24, right: 24, top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  'Kiralama Tarihleri',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Başlangıç tarihi
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(baslangic == null
                      ? 'Başlangıç tarihi seç'
                      : '${baslangic!.day}/${baslangic!.month}/${baslangic!.year}'),
                  onTap: () async {
                    final tarih = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (tarih != null) setModalState(() => baslangic = tarih);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),

                const SizedBox(height: 12),

                // Bitiş tarihi
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: Text(bitis == null
                      ? 'Bitiş tarihi seç'
                      : '${bitis!.day}/${bitis!.month}/${bitis!.year}'),
                  onTap: () async {
                    final tarih = await showDatePicker(
                      context: context,
                      initialDate: baslangic ?? DateTime.now(),
                      firstDate: baslangic ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (tarih != null) setModalState(() => bitis = tarih);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),

                const SizedBox(height: 16),

                // Kirala butonu
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (baslangic == null || bitis == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tarihleri seçin!')),
                        );
                        return;
                      }

                      try {
                        // musteri_id al
                        final musteri = await supabase
                            .from('musteriler')
                            .select('musteri_id')
                            .eq('user_id', supabase.auth.currentUser!.id)
                            .single();

                        // kiralama ekle
                        await supabase.from('kiralamalar').insert({
                          'ilan_id': ilan['ilan_id'],
                          'musteri_id': musteri['musteri_id'],
                          'baslangic_tarihi': baslangic!.toIso8601String(),
                          'bitis_tarihi': bitis!.toIso8601String(),
                        });

                        // ilanı kirada yap
                        await supabase
                            .from('ilanlar')
                            .update({'durum': 'KİRADA'})
                            .eq('ilan_id', ilan['ilan_id']);

                        // log kaydı
                        await supabase.from('logs').insert({
                          'user_id': supabase.auth.currentUser!.id,
                          'islem': 'kiralama_yapildi',
                          'aciklama': '${ilan['ilan_id']} nolu ilan kiralandı',
                        });

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kiralama başarılı!')),
                          );
                          _ilanlariGetir(); // listeyi yenile
                        }

                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Hata: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Kirala',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}