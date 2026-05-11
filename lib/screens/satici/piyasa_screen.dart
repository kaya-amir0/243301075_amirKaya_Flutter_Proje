import 'package:flutter/material.dart';

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
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              child: const Icon(Icons.person),
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5, // geçici, Supabase'den gelecek
              itemBuilder: (context, index) {
                return _ilanKarti(index);
              },
            ),
          ),

        ],
      ),
    );
  }

  // İlan kartı widget'ı
  Widget _ilanKarti(int index) {
    String model = index % 2 == 0 ? 'PS5' : 'PS4';

    return Container(
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
                    'Ali Yılmaz',
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

            // Fiyat + durum
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '150 TL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
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
                    'Müsait',
                    style: TextStyle(color: Colors.green, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}






















