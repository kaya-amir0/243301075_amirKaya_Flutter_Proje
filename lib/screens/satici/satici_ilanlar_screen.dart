import 'package:flutter/material.dart';
import 'package:ps_kiralama/services/supabase_client.dart';

class SaticiIlanlarScreen extends StatefulWidget {
  const SaticiIlanlarScreen({super.key});

  @override
  State<SaticiIlanlarScreen> createState() => _SaticiIlanlarScreenState();
}

class _SaticiIlanlarScreenState extends State<SaticiIlanlarScreen>

    with SingleTickerProviderStateMixin {


  late TabController _tabController;
  List<Map<String, dynamic>> _aktifIlanlar = [];
  List<Map<String, dynamic>> _gecmisIlanlar = [];
  bool _yukleniyor = true;
  String? _saticiId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _ilanlariGetir();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _ilanlariGetir() async {
    setState(() => _yukleniyor = true);

    try {
      // satici_id'yi al
      final satici = await supabase
          .from('saticilar')
          .select('satici_id')
          .eq('user_id', supabase.auth.currentUser!.id)
          .single();

      _saticiId = satici['satici_id'].toString();

      // ilanları çek
      final data = await supabase
          .from('ilanlar')
          .select('''
            ilan_id,
            fiyat,
            durum,
            konsollar (
              konsol_id,
              konsol_modeli,
              konsol_seri_no,
              satici_id
            )
          ''');

      final tumIlanlar = List<Map<String, dynamic>>.from(data);


      // satıcıya ait ilanları filtrele
      final benimIlanlar = tumIlanlar.where((ilan) {
        final konsol = ilan['konsollar'] as Map<String, dynamic>?;
        return konsol?['satici_id'].toString() == _saticiId;
      }).toList();

      setState(() {
        _aktifIlanlar = benimIlanlar
            .where((i) => i['durum'] == 'AKTİF/HAZIR' || i['durum'] == 'KİRADA')
            .toList();
        _gecmisIlanlar = benimIlanlar
            .where((i) => i['durum'] == 'PASİF')
            .toList();
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

  Future<void> _ilanKaldir(String ilanId) async {
    try {
      await supabase
          .from('ilanlar')
          .update({'durum': 'PASİF'})
          .eq('ilan_id', ilanId);

      await supabase.from('logs').insert({
        'user_id': supabase.auth.currentUser!.id,
        'islem': 'ilan_kaldirildi',
        'aciklama': '$ilanId nolu ilan kaldırıldı',
      });

      _ilanlariGetir();
    } catch (e) {
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
          'İlanlarım',
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
            Tab(text: 'Aktif İlanlar'),
            Tab(text: 'Geçmiş İlanlar'),
          ],
        ),
      ),

      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          // Aktif ilanlar
          _ilanListesi(_aktifIlanlar, aktif: true),
          // Geçmiş ilanlar
          _ilanListesi(_gecmisIlanlar, aktif: false),
        ],
      ),
    );
  }

  Widget _ilanListesi(List<Map<String, dynamic>> ilanlar, {required bool aktif}) {
    if (ilanlar.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              aktif
                  ? 'Henüz aktif ilanınız bulunmamaktadır.'
                  : 'Geçmiş ilanınız bulunmamaktadır.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: ilanlar.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return _ilanKarti(ilanlar[index], aktif: aktif);
      },
    );
  }

  Widget _ilanKarti(Map<String, dynamic> ilan, {required bool aktif}) {
    final konsol = ilan['konsollar'] as Map<String, dynamic>;
    final model = konsol['konsol_modeli'] ?? 'PS5';
    final fiyat = ilan['fiyat']?.toString() ?? '0';
    final durum = ilan['durum'] ?? 'AKTİF/HAZIR';
    final ilanId = ilan['ilan_id'].toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [

          // Konsol görseli
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
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
                  '$fiyat TL / gün',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: durum == 'AKTİF/HAZIR'
                        ? Colors.green.shade50
                        : durum == 'KİRADA'
                        ? Colors.orange.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    durum,
                    style: TextStyle(
                      color: durum == 'AKTİF/HAZIR'
                          ? Colors.green
                          : durum == 'KİRADA'
                          ? Colors.orange
                          : Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Aktif ilanlar için kaldır butonu
          if (aktif)
            IconButton(
              onPressed: () => _ilanKaldirOnay(ilanId),
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
            ),

        ],
      ),
    );
  }

  void _ilanKaldirOnay(String ilanId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('İlanı Kaldır'),
        content: const Text('Bu ilanı kaldırmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _ilanKaldir(ilanId);
            },
            child: const Text('Kaldır', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void ilanEkleDialog() {
    final fiyatController = TextEditingController();
    String? secilenKonsolId;
    List<Map<String, dynamic>> konsollar = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          if (konsollar.isEmpty) {
            supabase
                .from('konsollar')
                .select()
                .eq('satici_id', _saticiId!)
                .then((data) {
              setModalState(() {
                konsollar = List<Map<String, dynamic>>.from(data);
              });
            });
          }

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
                  'Yeni İlan Ekle',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  hint: const Text('Konsol Seç'),
                  value: secilenKonsolId,
                  items: konsollar.map((k) {
                    return DropdownMenuItem(
                      value: k['konsol_id'].toString(),
                      child: Text('${k['konsol_modeli']} - ${k['konsol_seri_no']}'),
                    );
                  }).toList(),
                  onChanged: (val) => setModalState(() => secilenKonsolId = val),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: fiyatController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Günlük Fiyat (TL)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (secilenKonsolId == null || fiyatController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tüm alanları doldurun!')),
                        );
                        return;
                      }

                      await supabase.from('ilanlar').insert({
                        'konsol_id': secilenKonsolId,
                        'fiyat': double.parse(fiyatController.text),
                        'durum': 'AKTİF/HAZIR',
                      });

                      await supabase.from('logs').insert({
                        'user_id': supabase.auth.currentUser!.id,
                        'islem': 'ilan_eklendi',
                        'aciklama': '$secilenKonsolId için ilan eklendi',
                      });

                      if (mounted) {
                        Navigator.pop(context);
                        _ilanlariGetir();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('İlan Ekle', style: TextStyle(color: Colors.white)),
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