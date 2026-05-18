import 'package:flutter/material.dart';
import 'package:ps_kiralama/services/supabase_client.dart';

class IlanEkleScreen extends StatefulWidget {
  const IlanEkleScreen({super.key});

  @override
  State<IlanEkleScreen> createState() => _IlanEkleScreenState();
}

class _IlanEkleScreenState extends State<IlanEkleScreen> {

  final fiyatController = TextEditingController();
  final seriNoController = TextEditingController();
  String? _secilenKonsolId;
  String _secilenModel = 'PS5';
  List<Map<String, dynamic>> _konsollar = [];
  bool _yukleniyor = false;
  bool _konsolEkleAcik = false; // konsol ekleme formu açık mı
  String? _saticiId;

  @override
  void initState() {
    super.initState();
    _konsollariGetir();
  }

  @override
  void dispose() {
    fiyatController.dispose();
    seriNoController.dispose();
    super.dispose();
  }

  Future<void> _konsollariGetir() async {
    try {
      final satici = await supabase
          .from('saticilar')
          .select('satici_id')
          .eq('user_id', supabase.auth.currentUser!.id)
          .single();

      _saticiId = satici['satici_id'].toString();

      final data = await supabase
          .from('konsollar')
          .select()
          .eq('satici_id', _saticiId!);

      setState(() {
        _konsollar = List<Map<String, dynamic>>.from(data);
      });

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Future<void> _konsolEkle() async {
    if (seriNoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seri no giriniz!')),
      );
      return;
    }

    setState(() => _yukleniyor = true);

    try {
      await supabase.from('konsollar').insert({
        'satici_id': _saticiId,
        'konsol_modeli': _secilenModel,
        'konsol_seri_no': seriNoController.text.trim(),
      });

      await supabase.from('logs').insert({
        'user_id': supabase.auth.currentUser!.id,
        'islem': 'konsol_eklendi',
        'aciklama': '$_secilenModel eklendi',
      });

      seriNoController.clear();
      setState(() => _konsolEkleAcik = false);

      // konsolları yenile
      await _konsollariGetir();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konsol eklendi!')),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      setState(() => _yukleniyor = false);
    }
  }

  Future<void> _ilanEkle() async {
    if (_secilenKonsolId == null || fiyatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tüm alanları doldurun!')),
      );
      return;
    }

    setState(() => _yukleniyor = true);

    try {
      await supabase.from('ilanlar').insert({
        'konsol_id': _secilenKonsolId,
        'fiyat': double.parse(fiyatController.text),
        'durum': 'AKTİF/HAZIR',
      });

      await supabase.from('logs').insert({
        'user_id': supabase.auth.currentUser!.id,
        'islem': 'ilan_eklendi',
        'aciklama': '$_secilenKonsolId için ilan eklendi',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İlan başarıyla eklendi!')),
        );
        Navigator.pop(context, true);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      setState(() => _yukleniyor = false);
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
          'İlan Ekle',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // KONSOL SEÇ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Konsol Seç',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                // Konsol ekle butonu
                TextButton.icon(
                  onPressed: () => setState(() => _konsolEkleAcik = !_konsolEkleAcik),
                  icon: Icon(_konsolEkleAcik ? Icons.close : Icons.add, size: 18),
                  label: Text(_konsolEkleAcik ? 'İptal' : 'Konsol Ekle'),
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Konsol ekleme formu - açılır kapanır
            if (_konsolEkleAcik) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      'Yeni Konsol Ekle',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // Model seç
                    Row(
                      children: [
                        _modelButon('PS4'),
                        const SizedBox(width: 12),
                        _modelButon('PS5'),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Seri no
                    TextField(
                      controller: seriNoController,
                      decoration: InputDecoration(
                        labelText: 'Seri No',
                        hintText: 'Örn: SN-PS5-001',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Ekle butonu
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _yukleniyor ? null : _konsolEkle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Konsolu Kaydet',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Konsol dropdown
            _konsollar.isEmpty
                ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey.shade500),
                  const SizedBox(width: 8),
                  const Text(
                    'Henüz konsolunuz yok.\nYukarıdan konsol ekleyin.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
                : DropdownButtonFormField<String>(
              hint: const Text('Konsol seçin'),
              value: _secilenKonsolId,
              items: _konsollar.map((k) {
                return DropdownMenuItem(
                  value: k['konsol_id'].toString(),
                  child: Row(
                    children: [
                      Image.asset(
                        k['konsol_modeli'] == 'PS5'
                            ? 'assets/ps5.png'
                            : 'assets/ps4.png',
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 8),
                      Text('${k['konsol_modeli']} - ${k['konsol_seri_no']}'),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _secilenKonsolId = val),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // GÜNLÜK FİYAT
            const Text(
              'Günlük Fiyat',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: fiyatController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Örn: 150',
                suffixText: 'TL',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // İLAN EKLE BUTONU
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _yukleniyor ? null : _ilanEkle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _yukleniyor
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'İlan Ekle',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  // PS4 / PS5 seçim butonu
  Widget _modelButon(String model) {
    final secili = _secilenModel == model;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _secilenModel = model),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: secili ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                model == 'PS5' ? 'assets/ps5.png' : 'assets/ps4.png',
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 8),
              Text(
                model,
                style: TextStyle(
                  color: secili ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}