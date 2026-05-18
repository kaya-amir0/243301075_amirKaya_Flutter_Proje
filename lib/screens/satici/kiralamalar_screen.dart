import 'package:flutter/material.dart';
import 'package:ps_kiralama/services/supabase_client.dart';
import 'package:ps_kiralama/screens/satici/kiralama_detay_screen.dart';

class KiralamalarScreen extends StatefulWidget {
  const KiralamalarScreen({super.key});

  @override
  State<KiralamalarScreen> createState() => _KiralamalarScreenState();
}

class _KiralamalarScreenState extends State<KiralamalarScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  List<Map<String, dynamic>> _aktifKiralamalar = [];
  List<Map<String, dynamic>> _gecmisKiralamalar = [];
  bool _yukleniyor = true;
  String? _saticiId;

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
      // satici_id al
      final satici = await supabase
          .from('saticilar')
          .select('satici_id')
          .eq('user_id', supabase.auth.currentUser!.id)
          .single();

      _saticiId = satici['satici_id'].toString();

      // satıcının ilanlarına yapılan kiralamaları çek
      final data = await supabase
          .from('kiralamalar')
          .select('''
            kiralama_id,
            baslangic_tarihi,
            bitis_tarihi,
            musteriler (
              musteri_adi,
              musteri_soyadi,
              musteri_tel
            ),
            ilanlar (
              fiyat,
              konsollar (
                konsol_modeli,
                satici_id
              )
            ),
            degerlendirmeler (
              puan,
              yorum,
              tarih
            )
          ''');
      print('Kiralamalar: $data');
      final tumKiralamalar = List<Map<String, dynamic>>.from(data);

      // sadece bu satıcıya ait kiralamaları filtrele
      final benimKiralamalar = tumKiralamalar.where((k) {
        final ilan = k['ilanlar'] as Map<String, dynamic>?;
        final konsol = ilan?['konsollar'] as Map<String, dynamic>?;
        return konsol?['satici_id'].toString() == _saticiId;
      }).toList();

      final simdi = DateTime.now();

      setState(() {
        _aktifKiralamalar = benimKiralamalar.where((k) {
          final bitis = DateTime.parse(k['bitis_tarihi']);
          return bitis.isAfter(simdi);
        }).toList();

        _gecmisKiralamalar = benimKiralamalar.where((k) {
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
        title: const Text(
          'Kiralamalar',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
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
    final musteri = kiralama['musteriler'] as Map<String, dynamic>?;
    final ilan = kiralama['ilanlar'] as Map<String, dynamic>?;
    final konsol = ilan?['konsollar'] as Map<String, dynamic>?;
    final degerlendirme = kiralama['degerlendirmeler'];

    final musteriAdi = musteri != null
        ? '${musteri['musteri_adi']} ${musteri['musteri_soyadi']}'
        : 'Bilinmiyor';
    final model = konsol?['konsol_modeli'] ?? 'PS5';
    final baslangic = kiralama['baslangic_tarihi'].toString().substring(0, 10);
    final bitis = kiralama['bitis_tarihi'].toString().substring(0, 10);

    // değerlendirme puanı
    int? puan;
    if (degerlendirme is List && degerlendirme.isNotEmpty) {
      puan = degerlendirme[0]['puan'];
    } else if (degerlendirme is Map) {
      puan = degerlendirme['puan'];
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => KiralamaDetayScreen(kiralama: kiralama),
          ),
        );
      },
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
                    musteriAdi,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    model,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$baslangic → $bitis',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Puan veya aktif badge
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
                Text(
                  ' $puan',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            )
                : Text(
              'Puanlanmadı',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),

            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),

          ],
        ),
      ),
    );
  }
}