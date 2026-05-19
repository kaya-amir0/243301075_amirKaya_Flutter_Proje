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
  final authService = AuthService();

  @override
  void initState() {
    super.initState();
    _musteriGetir();
  }

  Future<void> _musteriGetir() async {
    try {
      final data = await supabase
          .from('musteriler')
          .select()
          .eq('user_id', supabase.auth.currentUser!.id)
          .single();

      setState(() {
        _musteri = data;
        _yukleniyor = false;
      });
    } catch (e) {
      setState(() => _yukleniyor = false);
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
            const Divider(),
            const SizedBox(height: 16),

            _bilgiSatiri(
              icon: Icons.phone,
              baslik: 'Telefon',
              deger: _musteri!['musteri_tel'] ?? 'Eklenmemiş',
            ),

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
