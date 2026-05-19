import 'package:flutter/material.dart';
import 'package:ps_kiralama/screens/musteri/musteri_profil_screen.dart';
import 'package:ps_kiralama/services/supabase_client.dart';

class KiralamalarimScreen extends StatefulWidget {
  const KiralamalarimScreen({super.key});

  @override
  State<KiralamalarimScreen> createState() => _KiralamalarimScreenState();
}

class _KiralamalarimScreenState extends State<KiralamalarimScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  List<Map<String, dynamic>> _aktifKiralamalar = [];
  List<Map<String, dynamic>> _gecmisKiralamalar = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _kiralamalariGetir();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _kiralamalariGetir() async {
    setState(() => _yukleniyor = true);

    try {
      // musteri_id al
      final musteri = await supabase
          .from('musteriler')
          .select('musteri_id')
          .eq('user_id', supabase.auth.currentUser!.id)
          .single();

      final musteriId = musteri['musteri_id'].toString();

      // kiralamaları çek
      final data = await supabase
          .from('kiralamalar')
          .select('''
            kiralama_id,
            baslangic_tarihi,
            bitis_tarihi,
            ilanlar (
              fiyat,
              konsollar (
                konsol_modeli,
                saticilar (
                  satici_adi,
                  satici_soyadi,
                  satici_teli
                )
              )
            ),
            degerlendirmeler (
              puan,
              yorum,
              tarih
            )
          ''')
          .eq('musteri_id', musteriId);

      final tumKiralamalar = List<Map<String, dynamic>>.from(data);
      final simdi = DateTime.now();

      setState(() {
        _aktifKiralamalar = tumKiralamalar.where((k) {
          final bitis = DateTime.parse(k['bitis_tarihi']);
          return bitis.isAfter(simdi);
        }).toList();

        _gecmisKiralamalar = tumKiralamalar.where((k) {
          final bitis = DateTime.parse(k['bitis_tarihi']);
          return bitis.isBefore(simdi);
        }).toList();

        _yukleniyor = false;
      });

    } catch (e) {
      setState(() => _yukleniyor = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: 'Aktif'),
            Tab(text: 'Geçmiş'),
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


      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _kiralamaListesi(_aktifKiralamalar, aktif: true),
          _kiralamaListesi(_gecmisKiralamalar, aktif: false),
        ],
      ),
    );
  }

  Widget _kiralamaListesi(List<Map<String, dynamic>> kiralamalar, {required bool aktif}) {
    if (kiralamalar.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              aktif
                  ? 'Aktif kiralamanız bulunmamaktadır.'
                  : 'Geçmiş kiralamanız bulunmamaktadır.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: kiralamalar.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return _kiralamaKarti(kiralamalar[index], aktif: aktif);
      },
    );
  }

  Widget _kiralamaKarti(Map<String, dynamic> kiralama, {required bool aktif}) {
    final ilan = kiralama['ilanlar'] as Map<String, dynamic>?;
    final konsol = ilan?['konsollar'] as Map<String, dynamic>?;
    final satici = konsol?['saticilar'] as Map<String, dynamic>?;
    final degerlendirmeler = kiralama['degerlendirmeler'];

    if (konsol == null || satici == null) return const SizedBox();

    final model = konsol['konsol_modeli'] ?? 'PS5';
    final fiyat = ilan?['fiyat']?.toString() ?? '0';
    final saticiAdi = '${satici['satici_adi']} ${satici['satici_soyadi']}';
    final baslangic = kiralama['baslangic_tarihi'].toString().substring(0, 10);
    final bitis = kiralama['bitis_tarihi'].toString().substring(0, 10);

    int? puan;
    if (degerlendirmeler is List && degerlendirmeler.isNotEmpty) {
      puan = degerlendirmeler[0]['puan'];
    }

    return InkWell(
      onTap: !aktif && puan == null
          ? () => _degerlendirDialog(kiralama)
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [

            // Konsol görseli
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
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
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    saticiAdi,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$baslangic → $bitis',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$fiyat TL / gün',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Sağ taraf
            aktif
                ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Aktif',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            )
                : puan != null
                ? Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text(' $puan',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            )
                : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Değerlendir',
                style: TextStyle(color: Colors.orange, fontSize: 11),
              ),
            ),

            const SizedBox(width: 4),
            if (!aktif)
              Icon(Icons.chevron_right, color: Colors.grey.shade400),

          ],
        ),
      ),
    );
  }

  void _degerlendirDialog(Map<String, dynamic> kiralama) {
    int _puan = 5;
    final yorumController = TextEditingController();

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
                  'Değerlendirme Yap',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Yıldız seçimi
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () => setModalState(() => _puan = i + 1),
                      child: Icon(
                        i < _puan ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 36,
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // Yorum
                TextField(
                  controller: yorumController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Yorumunuzu yazın...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Gönder butonu
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await supabase.from('degerlendirmeler').insert({
                          'kiralama_id': kiralama['kiralama_id'],
                          'puan': _puan,
                          'yorum': yorumController.text.trim(),
                        });

                        await supabase.from('logs').insert({
                          'user_id': supabase.auth.currentUser!.id,
                          'islem': 'degerlendirme_yapildi',
                          'aciklama': '${kiralama['kiralama_id']} için $_puan puan verildi',
                        });

                        if (mounted) {
                          Navigator.pop(context);
                          _kiralamalariGetir();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Değerlendirme gönderildi!')),
                          );
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
                      'Gönder',
                      style: TextStyle(color: Colors.white, fontSize: 16),
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