import 'package:flutter/material.dart';
import 'package:ps_kiralama/screens/musteri/musteri_ana_screen.dart';

import 'package:ps_kiralama/screens/satici/piyasa_screen.dart';
import 'package:ps_kiralama/screens/satici/satici_ana_screen.dart';
import 'package:ps_kiralama/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ps_kiralama/screens/auth/login_screen.dart';



void main()  async{
  runApp(const MyApp()); // Tekrar dönüp baktığımda unutmamak adına bir kaç yorum ekleyeceğim.

  WidgetsFlutterBinding.ensureInitialized(); // Flutter widget bağlantısını başlat demek.

  await Supabase.initialize(url: "https://qzrbnrddeepjklpseesn.supabase.co",
      anonKey: "sb_publishable_eQfUIGyJnnSf6nxCF7UJjw_ucteeJvj");
  // Bu kısım supabase bağlantısını başlatıyor.
  // await ise supabase bağlantısı kurulmadan uygulama açılmasın bekle diyor.


}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false, // flutter da belkide ilk öğrendiğim şey :)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: _baslangicEkrani(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[



          ],
        ),
      ),

    );
  }
}


Widget _baslangicEkrani() {
  final rol = AuthService().mevcutKullaniciRol();

  if (rol == 'satici') {
    return const SaticiAnaScreen();
  } else if (rol == 'musteri') {
    return const MusteriAnaScreen();
  } else {
    return const LoginScreen();
  }
}