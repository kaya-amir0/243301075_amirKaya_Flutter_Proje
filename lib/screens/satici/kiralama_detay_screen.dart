import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class KiralamaDetayScreen extends StatelessWidget {
  final Map<String, dynamic> kiralama;

  const KiralamaDetayScreen({super.key, required this.kiralama});

  @override
  Widget build(BuildContext context) {
    final musteri = kiralama['musteriler'] as Map<String, dynamic>?;
    final ilan = kiralama['ilanlar'] as Map<String, dynamic>?;
    final konsol = ilan?['konsollar'] as Map<String, dynamic>?;
    final degerlendirmeler = kiralama['degerlendirmeler'];

    final musteriAdi = musteri != null
        ? '${musteri['musteri_adi']} ${musteri['musteri_soyadi']}'
        : 'Bilinmiyor';
    final musteriTel = musteri?['musteri_tel'] ?? '';
    final model = konsol?['konsol_modeli'] ?? 'PS5';
    final fiyat = ilan?['fiyat']?.toString() ?? '0';
    final baslangic = kiralama['baslangic_tarihi'].toString().substring(0, 10);
    final bitis = kiralama['bitis_tarihi'].toString().substring(0, 10);

    // değerlendirme
    Map<String, dynamic>? degerlendirme;
    if (degerlendirmeler is List && degerlendirmeler.isNotEmpty) {
      degerlendirme = degerlendirmeler[0] as Map<String, dynamic>;
    } else if (degerlendirmeler is Map) {
      degerlendirme = degerlendirmeler as Map<String, dynamic>;
    }

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Kiralama Detayı',
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

            // Konsol görseli + model
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        model == 'PS5' ? 'assets/ps5.png' : 'assets/ps4.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    model,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$fiyat TL / gün',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Kiralama tarihleri
            _baslik('Kiralama Tarihleri'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _bilgiKutusu(
                    icon: Icons.calendar_today,
                    baslik: 'Başlangıç',
                    deger: baslangic,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _bilgiKutusu(
                    icon: Icons.calendar_month,
                    baslik: 'Bitiş',
                    deger: bitis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Müşteri bilgileri
            _baslik('Müşteri Bilgileri'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              musteriAdi,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              musteriTel,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Ara ve SMS butonları
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _ara(musteriTel),
                          icon: const Icon(Icons.phone, color: Colors.black),
                          label: const Text(
                            'Ara',
                            style: TextStyle(color: Colors.black),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _smsGonder(musteriTel),
                          icon: const Icon(Icons.sms, color: Colors.white),
                          label: const Text(
                            'SMS',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Değerlendirme
            _baslik('Değerlendirme'),
            const SizedBox(height: 12),
            degerlendirme != null
                ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Yıldızlar
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < (degerlendirme!['puan'] ?? 0)
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 24,
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  // Yorum
                  Text(
                    degerlendirme['yorum'] ?? 'Yorum yapılmadı',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  // Tarih
                  Text(
                    degerlendirme['tarih']?.toString().substring(0, 10) ?? '',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
                : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.star_border, color: Colors.grey.shade400),
                  const SizedBox(width: 8),
                  Text(
                    'Henüz değerlendirme yapılmadı.',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Ara
  Future<void> _ara(String tel) async {
    final uri = Uri.parse('tel:$tel');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // SMS gönder
  Future<void> _smsGonder(String tel) async {
    final uri = Uri.parse('sms:$tel');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _baslik(String baslik) {
    return Text(
      baslik,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _bilgiKutusu({
    required IconData icon,
    required String baslik,
    required String deger,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(height: 4),
          Text(
            baslik,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            deger,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}