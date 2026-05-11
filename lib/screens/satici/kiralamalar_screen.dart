import 'package:flutter/material.dart';

class KiralamalarScreen extends StatefulWidget {
  const KiralamalarScreen({super.key});

  @override
  State<KiralamalarScreen> createState() => _KiralamalarScreenState();
}

class _KiralamalarScreenState extends State<KiralamalarScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Text('İlanlarım', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
