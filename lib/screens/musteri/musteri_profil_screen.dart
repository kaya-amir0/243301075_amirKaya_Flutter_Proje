import 'package:flutter/material.dart';
import 'package:ps_kiralama/services/auth_service.dart';
import 'package:ps_kiralama/services/supabase_client.dart';
import 'package:ps_kiralama/screens/auth/login_screen.dart';

class MusteriProfilScreen extends StatefulWidget {
  const MusteriProfilScreen({super.key});

  @override
  State<MusteriProfilScreen> createState() => _MusteriProfilScreenState();
}

class _MusteriProfilScreenState extends State<MusteriProfilScreen> {

  Map<String, dynamic>? _musteri;
  bool _yukleniyor = true;
  bool _duzenlemeModu = false;
  int _toplamKiralama = 0;
  double _ortalamaPuan = 0.0;
  final authService = AuthService();

  // Düzenleme için controller'lar
  final adController = TextEditingController();
  final soyadController = TextEditingController();
  final telController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _musteriGetir();
  }

  @override
  void dispose() {
    adController.dispose();
    soyadController.dispose();
    telController.dispose();
    super.dispose();
  }

  Future<void> _musteriGetir() async {
    try {
      final data = await supabase
          .from('musteriler')
          .select()
          .eq('user_id', supabase.auth.currentUser!.id)
          .single();

      // İstatistikleri çek
      final musteriId = data['musteri_id'].toString();

      final kiralamalar = await supabase
          .from('kiralamalar')
          .select('kiralama_id, degerlendirmeler(puan)')
          .eq('musteri_id', musteriId);

      int toplamKiralama = kiralamalar.length;
      double toplamPuan = 0;
      int puanSayisi = 0;

      for (final k in kiralamalar) {
        final degerlendirmeler = k['degerlendirmeler'];
        if (degerlendirmeler is List && degerlendirmeler.isNotEmpty) {
          toplamPuan += degerlendirmeler[0]['puan'];
          puanSayisi++;
        }
      }

      setState(() {
        _musteri = data;
        _toplamKiralama = toplamKiralama;
        _ortalamaPuan = puanSayisi > 0 ? toplamPuan / puanSayisi : 0.0;
        _yukleniyor = false;

        // Controller'ları doldur
        adController.text = data['musteri_adi'] ?? '';
        soyadController.text = data['musteri_soyadi'] ?? '';
        telController.text = data['musteri_tel'] ?? '';
      });
    } catch (e) {
      setState(() => _yukleniyor = false);
    }
  }

  Future<void> _bilgileriGuncelle() async {
    try {
      await supabase
          .from('musteriler')
          .update({
        'musteri_adi': adController.text.trim(),
        'musteri_soyadi': soyadController.text.trim(),
        'musteri_tel': telController.text.trim(),
      })
          .eq('user_id', supabase.auth.currentUser!.id);

      // Log kaydı
      await supabase.from('logs').insert({
        'user_id': supabase.auth.currentUser!.id,
        'islem': 'profil_guncellendi',
        'aciklama': 'Müşteri profil bilgileri güncellendi',
      });

      setState(() => _duzenlemeModu = false);
      await _musteriGetir();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil güncellendi!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Future<void> _cikisYap() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authService.cikisYap();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
            child: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profilim',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Düzenle / Kaydet butonu
          IconButton(
            onPressed: () {
              if (_duzenlemeModu) {
                _bilgileriGuncelle();
              } else {
                setState(() => _duzenlemeModu = true);
              }
            },
            icon: Icon(
              _duzenlemeModu ? Icons.check : Icons.edit,
              color: _duzenlemeModu ? Colors.green : Colors.black,
            ),
          ),
          IconButton(
            onPressed: _cikisYap,
            icon: const Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),

      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : _musteri == null
          ? const Center(child: Text('Profil bulunamadı'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.black,
              child: Text(
                _musteri!['musteri_adi'][0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              '${_musteri!['musteri_adi']} ${_musteri!['musteri_soyadi']}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              supabase.auth.currentUser?.email ?? '',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),

            const SizedBox(height: 24),

            // İstatistikler
            Row(
              children: [
                Expanded(
                  child: _istatistikKutusu(
                    icon: Icons.history,
                    deger: '$_toplamKiralama',
                    baslik: 'Kiralama',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _istatistikKutusu(
                    icon: Icons.star,
                    deger: _ortalamaPuan > 0
                        ? _ortalamaPuan.toStringAsFixed(1)
                        : '-',
                    baslik: 'Ort. Puan',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Bilgiler — düzenleme moduna göre değişir
            _duzenlemeModu
                ? _duzenleFormu()
                : _bilgiListesi(),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Çıkış butonu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _cikisYap,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Çıkış Yap',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // İstatistik kutusu
  Widget _istatistikKutusu({
    required IconData icon,
    required String deger,
    required String baslik,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.black, size: 24),
          const SizedBox(height: 8),
          Text(
            deger,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            baslik,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Bilgi listesi (görüntüleme modu)
  Widget _bilgiListesi() {
    return Column(
      children: [
        _bilgiSatiri(
          icon: Icons.person,
          baslik: 'Ad',
          deger: _musteri!['musteri_adi'] ?? '-',
        ),
        const SizedBox(height: 12),
        _bilgiSatiri(
          icon: Icons.person_outline,
          baslik: 'Soyad',
          deger: _musteri!['musteri_soyadi'] ?? '-',
        ),
        const SizedBox(height: 12),
        _bilgiSatiri(
          icon: Icons.phone,
          baslik: 'Telefon',
          deger: _musteri!['musteri_tel'] ?? 'Eklenmemiş',
        ),
      ],
    );
  }

  // Düzenleme formu
  Widget _duzenleFormu() {
    return Column(
      children: [
        _duzenlemeAlani(adController, 'Ad', Icons.person),
        const SizedBox(height: 12),
        _duzenlemeAlani(soyadController, 'Soyad', Icons.person_outline),
        const SizedBox(height: 12),
        _duzenlemeAlani(telController, 'Telefon', Icons.phone,
            klavyeTipi: TextInputType.phone),
      ],
    );
  }

  Widget _duzenlemeAlani(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType klavyeTipi = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      keyboardType: klavyeTipi,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
    );
  }

  Widget _bilgiSatiri({
    required IconData icon,
    required String baslik,
    required String deger,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.black, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              baslik,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            Text(
              deger,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }
}