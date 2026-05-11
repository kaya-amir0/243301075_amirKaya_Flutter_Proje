import 'package:flutter/material.dart';

class SaticiIlanlarScreen extends StatefulWidget {
  const SaticiIlanlarScreen({super.key});

  @override
  State<SaticiIlanlarScreen> createState() => _SaticiIlanlarScreenState();
}

class _SaticiIlanlarScreenState extends State<SaticiIlanlarScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text("Hoşgeldiniz"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Column(
        children: [
           Text('İlanlarım', style: TextStyle(color: Colors.white)),

        ],

      ),
    );
  }
}
